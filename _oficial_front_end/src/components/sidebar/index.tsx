import defaultAvatar from "@/assets/defaultAvatar.png";
import { useUserSession } from "@/providers";
import { useNuiEvent } from "@/hooks";
import { debugData, fetchNui, getCroppedImageDataUrl, getCropPixelsForExport, isEnvBrowser } from "@/utils";
import clsx from "clsx";
import { AnimatePresence, motion } from "framer-motion";
import { type ChangeEvent, ReactNode, useCallback, useEffect, useMemo, useRef, useState } from "react";
import { Link, useLocation, useSearchParams } from "react-router-dom";
import { twMerge } from "tailwind-merge";
import { DashboardIcon, DataLineIcon, HandCuffsIcon, JamIcon, UsersIcon, CarIcon } from "../icons";
import Cropper from "react-easy-crop";
import type { Area, MediaSize, Size } from "react-easy-crop";
import "react-easy-crop/react-easy-crop.css";
import { toast } from "sonner";

const BookIcon = () => {
    return (
        <svg className="size-[1.5rem]" width="18" height="23" viewBox="0 0 18 23" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M0 19.7143V3.28571C0 2.41429 0.344804 1.57855 0.958559 0.962363C1.57231 0.346173 2.40475 0 3.27273 0H14.7273C15.5953 0 16.4277 0.346173 17.0414 0.962363C17.6552 1.57855 18 2.41429 18 3.28571V18.2768C18 18.658 17.8491 19.0237 17.5806 19.2933C17.3121 19.5628 16.9479 19.7143 16.5682 19.7143H1.63636C1.63636 20.15 1.80877 20.5679 2.11564 20.876C2.42252 21.1841 2.83874 21.3571 3.27273 21.3571H17.1818C17.3988 21.3571 17.6069 21.4437 17.7604 21.5977C17.9138 21.7518 18 21.9607 18 22.1786C18 22.3964 17.9138 22.6054 17.7604 22.7594C17.6069 22.9135 17.3988 23 17.1818 23H3.27273C2.40475 23 1.57231 22.6538 0.958559 22.0376C0.344804 21.4214 0 20.5857 0 19.7143ZM4.70455 3.28571C4.3248 3.28571 3.96061 3.43717 3.6921 3.70675C3.42358 3.97633 3.27273 4.34197 3.27273 4.72321V5.95536C3.27273 6.74886 3.91418 7.39286 4.70455 7.39286H13.2955C13.6752 7.39286 14.0394 7.24141 14.3079 6.97182C14.5764 6.70224 14.7273 6.33661 14.7273 5.95536V4.72321C14.7273 4.34197 14.5764 3.97633 14.3079 3.70675C14.0394 3.43717 13.6752 3.28571 13.2955 3.28571H4.70455Z" fill="white" fillOpacity="0.4" />
        </svg>
    )
}


type ISidebarTabs = Record<string, {
    content: string
    pathName?: string
    Icon?: ReactNode
}[]>

