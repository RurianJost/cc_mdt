import { PageHeader } from "@/components";
import { useNuiEvent } from "@/hooks";
import { debugData, fetchNui, formatCurrencyBRL, getCroppedImageDataUrl, getCropPixelsForExport, isEnvBrowser, randomAvatar } from "@/utils";
import clsx from "clsx";
import { AnimatePresence, motion } from "framer-motion";
import { Fragment, useCallback, useEffect, useMemo, useRef, useState } from "react";
import Cropper from "react-easy-crop";
import type { Area, MediaSize, Size } from "react-easy-crop";
import "react-easy-crop/react-easy-crop.css";
import { toast } from "sonner";
import { useLocation, useSearchParams } from "react-router-dom";

type FineItem = {
  id: number;
  article: string;
  description: string;
  value: number;
};

const FormStep = ({ index, title, isActive }: { index: number; title?: string; isActive?: boolean }) => {
  return (
    <div className={clsx(isActive && "!opacity-100", "flex items-center gap-4 transition-opacity opacity-45 duration-300")}>
      <div className="size-12 aspect-square rounded-full border-[.1rem] border-solid border-white fullCenter">
        <span className="text-white text-2xl font-normal">{index}</span>
      </div>
      <span className="text-white text-2xl font-normal capitalize">{title}</span>
    </div>
  );
};

function clamp(n: number, min: number, max: number) {
  return Math.max(min, Math.min(max, n));
}

