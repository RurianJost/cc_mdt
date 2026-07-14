export type NaturalPixelCrop = {
    x: number;
    y: number;
    width: number;
    height: number;
};

function isLocalImageSource(src: string): boolean {
    return src.startsWith("data:") || src.startsWith("blob:");
}

export function loadImageForCrop(src: string): Promise<HTMLImageElement> {
    return new Promise((resolve, reject) => {
        const img = new Image();

        if (!isLocalImageSource(src)) {
            try {
                const url = new URL(src, window.location.href);

                if (url.origin !== window.location.origin) {
                    img.crossOrigin = "anonymous";
                }
            } catch {
                // O carregamento abaixo retornará o erro apropriado.
            }
        }

        img.onload = () => resolve(img);
        img.onerror = () => reject(new Error("Falha ao carregar a imagem."));
        img.src = src;
    });
}

function isImageSafeForCanvas(img: HTMLImageElement): boolean {
    const src = img.currentSrc || img.src || "";
    if (isLocalImageSource(src)) return true;

    try {
        const url = new URL(src, window.location.href);
        if (url.origin === window.location.origin) return true;
    } catch {
        return false;
    }

    return img.crossOrigin === "anonymous" || img.crossOrigin === "use-credentials";
}

export async function getCroppedImageDataUrl(
    imageSrc: string,
    crop: NaturalPixelCrop,
    options?: {
        imageElement?: HTMLImageElement | null;
        jpegQuality?: number;
        maxOutputSize?: number;
    }
): Promise<string> {
    const jpegQuality = options?.jpegQuality ?? 0.88;
    const maxOutputSize = Math.max(64, Math.round(options?.maxOutputSize ?? 512));
    const cropperImage = options?.imageElement;
    const shouldReloadImage = isLocalImageSource(imageSrc);
    const canUseCropperImage =
        !shouldReloadImage &&
        cropperImage &&
        cropperImage.complete &&
        cropperImage.naturalWidth > 0 &&
        isImageSafeForCanvas(cropperImage);
    const image = canUseCropperImage ? cropperImage : await loadImageForCrop(imageSrc);

    try {
        await image.decode();
    } catch {
        // onload já confirmou que a imagem está disponível.
    }

    const naturalWidth = image.naturalWidth;
    const naturalHeight = image.naturalHeight;
    if (!naturalWidth || !naturalHeight) {
        throw new Error("Imagem sem dimensões válidas.");
    }

    let sourceX = Math.max(0, Math.round(crop.x));
    let sourceY = Math.max(0, Math.round(crop.y));
    let sourceWidth = Math.max(1, Math.round(crop.width));
    let sourceHeight = Math.max(1, Math.round(crop.height));

    sourceX = Math.min(sourceX, naturalWidth - 1);
    sourceY = Math.min(sourceY, naturalHeight - 1);
    sourceWidth = Math.min(sourceWidth, naturalWidth - sourceX);
    sourceHeight = Math.min(sourceHeight, naturalHeight - sourceY);

    if (sourceWidth < 1 || sourceHeight < 1) {
        throw new Error("Região de corte inválida.");
    }

    const outputSize = Math.max(1, Math.min(maxOutputSize, sourceWidth, sourceHeight));
    const cropCanvas = document.createElement("canvas");
    cropCanvas.width = outputSize;
    cropCanvas.height = outputSize;

    const cropContext = cropCanvas.getContext("2d", { willReadFrequently: true });
    if (!cropContext) {
        throw new Error("Canvas 2D indisponível.");
    }

    cropContext.imageSmoothingEnabled = true;
    cropContext.imageSmoothingQuality = "high";
    cropContext.clearRect(0, 0, outputSize, outputSize);
    cropContext.drawImage(
        image,
        sourceX,
        sourceY,
        sourceWidth,
        sourceHeight,
        0,
        0,
        outputSize,
        outputSize
    );

    const pixelData = cropContext.getImageData(0, 0, outputSize, outputSize).data;
    let hasVisiblePixel = false;

    for (let index = 3; index < pixelData.length; index += 64) {
        if (pixelData[index] > 0) {
            hasVisiblePixel = true;
            break;
        }
    }

    if (!hasVisiblePixel) {
        throw new Error("A captura não pôde ser processada. Tire uma nova foto.");
    }

    const outputCanvas = document.createElement("canvas");
    outputCanvas.width = outputSize;
    outputCanvas.height = outputSize;

    const outputContext = outputCanvas.getContext("2d");
    if (!outputContext) {
        throw new Error("Canvas 2D indisponível.");
    }

    outputContext.fillStyle = "#ffffff";
    outputContext.fillRect(0, 0, outputSize, outputSize);
    outputContext.drawImage(cropCanvas, 0, 0);

    const result = outputCanvas.toDataURL("image/jpeg", jpegQuality);
    if (!result || result === "data:,") {
        throw new Error("Não foi possível gerar a imagem cortada.");
    }

    return result;
}
