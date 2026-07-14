import { EndRegisterForm, MitigationSuspectForm, PageHeader, SuspectInfoRecordForm } from "@/components";
import { PenalCodesForm } from "@/components/penalCodesForm";
import { useNuiEvent } from "@/hooks";
import { debugData, fetchNui, getCroppedImageDataUrl, getCropPixelsForExport, isEnvBrowser, randomAvatar } from "@/utils";
import clsx from "clsx";
import { AnimatePresence, motion } from "framer-motion";
import { Fragment, useCallback, useEffect, useMemo, useRef, useState } from "react";
import Cropper from "react-easy-crop";
import type { Area, MediaSize, Size } from "react-easy-crop";
import "react-easy-crop/react-easy-crop.css";
import { useLocation, useSearchParams } from "react-router-dom";

import { useCrimesProvider } from "@/providers/crimesProvider";
import { toast } from "sonner";
const FormStep = ({ index, title, isActive }: { index: number, title?: string, isActive?: boolean }) => {
    return (
        <div className={clsx(isActive && "!opacity-100", "flex items-center gap-4 transition-opacity opacity-45 duration-300")}>
            <div className="size-12 aspect-square rounded-full border-[.1rem] border-solid border-white fullCenter">
                <span className="text-white text-2xl font-normal">{index}</span>
            </div>

            <span className="text-white text-2xl font-normal capitalize">{title}</span>
        </div>
    )
}