export default function Fines() {
  const [plate, setPlate] = useState("");
  const [reason, setReason] = useState("");

  const [formStep, setFormStep] = useState(1);
  const formSteps = ["Veículo", "Motivos", "Resumo"];

  const [fines, setFines] = useState<FineItem[]>([]);
  const [selectedFineIds, setSelectedFineIds] = useState<number[]>([]);

  const [fineValue, setFineValue] = useState(0);

  const [photoURL, setPhotoURL] = useState<string | null>(null);
  const [finalPhotoURL, setFinalPhotoURL] = useState<string | null>(null);
  const [toPhotoScreen, setToPhotoScreen] = useState(false);

  const [searchParams, setSearchParams] = useSearchParams();
  const location = useLocation();

  const [crop, setCrop] = useState({ x: 0, y: 0 });
  const [zoom, setZoom] = useState(1);
  const [croppedAreaPixels, setCroppedAreaPixels] = useState<Area | null>(null);
  const [cropSessionId, setCropSessionId] = useState(0);
  const croppedAreaPixelsRef = useRef<Area | null>(null);
  const mediaSizeRef = useRef<MediaSize | null>(null);
  const cropSizeRef = useRef<Size | null>(null);
  const cropperImageRef = useRef<HTMLImageElement | null>(null);

  const syncCropPixels = useCallback((_: Area, pixels: Area) => {
    croppedAreaPixelsRef.current = pixels;
    setCroppedAreaPixels(pixels);
  }, []);

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

  const loadFines = useCallback(async () => {
    const response = await fetchNui<{ fines?: FineItem[] }>(
      "getFines",
      {},
      {
        fines: [
          { id: 1, article: "I", description: "Estacionamento irregular", value: 5000 },
          { id: 2, article: "II", description: "Excesso de velocidade", value: 15000 },
          { id: 3, article: "III", description: "Direção perigosa", value: 12000 },
          { id: 4, article: "IV", description: "Avançar sinal vermelho", value: 8000 },
          { id: 5, article: "V", description: "Ultrapassagem proibida", value: 9000 },
          { id: 6, article: "VI", description: "Conduzir na contramão", value: 11000 },
          { id: 7, article: "VII", description: "Não usar cinto de segurança", value: 4500 },
          { id: 8, article: "VIII", description: "Uso de celular ao volante", value: 7000 },
          { id: 9, article: "IX", description: "Farol desligado à noite", value: 3500 },
          { id: 10, article: "X", description: "Som alto/perturbação", value: 6000 },
          { id: 11, article: "XI", description: "Dirigir sem habilitação", value: 20000 },
          { id: 12, article: "XII", description: "Veículo irregular (documentação)", value: 10000 },
          { id: 13, article: "XIII", description: "Placa ilegível/ausente", value: 7500 },
          { id: 14, article: "XIV", description: "Furto de veículo (suspeita)", value: 25000 },
          { id: 15, article: "XV", description: "Recusar abordagem policial", value: 16000 },
          { id: 16, article: "XVI", description: "Fuga de blitz", value: 22000 },
          { id: 17, article: "XVII", description: "Dano ao patrimônio público", value: 18000 },
          { id: 18, article: "XVIII", description: "Condução perigosa em alta velocidade", value: 24000 },
          { id: 19, article: "XIX", description: "Batida e evasão", value: 13000 },
          { id: 20, article: "XX", description: "Dirigir embriagado", value: 30000 },
          { id: 21, article: "XXI", description: "Corrida ilegal", value: 28000 },
          { id: 22, article: "XXII", description: "Circular em área proibida", value: 6500 },
          { id: 23, article: "XXIII", description: "Veículo com danos severos em via pública", value: 5500 },
          { id: 24, article: "XXIV", description: "Sem capacete (motocicleta)", value: 5000 },
          { id: 25, article: "XXV", description: "Transitar na calçada", value: 4000 },
        ],
      },
      600
    );
    setFines(response?.fines ?? []);
  }, []);

  useEffect(() => {
    void loadFines();
  }, [loadFines]);

  useEffect(() => {
    const state = location.state as
      | {
        prefillVehicle?: { plate?: string; reason?: string };
        startStep?: number;
      }
      | null;

    if (!state) return;

    const prefill = state.prefillVehicle;
    if (prefill?.plate) setPlate(String(prefill.plate).toUpperCase());
    if (prefill?.reason !== undefined) setReason(prefill.reason ?? "");

    if (state.startStep && Number.isFinite(state.startStep)) {
      setFormStep(Math.max(1, Math.min(3, state.startStep)));
    }
  }, [location.state]);

  const selectedFines = useMemo(() => {
    const set = new Set(selectedFineIds);
    return fines.filter((f) => set.has(f.id));
  }, [fines, selectedFineIds]);

  const minFineValue = useMemo(() => {
    if (!selectedFines.length) return 0;
    return Math.min(...selectedFines.map((f) => f.value ?? 0));
  }, [selectedFines]);

  const maxFineValue = useMemo(() => {
    if (!selectedFines.length) return 0;
    return selectedFines.reduce((acc, f) => acc + (f.value ?? 0), 0);
  }, [selectedFines]);

  const sliderMin = minFineValue || 0;
  const sliderMax = maxFineValue || 0;
  const sliderValue = selectedFineIds.length ? fineValue : 0;
  const sliderPct = useMemo(() => {
    const range = sliderMax - sliderMin;
    if (range <= 0) return 0;
    return clamp(((sliderValue - sliderMin) / range) * 100, 0, 100);
  }, [sliderMax, sliderMin, sliderValue]);

  const suggestedValue = useMemo(() => {
    if (!selectedFines.length) return 0;
    return selectedFines.reduce((acc, f) => acc + (f.value ?? 0), 0);
  }, [selectedFines]);

  useEffect(() => {
    if (!selectedFineIds.length) {
      setFineValue(0);
      return;
    }
    const min = minFineValue || 0;
    const max = maxFineValue || 0;
    const next = clamp(suggestedValue, min, max);
    setFineValue(next);
  }, [minFineValue, maxFineValue, suggestedValue, selectedFineIds.length]);

  const toggleFine = (id: number) => {
    setSelectedFineIds((prev) => (prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]));
  };

  const toVehiclePicture = async () => {
    try {
      setPhotoURL(null);
      await fetchNui("initVehiclePicture", {});
      const params = new URLSearchParams(searchParams);
      params.set("hidden", "true");
      setSearchParams(params);
      if (!isEnvBrowser()) return;
      setTimeout(() => {
        debugData([
          {
            action: "setVehiclePictureForm",
            data: randomAvatar(),
          },
        ]);
      }, 4000);
    } catch {
      toast.error("Erro ao iniciar a foto.");
    }
  };

  useNuiEvent(
    "setVehiclePictureForm",
    useCallback(
      (data: string) => {
        const params = new URLSearchParams(searchParams);
        params.delete("hidden");
        setSearchParams(params);
        setToPhotoScreen(true);
        resetImageCropOptions();
        setPhotoURL(data ?? null);
      },
      [resetImageCropOptions, setSearchParams]
    )
  );

  const handleConfirmEditImage = useCallback(async () => {
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
    if (!pixels) pixels = croppedAreaPixelsRef.current ?? croppedAreaPixels;
    if (!pixels) {
      toast.error("Ajuste o enquadramento antes de confirmar.");
      return;
    }

    try {
      const croppedImage = await getCroppedImageDataUrl(photoURL, pixels, { imageElement: cropperImageRef.current });
      setFinalPhotoURL(croppedImage);
      setToPhotoScreen(false);
    } catch (e) {
      toast.error((e as Error).message ?? "Erro ao gerar a imagem cortada.");
    }
  }, [crop, croppedAreaPixels, photoURL, zoom]);

  const buttonIsDisabled = useMemo(() => {
    if (formStep === 1) return !plate.trim();
    if (formStep === 2) return selectedFineIds.length === 0;
    return false;
  }, [formStep, plate, selectedFineIds.length]);

  const onBack = () => {
    if (formStep === 1) {
      setPlate("");
      setReason("");
      setSelectedFineIds([]);
      setFineValue(0);
      setPhotoURL(null);
      setFinalPhotoURL(null);
      setToPhotoScreen(false);
      resetImageCropOptions();
      return;
    }
    setFormStep((prev) => Math.max(1, prev - 1));
  };

  const confirmFine = async () => {
    try {
      await fetchNui("applyVehicleFine", {
        vehiclePlate: plate.trim(),
        reason: reason.trim(),
        fines: selectedFines?.map((f) => f.id),
      });
      toast("Multa aplicada com sucesso.");
      onBack(); // reset
    } catch {
      toast("Erro ao aplicar multa.");
    }
  };

  const toNext = () => {
    if (buttonIsDisabled) return;
    if (formStep >= 3) {
      void confirmFine();
      return;
    }
    setFormStep((prev) => Math.min(3, prev + 1));
  };

  useEffect(() => {
    if (formStep !== 3) return;
    if (finalPhotoURL) return;
    if (toPhotoScreen) return;
    setToPhotoScreen(true);
    setPhotoURL(null);
    resetImageCropOptions();
    void toVehiclePicture();
  }, [finalPhotoURL, formStep, resetImageCropOptions, toPhotoScreen]);

  return (
    <>
      <AnimatePresence key="finePhotoCropper" mode="wait">
        {toPhotoScreen && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.3 }}
            className="flex-1 flex w-full h-full bg-black/20 z-20 absolute fullCenter"
          >
            <div className="!p-9 default-box max-w-3xl w-full gap-4 flex-col flex">
              {photoURL ? (
                <h2 className="text-4xl font-bold">Ajustar foto do veículo</h2>
              ) : (
                <div className="space-y-2">
                  <h2 className="text-4xl font-bold">Fotografe o veículo</h2>
                  <p className="text-2xl mt-0.5 font-normal text-text-secondary">
                    Tire uma foto nítida do veículo.
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
                    aspect={1}
                    onCropChange={setCrop}
                    onZoomChange={setZoom}
                    onCropComplete={syncCropPixels}
                    onCropAreaChange={syncCropPixels}
                    onMediaLoaded={(ms) => {
                      mediaSizeRef.current = ms;
                    }}
                    onCropSizeChange={(size) => {
                      cropSizeRef.current = size;
                    }}
                    setImageRef={(ref) => {
                      cropperImageRef.current = ref.current;
                    }}
                    mediaProps={{ crossOrigin: "anonymous" }}
                    showGrid={true}
                  />
                </div>
              )}

              <div className="mt-2 flex flex-col gap-4">
                {!photoURL ? (
                  <button
                    onClick={() => void toVehiclePicture()}
                    type="button"
                    className="h-[3.7rem] w-full rounded-lg bg-[#6F88D8] hover:bg-[#7B93E0] transition-colors text-white text-2xl font-bold"
                  >
                    Tirar foto
                  </button>
                ) : (
                  <button
                    onClick={() => void handleConfirmEditImage()}
                    type="button"
                    className="h-[3.7rem] w-full rounded-lg bg-[#6F88D8] hover:bg-[#7B93E0] transition-colors text-white text-2xl font-bold"
                  >
                    Confirmar corte
                  </button>
                )}

                {/* <button
                  type="button"
                  onClick={() => setToPhotoScreen(false)}
                  className="h-12 w-full rounded-lg border-[.15rem] bg-white/5 border-white/20 font-bold text-lg text-white/90 hover:bg-white/10 transition-colors"
                >
                  Voltar
                </button> */}
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      <div className="flex-1 pt-[3.3rem] px-[3.4rem] flex flex-col pb-[2.7rem] gap-5 min-h-0">
        <PageHeader title="Multar" description="Registre uma infração e aplique multa ao veículo;" />

        <div className="w-full justify-between flex items-center">
          {formSteps.map((title, index) => (
            <Fragment key={index}>
              <FormStep index={index + 1} title={title} isActive={index + 1 === formStep} />
              {index !== formSteps.length - 1 && <div className="w-[10.2rem] h-px bg-[#B9BBBE]/20" />}
            </Fragment>
          ))}
        </div>

        <div className="flex-1 flex flex-col justify-between gap-6 min-h-0">
          {formStep === 1 && (
            <>
              <div className="w-full default-box !px-6 flex flex-col gap-3">
                <h2 className="text-white text-2xl font-bold">Placa</h2>
                <div className="h-12 bg-black/20 relative flex items-center rounded-lg">
                  <input
                    value={plate}
                    onChange={(e) =>
                      setPlate(e.target.value.toUpperCase().replace(/[^A-Z0-9]/g, "").slice(0, 10))
                    }
                    className="w-full flex-1 h-full font-normal text-base px-4 pr-12 bg-transparent text-text-secondary"
                    spellCheck={false}
                    type="text"
                    placeholder="Digite a placa"
                    maxLength={10}
                  />
                </div>
              </div>

              <div className="w-full default-box !px-6 !pb-6 flex flex-col gap-3 flex-1 min-h-0">
                <h2 className="text-white text-2xl font-bold">Descreva o motivo</h2>
                <div className="flex-1 bg-black/20 relative rounded-lg min-h-[10rem]">
                  <textarea
                    className="w-full h-full p-4 bg-transparent font-normal text-base text-text-secondary resize-none outline-none"
                    spellCheck={false}
                    value={reason}
                    onChange={(e) => setReason(e.target.value ?? "")}
                    maxLength={255}
                    placeholder="Descreva o motivo da multa"
                  />
                </div>
              </div>
            </>
          )}

          {formStep === 2 && (
            <div className="default-box flex-1 !p-6 flex flex-col gap-4 min-h-0">
              <h2 className="text-white text-xl font-bold">
                Multas<span className="text-red-500 ml-2">*</span>
              </h2>

              <div className="grid grid-cols-[4rem_8rem_1fr_12rem] text-text-secondary text-base">
                <div />
                <span>Artigo</span>
                <span>Descrição</span>
                <span>Multa</span>
              </div>

              <div className="flex-1 min-h-0 overflow-y-auto w-full overflow-x-hidden pr-2">
                <div className="flex flex-col gap-3">
                  {fines.map((fine) => (
                    <div
                      onClick={() => toggleFine(fine.id)}
                      key={fine.id}
                      className="!grid !cursor-default grid-cols-[4rem_8rem_1fr_12rem] text-base items-center text-white"
                    >
                      <input
                        type="checkbox"
                        checked={selectedFineIds.includes(fine.id)}
                        onChange={() => toggleFine(fine.id)}
                        onClick={(e) => e.stopPropagation()}
                        className="custom-checkbox"
                      />
                      <span className="capitalize">{fine.article}</span>
                      <span className="truncate">{fine.description}</span>
                      <span>{formatCurrencyBRL(fine.value ?? 0)}</span>
                    </div>
                  ))}
                </div>
              </div>

              <div className="bg-black/20 rounded-xl p-4 mt-auto">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-text-secondary text-sm">Valor da multa</span>
                  <span className="text-white text-xl font-bold">
                    {formatCurrencyBRL(selectedFineIds.length ? fineValue : 0)}
                  </span>
                </div>
                <input
                  type="range"
                  min={sliderMin}
                  max={sliderMax}
                  value={sliderValue}
                  onChange={(e) => setFineValue(Number(e.target.value))}
                  disabled={!selectedFineIds.length}
                  className={clsx(
                    "w-full mdt-range",
                    !selectedFineIds.length && "opacity-50 cursor-not-allowed"
                  )}
                  style={{
                    background: `linear-gradient(to right, rgba(111,136,216,0.85) 0%, rgba(111,136,216,0.85) ${sliderPct}%, rgba(255,255,255,0.12) ${sliderPct}%, rgba(255,255,255,0.12) 100%)`,
                  }}
                />
                <div className="flex items-center justify-between mt-2 text-xs text-text-secondary">
                  <span>{formatCurrencyBRL(minFineValue || 0)}</span>
                  <span>{formatCurrencyBRL(maxFineValue || 0)}</span>
                </div>
              </div>
            </div>
          )}

          {formStep === 3 && (
            <div className="w-full default-box !px-6 !flex-1 flex flex-col gap-3">
              <h2 className="text-white text-2xl font-bold">Resumo</h2>
              <div className="flex flex-col items-center flex-1">
                <div className="w-52 h-52 border border-white/30 rounded-md flex items-center justify-center overflow-hidden bg-black/20">
                  {finalPhotoURL ? (
                    <img src={finalPhotoURL} alt="Foto do veículo" className="w-full h-full object-cover rounded-md" />
                  ) : (
                    <span className="text-text-secondary text-sm">Sem foto</span>
                  )}
                </div>

                <div className="flex-1 w-full flex items-center justify-around">
                  <div className="flex flex-col fullCenter">
                    <span className="text-gray-400 text-sm">Placa</span>
                    <span className="text-white text-2xl font-semibold uppercase">{plate}</span>
                  </div>
                  <div className="flex flex-col fullCenter">
                    <span className="text-gray-400 text-sm">Multa</span>
                    <span className="text-white text-2xl font-semibold">{formatCurrencyBRL(fineValue)}</span>
                  </div>
                </div>
              </div>
            </div>
          )}

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
              {formStep === 3 && (
                <button
                  onClick={() => {
                    setToPhotoScreen(true);
                    setPhotoURL(null);
                    resetImageCropOptions();
                    void toVehiclePicture();
                  }}
                  disabled={!finalPhotoURL}
                  className="bg-blue-custom disabled:!cursor-default disabled:!bg-blue-custom/90 disabled:opacity-55 px-12 h-full cursor-pointer rounded-xl flex items-center justify-center"
                >
                  <span className="text-white text-2xl font-bold capitalize">Alterar foto</span>
                </button>
              )}

              <button
                onClick={buttonIsDisabled ? void 0 : toNext}
                disabled={buttonIsDisabled}
                className="bg-blue-custom disabled:!cursor-default disabled:!bg-blue-custom/90 disabled:opacity-55 px-12 h-full cursor-pointer rounded-xl flex items-center justify-center"
              >
                <span className="text-white text-2xl font-bold capitalize">
                  {formStep === 3 ? "Confirmar" : "Avançar"}
                </span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

