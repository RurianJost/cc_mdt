/** Retângulo em pixels no bitmap natural (ex.: `croppedAreaPixels` do react-easy-crop). */
export type NaturalPixelCrop = {
    x: number;
    y: number;
    width: number;
    height: number;
};

export function loadImageForCrop(src: string): Promise<HTMLImageElement> {
    return new Promise((resolve, reject) => {
        const img = new Image();
        img.crossOrigin = "anonymous";
        img.onload = () => resolve(img);
        img.onerror = () => reject(new Error("Falha ao carregar a imagem"));
        img.src = src;
    });
}

/** `drawImage` + `toDataURL` só funcionam se a imagem não for cross-origin “sujo” (sem CORS). */
function isImageSafeForCanvas(img: HTMLImageElement): boolean {
    const src = img.currentSrc || img.src || "";
    if (src.startsWith("blob:") || src.startsWith("data:")) {
        return true;
    }
    try {
        const u = new URL(src, window.location.href);
        if (u.origin === window.location.origin) {
            return true;
        }
    } catch {
        return false;
    }
    return img.crossOrigin === "anonymous" || img.crossOrigin === "use-credentials";
}

/**
 * Recorta a região `crop` (coordenadas na imagem natural) e devolve JPEG em data URL.
 * Não altere canvas.width/height após criar o contexto sem redesenhar — defina antes do `getContext`.
 */
export async function getCroppedImageDataUrl(
    imageSrc: string,
    crop: NaturalPixelCrop,
    options?: { imageElement?: HTMLImageElement | null; jpegQuality?: number }
): Promise<string> {
    const jpegQuality = options?.jpegQuality ?? 0.92;
    const el = options?.imageElement;
    const useEl =
        el &&
        el.complete &&
        el.naturalWidth > 0 &&
        isImageSafeForCanvas(el);
    const image = useEl ? el : await loadImageForCrop(imageSrc);
    try {
        await image.decode();
    } catch {
        /* opcional */
    }

    const nw = image.naturalWidth;
    const nh = image.naturalHeight;
    if (!nw || !nh) {
        throw new Error("Imagem sem dimensões válidas");
    }

    let sx = Math.round(crop.x);
    let sy = Math.round(crop.y);
    let sw = Math.round(crop.width);
    let sh = Math.round(crop.height);

    sx = Math.max(0, sx);
    sy = Math.max(0, sy);
    sw = Math.max(1, sw);
    sh = Math.max(1, sh);

    sx = Math.min(sx, nw - 1);
    sy = Math.min(sy, nh - 1);
    sw = Math.min(sw, nw - sx);
    sh = Math.min(sh, nh - sy);

    if (sw < 1 || sh < 1) {
        throw new Error("Região de corte inválida");
    }

    const canvas = document.createElement("canvas");
    canvas.width = nw;
    canvas.height = nh;

    const ctx = canvas.getContext("2d");
    if (!ctx) {
        throw new Error("Canvas 2D indisponível");
    }

    ctx.imageSmoothingEnabled = true;
    ctx.imageSmoothingQuality = "high";

    ctx.fillStyle = "#ffffff";
    ctx.fillRect(0, 0,nw, nh);
    ctx.drawImage(image, sx, sy, sw, sh, 0, 0, nw, nh);

    return canvas.toDataURL("image/jpeg", jpegQuality);
}