export default function ToRegister() {
    const [id, setUserId] = useState("");
    const [suspectName, setSuspectName] = useState("")
    const [description, setDescription] = useState<string>("");
    const [formStep, setFormStep] = useState(1);
    const { crimes, attenuants, aggravants } = useCrimesProvider();
    const [selectedCrimes, setSelectedCrimes] = useState<string[]>([])
    const [selectedAttenuants, setSelectedAttenuants] = useState<string[]>([])
    const [selectedAggravants, setSelectedAggravants] = useState<string[]>([])
    const [photoURL, setPhotoURL] = useState<string | null>(null)
    const [finalPhotoURL, setFinalPhotoURL] = useState<string | null>(null)
    const [toPhotoScreen, setToPhotoScreen] = useState<boolean>(false);
    const [searchParams, setSearchParams] = useSearchParams();
    const location = useLocation();

    useEffect(() => {
        const state = location.state as {
            prefillSuspect?: {
                id?: string;
                name?: string;
                avatarURL?: string | null;
            };
            startStep?: number;
        } | null;

        const prefill = state?.prefillSuspect;
        if (!prefill) return;

        if (prefill.id) setUserId(String(prefill.id));
        if (prefill.name) setSuspectName(prefill.name);
        if (prefill.avatarURL) {
            // Foto opcional no resumo (não abre crop automaticamente).
            setFinalPhotoURL(prefill.avatarURL);
        }
        if (state?.startStep && Number.isFinite(state.startStep)) {
            setFormStep(Math.max(1, Math.min(4, state.startStep)));
        }
    }, [location.state]);


    const [crop, setCrop] = useState({ x: 0, y: 0 })
    const [zoom, setZoom] = useState(1)
    const [croppedAreaPixels, setCroppedAreaPixels] = useState<Area | null>(null)
    /** Força remount do Cropper a cada nova captura (evita overlay/refs alinhados à foto anterior). */
    const [cropSessionId, setCropSessionId] = useState(0)
    /** react-easy-crop chama `onCropAreaChange` a cada mudança de crop; `onCropComplete` nem sempre. O ref evita estado React defasado ao confirmar. */
    const croppedAreaPixelsRef = useRef<Area | null>(null);
    const mediaSizeRef = useRef<MediaSize | null>(null);
    const cropSizeRef = useRef<Size | null>(null);
    const cropperImageRef = useRef<HTMLImageElement | null>(null);

    const syncCropPixels = useCallback((_: Area, pixels: Area) => {
        croppedAreaPixelsRef.current = pixels;
        setCroppedAreaPixels(pixels);
    }, []);


    const penaltyCalculation = useMemo(() => {
        if (formStep !== 4) return null;

        // 1. filtra crimes selecionados
        const selectedCrimesList = crimes.filter(c =>
            selectedCrimes.includes(c.id)
        )

        // 2. soma base
        const baseMonths = selectedCrimesList.reduce((acc, c) => acc + c.sentence, 0)
        const baseFine = selectedCrimesList.reduce((acc, c) => acc + c.fine, 0)

        // 3. soma % atenuantes
        const attenuantPercent = attenuants
            .filter(a => selectedAttenuants.includes(a.id))
            .reduce((acc, a) => acc + a.percentage, 0)

        // 4. soma % agravantes
        const aggravantPercent = aggravants
            .filter(a => selectedAggravants.includes(a.id))
            .reduce((acc, a) => acc + a.percentage, 0)

        // 5. cálculo final (% total)
        const finalMultiplier =
            1 + (aggravantPercent / 100) - (attenuantPercent / 100)

        const finalMonths = Math.max(0, Math.round(baseMonths * finalMultiplier))
        const finalFine = Math.max(0, Math.round(baseFine * finalMultiplier))

        return {
            baseMonths,
            baseFine,
            attenuantPercent,
            aggravantPercent,
            finalMonths,
            finalFine
        }
    }, [
        formStep,
        crimes,
        selectedCrimes,
        attenuants,
        selectedAttenuants,
        aggravants,
        selectedAggravants
    ]);

    const handleConfirmEditImage = async () => {
        if (!photoURL) {
            toast.error("Nenhuma imagem para processar.");
            return;
        }

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
        if (!pixels) {
            pixels = croppedAreaPixelsRef.current ?? croppedAreaPixels;
        }
        if (!pixels) {
            toast.error("Ajuste o enquadramento antes de confirmar.");
            return;
        }

        try {
            const croppedImage = await getCroppedImageDataUrl(photoURL, pixels, {
                imageElement: cropperImageRef.current,
            });
            setFinalPhotoURL(croppedImage);
            setToPhotoScreen(false);
        } catch (e) {
            toast.error((e as Error).message ?? "Erro ao gerar a imagem cortada.");
        }
    };

    const resetImageCropOptions = useCallback(() => {
        setCropSessionId((n) => n + 1);
        setCrop({ x: 0, y: 0 });
        setZoom(1);
        setCroppedAreaPixels(null);
        croppedAreaPixelsRef.current = null;
        mediaSizeRef.current = null;
        cropSizeRef.current = null;
        cropperImageRef.current = null;
    }, []);

    useNuiEvent(
        "setPictureForm",
        useCallback(
            (data: string) => {
                setSearchParams((prev) => {
                    const p = new URLSearchParams(prev);
                    p.delete("hidden");
                    return p;
                });
                setToPhotoScreen(true);
                resetImageCropOptions();
                setPhotoURL(data ?? null);
            },
            [resetImageCropOptions, setSearchParams]
        )
    );

    function toggleItem(
        id: string,
        list: string[],
        setList: React.Dispatch<React.SetStateAction<string[]>>
    ) {
        setList((prev) =>
            prev.includes(id)
                ? prev.filter((item) => item !== id) // remove
                : [...prev, id] // adiciona
        )

    };

    const onSelectCrime = (id: string) => {
        toggleItem(id, selectedCrimes, setSelectedCrimes)
    };

    const onSelectAttenuant = (id: string) => {
        toggleItem(id, selectedAttenuants, setSelectedAttenuants)
    };

    const onSelectAggravant = (id: string) => {
        toggleItem(id, selectedAggravants, setSelectedAggravants)
    };

    useEffect(() => {
        console.log(selectedAggravants, selectedAttenuants)
    }, [selectedAggravants, selectedAttenuants]);

    const formSteps = ["Acusado", "Crimes", "Atenuantes", "Resumo"];

    const onBack = () => {
        if (formStep === 1) {
            resetAll();
            return;
        };
        setFormStep(prev => Math.max(0, prev - 1));
    };

    const toPicture = async () => {
       try {
           // Antes de qualquer await: some o cropper para não zerar refs com <Cropper> ainda montado (quebra grades/overlay).
           setPhotoURL(null);
           await fetchNui("initPhotoPicture", {});
           const params = new URLSearchParams(searchParams);
           params.set("hidden", "true");
           setSearchParams(params);
           if (!isEnvBrowser()) return;
           setTimeout(() => {
               console.debug("debug")
               debugData([
                   {
                       "action": "setPictureForm",
                       data: randomAvatar()
                   }
               ])
           }, 1500);
       } catch (error) {
        toast.error("Erro ao iniciar a foto.");
       }
    };

    const resetAll = () => {
        setUserId("")
        setSuspectName("")
        setDescription("")
        setFinalPhotoURL(null)
        setFormStep(1)
        setSelectedCrimes([])
        setSelectedAttenuants([])
        setSelectedAggravants([])
        setPhotoURL(null)
        setToPhotoScreen(false)
        resetImageCropOptions();
    }

    const registerOccurrence = async () => {
        try {
            const response = await fetchNui<{ errorMessage?: string }>("registerOccurrence", {
                suspect: {
                    id: id,
                    description,
                },
                crimes: selectedCrimes,
                photo: finalPhotoURL,
                modifiers: {
                    attenuants: selectedAttenuants,
                    aggravants: selectedAggravants,
                },
            }, {
                // errorMessage: null
            })
            if (response.errorMessage) {
                return toast(response.errorMessage)
            };

            toast("Boletim criado com sucesso");
            resetAll();
        } catch (error) {
            toast("Erro na criação do boletim de ocorrência");
        }
    }



    const toNext = () => {
        if (formStep === 1 && !id || formStep === 2 && !selectedCrimes?.length) return;
        setFormStep(prev => Math.min(4, prev + 1))
        if (formStep === 3 && !photoURL) {
            setToPhotoScreen(true);
            // setTimeout(() => {
            //     setVisible(true)
            // }, 1000);
        }

        if (formStep > 3) {
            registerOccurrence();
        };
    };

    const buttonIsDisabled = useMemo(() => {
        switch (formStep) {
            case 1:
                return !id
                break;
            case 2:
                return !selectedCrimes.length
                break;
            default:
                break;
        }
    }, [formStep, id, selectedCrimes])

    return (
        <>
            <AnimatePresence key="occurrencyActions" mode="wait">
                {toPhotoScreen && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        transition={{
                            duration: 0.3,
                        }}

                        className="flex-1 flex w-full h-full bg-black/20 z-20 absolute fullCenter"
                    >
                        {/* <div ref={null} className="!p-9 default-box max-w-2xl w-full gap-4 flex-col flex">
                            <div className="space-y-2">
                                <h2 className="text-4xl font-bold">Fotografe o indivíduo</h2>
                                <p className="text-2xl mt-0.5 font-normal text-text-secondary">
                                    Tire uma foto nítida do rosto do criminoso.
                                </p>
                            </div>

                            <div className="mt-2 flex flex-col gap-6">
                                <button
                                    onClick={toPicture}
                                    type="button"
                                    className="mt-2.5 h-[3.7rem] w-full rounded-lg bg-[#6F88D8] hover:bg-[#7B93E0] transition-colors text-white text-2xl font-bold"
                                >
                                    Tirar foto
                                </button>
                            </div>
                        </div> */}
                        <div ref={null} className="!p-9 default-box max-w-3xl w-full gap-4 flex-col flex">
                            {photoURL ? (
                                <h2 className="text-4xl font-bold">{photoURL ? "Alterar foto" : "Tire uma foto nítida do rosto do criminoso."}</h2>
                            ) : (
                                <div className="space-y-2">
                                    <h2 className="text-4xl font-bold">Fotografe o indivíduo</h2>
                                    <p className="text-2xl mt-0.5 font-normal text-text-secondary">
                                        Tire uma foto nítida do rosto do criminoso.
                                    </p>
                                </div>
                            )}

                            {photoURL && (
                                <div className="w-full h-80 relative bg-black rounded-lg overflow-hidden">
                                    <Cropper
                                        key={cropSessionId}
                                        image={photoURL}
                                        crop={crop}
                                        zoom={zoom}
                                        aspect={1} // quadrado igual sua UI
                                        onCropChange={setCrop}
                                        onZoomChange={setZoom}
                                        onCropComplete={syncCropPixels}
                                        onCropAreaChange={syncCropPixels}
                                        onMediaLoaded={ms => {
                                            mediaSizeRef.current = ms;
                                        }}
                                        onCropSizeChange={size => {
                                            cropSizeRef.current = size;
                                        }}
                                        setImageRef={ref => {
                                            cropperImageRef.current = ref.current;
                                        }}
                                        mediaProps={{ crossOrigin: "anonymous" }}
                                        showGrid={true}
                                    />
                                </div>
                            )}
                            <div className="mt-2 flex flex-col gap-6">
                                <button
                                    onClick={photoURL ? handleConfirmEditImage : toPicture}
                                    type="button"
                                    className="mt-2.5 h-[3.7rem] w-full rounded-lg bg-[#6F88D8] hover:bg-[#7B93E0] transition-colors text-white text-2xl font-bold"
                                >
                                    {photoURL ? "Confirmar corte" : "Tirar foto"}
                                </button>
                            </div>
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>
            <div className="flex-1 pt-[3.3rem] px-[3.4rem] flex flex-col pb-[2.7rem] gap-5">
                <PageHeader
                    title="Boletim de ocorrência"
                    description="Realize a apreensão de indivíduos;"
                />

                <div className="w-full justify-between flex items-center">
                    {formSteps.map((title, index) => {
                        return <Fragment
                            key={index}
                        >
                            <FormStep
                                index={index + 1}
                                title={title}
                                isActive={index + 1 === formStep}
                            />

                            {index !== formSteps.length - 1 && (
                                <div className="w-[4.2rem] h-px bg-[#B9BBBE]/20" />
                            )}
                        </Fragment>
                    })}
                </div>
                <div className="flex-1 flex flex-col justify-between gap-6">
                    {formStep === 1 && <SuspectInfoRecordForm
                        id={id}
                        description={description}
                        setDescription={setDescription}
                        setId={setUserId}
                    />}
                    {formStep === 2 && <PenalCodesForm
                        crimes={crimes}
                        onSelectCrime={onSelectCrime}
                        selected={selectedCrimes}
                    />}
                    {formStep === 3 && <MitigationSuspectForm
                        attenuants={attenuants}
                        aggravants={aggravants}
                        onSelectAttenuant={onSelectAttenuant}
                        selectedAttenuants={selectedAttenuants}


                        selectedAggravants={selectedAggravants}
                        onSelectAggravant={onSelectAggravant}
                    />}
                    {formStep === 4 && <EndRegisterForm
                        photoURL={finalPhotoURL}
                        finalFine={penaltyCalculation?.finalFine}
                        totalMonth={penaltyCalculation?.finalMonths ?? 0}
                        suspect={{
                            id,
                            name: suspectName
                        }}
                    />}
                    <div className="w-full flex items-center justify-between h-12">
                        <button
                            onClick={onBack}
                            className="border-red-custom border-solid border-[.1rem] px-12 h-full cursor-pointer rounded-xl flex items-center justify-center"
                        >
                            <span className="text-red-custom text-2xl font-normal capitalize">
                                {formStep === 1 ? "Restaurar" : "Voltar"}
                            </span>
                        </button>

                        <div className="flex items-center justify-center gap-4 h-full">
                            {formStep === 4 && (
                                <button
                                    onClick={() => {
                                        setToPhotoScreen(true);
                                        setPhotoURL(null);
                                        resetImageCropOptions();
                                        void toPicture();
                                    }}
                                    disabled={!finalPhotoURL}
                                    className="bg-blue-custom disabled:!cursor-default disabled:!bg-blue-custom/90 disabled:opacity-55 px-12 h-full cursor-pointer rounded-xl flex items-center justify-center"
                                >
                                    <span className="text-white text-2xl font-bold capitalize">
                                        Alterar foto
                                    </span>
                                </button>
                            )}
                            <button
                                onClick={buttonIsDisabled ? void 0 : toNext}
                                disabled={buttonIsDisabled}
                                className="bg-blue-custom disabled:!cursor-default disabled:!bg-blue-custom/90 disabled:opacity-55 px-12 h-full cursor-pointer rounded-xl flex items-center justify-center"
                            >
                                <span className="text-white text-2xl font-bold capitalize">
                                    Avançar
                                </span>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </>
    )
}