export function SideBar() {
    const [inChangeAvatar, setInChangeAvatar] = useState<boolean>(false);
    const wrapperContainerRef = useRef<HTMLDivElement>(null);
    const { data } = useUserSession();
    const { pathname } = useLocation();
    const [searchParams, setSearchParams] = useSearchParams();

    const [avatarUrlInput, setAvatarUrlInput] = useState("");
    const [avatarLoadFailed, setAvatarLoadFailed] = useState(false);
    const [isSavingAvatar, setIsSavingAvatar] = useState(false);

    const [crop, setCrop] = useState({ x: 0, y: 0 });
    const [zoom, setZoom] = useState(1);
    const [croppedAreaPixels, setCroppedAreaPixels] = useState<Area | null>(null);
    const [cropSessionId, setCropSessionId] = useState(0);
    const [avatarCropSize, setAvatarCropSize] = useState<Size>();
    const croppedAreaPixelsRef = useRef<Area | null>(null);
    const mediaSizeRef = useRef<MediaSize | null>(null);
    const cropSizeRef = useRef<Size | null>(null);
    const cropperImageRef = useRef<HTMLImageElement | null>(null);
    const cropContainerRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        setAvatarUrlInput(data?.avatarURL ?? "");
        setAvatarLoadFailed(false);
    }, [data?.avatarURL]);

    const syncCropPixels = useCallback((_: Area, pixels: Area) => {
        croppedAreaPixelsRef.current = pixels;
        setCroppedAreaPixels(pixels);
    }, []);

    const resetImageCropOptions = useCallback(() => {
        setCropSessionId((n: number) => n + 1);
        setCrop({ x: 0, y: 0 });
        setZoom(1);
        setCroppedAreaPixels(null);
        croppedAreaPixelsRef.current = null;
        mediaSizeRef.current = null;
        cropSizeRef.current = null;
        cropperImageRef.current = null;
    }, []);

    const isImageValid = useCallback((image: string) => {
        return new Promise<boolean>((resolve) => {
            const img = new Image();
            img.onload = () => resolve(true);
            img.onerror = () => resolve(false);
            img.src = image;
        });
    }, []);

    const saveAvatarByUrl = useCallback(
        async (url: string) => {
            const trimmed = url.trim();
            if (!trimmed) return;
            setIsSavingAvatar(true);
            try {
                const ok = await isImageValid(trimmed);
                if (!ok) return;
                await fetchNui("setAvatarURL", { avatarURL: trimmed });
            } finally {
                setIsSavingAvatar(false);
                setInChangeAvatar(false);
            }
        },
        [isImageValid]
    );

    const handleConfirmCropAvatar = useCallback(async () => {
        const imageSrc = (avatarUrlInput || data?.avatarURL || defaultAvatar) as string;

        const ms = mediaSizeRef.current;
        const cs = cropSizeRef.current;

        let pixels: Area | null = null;
        if (ms && cs && cs.width > 0 && cs.height > 0) {
            try {
                pixels = getCropPixelsForExport({
                    crop,
                    mediaSize: ms,
                    cropSize: cs,
                    aspect: 1,
                    zoom,
                    rotation: 0,
                    restrictPosition: true,
                });
            } catch {
                pixels = null;
            }
        }
        if (!pixels) pixels = croppedAreaPixelsRef.current ?? croppedAreaPixels;
        if (!pixels) return;

        setIsSavingAvatar(true);
        try {
            const croppedImage = await getCroppedImageDataUrl(imageSrc, pixels, { imageElement: cropperImageRef.current });
            await fetchNui("setAvatarURL", { avatarURL: croppedImage });
            setAvatarUrlInput(croppedImage);
            setInChangeAvatar(false);
        } catch (error) {
            toast.error((error as Error).message || "Não foi possível salvar a foto.");
        } finally {
            setIsSavingAvatar(false);
        }
    }, [avatarUrlInput, crop, croppedAreaPixels, data?.avatarURL, zoom]);

    const cameraDisabled = useMemo(() => isSavingAvatar, [isSavingAvatar]);

    const toAvatarPicture = useCallback(async () => {
        try {
            await fetchNui("initAvatarPicture", {});
            const params = new URLSearchParams(searchParams);
            params.set("hidden", "true");
            setSearchParams(params);
            if (!isEnvBrowser()) return;
            setTimeout(() => {
                debugData([
                    {
                        action: "setAvatarPictureForm",
                        data: `https://api.dicebear.com/8.x/bottts-neutral/svg?seed=${Math.random()}`,
                    },
                ]);
            }, 4000);
        } catch {
            // noop (toast opcional)
        }
    }, [searchParams, setSearchParams]);

    useNuiEvent(
        "setAvatarPictureForm",
        useCallback(
            (dataUrl: string) => {
                setSearchParams((prev: URLSearchParams) => {
                    const p = new URLSearchParams(prev);
                    p.delete("hidden");
                    return p;
                });
                setAvatarUrlInput(dataUrl ?? "");
                resetImageCropOptions();
                // void saveAvatarByUrl(dataUrl ?? "");
            },
            [resetImageCropOptions, saveAvatarByUrl, setSearchParams]
        )
    );

    useEffect(() => {
        if (!inChangeAvatar) return;

        const eventClick = (event: MouseEvent) => {
            const target = event.target as Node;

            if (
                wrapperContainerRef.current &&
                !wrapperContainerRef.current.contains(target)
            ) {
                setInChangeAvatar(false); // fecha o wrapper
            }
        };

        document.addEventListener("mousedown", eventClick);

        return () => document.removeEventListener("mousedown", eventClick);
    }, [inChangeAvatar]);

    useEffect(() => {
        if (!inChangeAvatar) return;
        resetImageCropOptions();
    }, [inChangeAvatar, resetImageCropOptions]);

    useEffect(() => {
        if (!inChangeAvatar) {
            setAvatarCropSize(undefined);
            return;
        }

        let firstFrame = 0;
        let secondFrame = 0;

        const measureCropArea = () => {
            const container = cropContainerRef.current;
            if (!container) return;

            const rect = container.getBoundingClientRect();
            const side = Math.floor(Math.min(rect.width, rect.height));
            if (side <= 0) return;

            setAvatarCropSize((current) => {
                if (current?.width === side && current.height === side) return current;
                return { width: side, height: side };
            });
        };

        firstFrame = window.requestAnimationFrame(() => {
            measureCropArea();
            secondFrame = window.requestAnimationFrame(measureCropArea);
        });

        const resizeObserver = typeof ResizeObserver !== "undefined"
            ? new ResizeObserver(measureCropArea)
            : null;

        if (cropContainerRef.current) resizeObserver?.observe(cropContainerRef.current);
        window.addEventListener("resize", measureCropArea);

        return () => {
            window.cancelAnimationFrame(firstFrame);
            window.cancelAnimationFrame(secondFrame);
            resizeObserver?.disconnect();
            window.removeEventListener("resize", measureCropArea);
        };
    }, [inChangeAvatar]);

    const tabs: ISidebarTabs = {
        "Geral": [
            {
                content: "Dashboard",
                pathName: "/",
                Icon: <DashboardIcon />
            },
            {
                content: "Comunicados",
                pathName: "/communications",
                Icon: <BookIcon />
            },
            {
                content: "Dados",
                pathName: "/data",
                Icon: <DataLineIcon />
            },
            {
                content: "Multar",
                pathName: "/fines",
                Icon: <CarIcon />
            },
            {
                content: "Boletim de ocorrência",
                pathName: "/toRegister",
                Icon: <HandCuffsIcon />
            },
            {
                content: "Registros",
                pathName: "/registers",
                Icon: <JamIcon />
            },
        ],
        "Administração": [
            {
                content: "Gerenciar Oficiais",
                pathName: "/officers",
                Icon: <UsersIcon />
            },
        ],
    };

    return (
        <>
            <AnimatePresence key="changeAvattarWrapper" mode="wait">
                {inChangeAvatar && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        transition={{
                            duration: 0.3,
                        }}

                        className="flex-1 flex w-full h-full bg-black/20 z-[3000] absolute fullCenter"
                    >
                        <div ref={wrapperContainerRef} className="!p-8 default-box w-[47.7rem] gap-4 flex-col flex">
                            <h2 className="text-3xl font-bold">Alterar foto de perfil</h2>

                            <div ref={cropContainerRef} className="w-full h-[18rem] relative bg-white/10 rounded-lg overflow-hidden">
                                <Cropper
                                    key={cropSessionId}
                                    image={avatarUrlInput || data?.avatarURL || defaultAvatar}
                                    crop={crop}
                                    zoom={zoom}
                                    aspect={1}
                                    cropSize={avatarCropSize}
                                    objectFit="contain"
                                    onCropChange={setCrop}
                                    onZoomChange={setZoom}
                                    onCropComplete={syncCropPixels}
                                    onCropAreaChange={syncCropPixels}
                                    onMediaLoaded={(ms: MediaSize) => {
                                        mediaSizeRef.current = ms;
                                    }}
                                    onCropSizeChange={(size: Size) => {
                                        cropSizeRef.current = size;
                                    }}
                                    setImageRef={(ref: { current: HTMLImageElement | null }) => {
                                        cropperImageRef.current = ref.current;
                                    }}
                                    mediaProps={{ crossOrigin: "anonymous" }}
                                    style={{
                                        containerStyle: {
                                            cursor: isSavingAvatar ? "default" : "grab",
                                            touchAction: "none",
                                        },
                                        cropAreaStyle: {
                                            pointerEvents: "none",
                                            border: "2px solid rgba(255, 255, 255, 0.8)",
                                        },
                                    }}
                                    classes={{
                                        cropAreaClassName: "mdt-avatar-crop-area",
                                    }}
                                    cropperProps={{
                                        "aria-label": "Arraste a foto para ajustar o enquadramento",
                                    }}
                                    showGrid={true}
                                />
                            </div>

                            <p className="text-sm text-text-secondary">
                                Arraste a foto para os lados até ajustar o enquadramento.
                            </p>

                            {/* <div className="w-full flex items-center gap-4">
                                <span className="text-text-secondary text-sm min-w-14">Zoom</span>
                                <input
                                    type="range"
                                    min={1}
                                    max={3}
                                    step={0.01}
                                    value={zoom}
                                    onChange={(e: ChangeEvent<HTMLInputElement>) => setZoom(Number(e.target.value))}
                                    className="w-full"
                                    disabled={isSavingAvatar}
                                />
                            </div> */}

                            <div className="w-full flex items-center gap-3">
                                <div className="flex-1 h-12 bg-black/20 relative flex items-center rounded-lg">
                                    <input
                                        value={avatarUrlInput}
                                        onChange={(e: ChangeEvent<HTMLInputElement>) => setAvatarUrlInput(e.target.value)}
                                        className="w-full flex-1 h-full px-4 bg-transparent text-base text-text-secondary"
                                        spellCheck={false}
                                        placeholder="Cole o link da imagem"
                                        maxLength={500}
                                    />
                                </div>
                                <button
                                    type="button"
                                    disabled={cameraDisabled}
                                    onClick={() => void toAvatarPicture()}
                                    className="size-12 rounded-lg bg-white/10 hover:bg-white/15 transition-colors fullCenter disabled:opacity-50"
                                    aria-label="Fotografar pelo telefone"
                                >
                                    <svg className="size-7" width="30" height="30" viewBox="0 0 30 30" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden>
                                        <path d="M26.25 7.5H22.2875L20.7375 5.8125C20.5046 5.55674 20.2208 5.35238 19.9044 5.21248C19.588 5.07258 19.2459 5.00021 18.9 5H10.9C10.7542 5 10.6092 5.0125 10.4667 5.0375C10.2333 5.075 10.0125 5.15 9.8125 5.25C9.6 5.35 9.4125 5.4875 9.25 5.6625L7.7125 7.5H3.75C2.375 7.5 1.25 8.625 1.25 10V25C1.25 26.375 2.375 27.5 3.75 27.5H26.25C27.625 27.5 28.75 26.375 28.75 25V10C28.75 8.625 27.625 7.5 26.25 7.5ZM15 23.75C11.55 23.75 8.75 20.95 8.75 17.5C8.75 14.05 11.55 11.25 15 11.25C18.45 11.25 21.25 14.05 21.25 17.5C21.25 20.95 18.45 23.75 15 23.75Z" fill="white" />
                                    </svg>
                                </button>
                            </div>

                            <button
                                type="button"
                                disabled={isSavingAvatar}
                                onClick={() => void handleConfirmCropAvatar()}
                                className="h-12 w-full rounded-lg bg-blue-custom font-bold text-xl text-white disabled:opacity-50 disabled:cursor-default"
                            >
                                Confirmar corte
                            </button>
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>
            <div className="h-full w-[25.4rem] bg-[#202225] flex flex-col">
                <div className="w-full py-[1.9rem] border-b-[.2rem] border-0 border-solid border-white/10 flex items-center gap-6 px-[1.8rem]">

                    <div className="size-[8rem] aspect-square relative fullCenter group ">
                        <img
                            onClick={() => {
                                setInChangeAvatar(true);
                            }}
                            className="size-[8rem] pointer-events-auto transition-opacity group-hover:opacity-65 cursor-pointer aspect-square rounded"
                            src={avatarLoadFailed ? defaultAvatar : data?.avatarURL || defaultAvatar}
                            alt="Foto do oficial"
                            onError={() => setAvatarLoadFailed(true)}
                        />


                        <svg className="absolute size-12 z-10 pointer-events-none block opacity-0 transition-opacity group-hover:opacity-100 duration-500" width="30" height="30" viewBox="0 0 30 30" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path d="M3.75 10C3.75 10.6875 4.3125 11.25 5 11.25C5.6875 11.25 6.25 10.6875 6.25 10V7.5H8.75C9.4375 7.5 10 6.9375 10 6.25C10 5.5625 9.4375 5 8.75 5H6.25V2.5C6.25 1.8125 5.6875 1.25 5 1.25C4.3125 1.25 3.75 1.8125 3.75 2.5V5H1.25C0.5625 5 0 5.5625 0 6.25C0 6.9375 0.5625 7.5 1.25 7.5H3.75V10Z" fill="white" />
                            <path d="M16.25 21.25C18.3211 21.25 20 19.5711 20 17.5C20 15.4289 18.3211 13.75 16.25 13.75C14.1789 13.75 12.5 15.4289 12.5 17.5C12.5 19.5711 14.1789 21.25 16.25 21.25Z" fill="white" />
                            <path d="M26.25 7.5H22.2875L20.7375 5.8125C20.5046 5.55674 20.2208 5.35238 19.9044 5.21248C19.588 5.07258 19.2459 5.00021 18.9 5H10.9C11.1125 5.375 11.25 5.7875 11.25 6.25C11.25 7.625 10.125 8.75 8.75 8.75H7.5V10C7.5 11.375 6.375 12.5 5 12.5C4.5375 12.5 4.125 12.3625 3.75 12.15V25C3.75 26.375 4.875 27.5 6.25 27.5H26.25C27.625 27.5 28.75 26.375 28.75 25V10C28.75 8.625 27.625 7.5 26.25 7.5ZM16.25 23.75C12.8 23.75 10 20.95 10 17.5C10 14.05 12.8 11.25 16.25 11.25C19.7 11.25 22.5 14.05 22.5 17.5C22.5 20.95 19.7 23.75 16.25 23.75Z" fill="white" />
                        </svg>
                    </div>


                    <div className="flex flex-col gap-1.5">
                        <h3 className="text-[1.6rem] text-nowrap truncate max-w-48">{data?.name ?? "---"}</h3>
                        <h3 className="text-[1.4rem] text-text-secondary">{data?.policeRank ?? "--"}</h3>
                        <div className="w-full flex items-center gap-3">
                            <span className={twMerge(clsx(data?.inService ? "bg-[#3BA55D]" : "bg-red-500", "size-3 rounded-full"))} />
                            <h3 className="text-[1.4rem] text-text-secondary">{data?.inService ? "Em serviço" : "Fora de serviço"}</h3>
                        </div>
                    </div>
                </div>

                <div className="flex-1 py-[1.9rem] px-[1.8rem] flex flex-col gap-6">
                    {Object.entries(tabs).map(([k, v], i) => {
                        return (
                            <div
                                key={i}
                                className="flex flex-col"
                            >
                                <h2 className="text-text-secondary font-bold text-[1.2rem]">
                                    {k}
                                </h2>

                                <div className="flex flex-col gap-3 mt-[.7rem]">
                                    {v.map(({ content, pathName, Icon }, i) => {
                                        const isActive = !!pathName && pathname === pathName;

                                        return (
                                            <Link
                                                key={i}
                                                to={pathName ?? "#"}
                                                className={"flex items-center gap-6 group"}
                                            >
                                                <span className={clsx(
                                                    "size-[2.5rem] rounded-lg aspect-square transition-all fullCenter",
                                                    isActive ? "bg-white/15" : "bg-white/10 group-hover:bg-white/15"
                                                )} >
                                                    {Icon}
                                                </span>
                                                <p
                                                    className={clsx(
                                                        "text-[1.4rem] transition-colors",
                                                        isActive ? "text-white" : "text-text-secondary group-hover:text-white"
                                                    )}
                                                >
                                                    {content}
                                                </p>
                                            </Link>
                                        );
                                    })}
                                </div>
                            </div>
                        );
                    })}
                </div>
            </div>
        </>
    )
};
