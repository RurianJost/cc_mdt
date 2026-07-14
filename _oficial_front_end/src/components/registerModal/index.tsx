import { IRegisterItem, ModifierPenalCodeItem, PenalCodeItem, SelectedCrimeDetailed } from "@/interfaces";
import { formatCurrencyBRL } from "@/utils";
import { AnimatePresence, motion } from "framer-motion";
import { useEffect, useRef, useState } from "react";

type RegisterModalProps = {
    isOpen: boolean;
    mode: "expanded" | "finish";
    selectedItem: (IRegisterItem & { index: number }) | null;
    crimes: PenalCodeItem[];
    attenuants: ModifierPenalCodeItem[];
    aggravants: ModifierPenalCodeItem[];
    onClose: () => void;
    onSave: () => void;
    onConfirmFinish: () => void;
    onRemoveCrime: (crime: SelectedCrimeDetailed, index: number) => void;
    onAddCrime: (crimeId: string) => void;
    onChangeDescription: (description: string) => void;
};

function findCrimeData(
    id: string,
    crimes: PenalCodeItem[],
    attenuants: ModifierPenalCodeItem[],
    aggravants: ModifierPenalCodeItem[]
) {
    const match = (e?: { id: string }) => e?.id === id;
    return crimes.find(match) || attenuants.find(match) || aggravants.find(match);
}

function crimeArticleLabel(crimeData: PenalCodeItem | ModifierPenalCodeItem): string {
    return "article" in crimeData ? crimeData.article : "I";
}

export function RegisterModal({
    isOpen,
    mode,
    selectedItem,
    crimes,
    attenuants,
    aggravants,
    onClose,
    onSave,
    onConfirmFinish,
    onRemoveCrime,
    onAddCrime,
    onChangeDescription,
}: RegisterModalProps) {
    const [isAddCrimeOpen, setIsAddCrimeOpen] = useState(false);
    const addCrimeRef = useRef<HTMLDivElement | null>(null);

    useEffect(() => {
        if (!isAddCrimeOpen) return;
        const onClick = (e: MouseEvent) => {
            const target = e.target as Node;
            if (addCrimeRef.current && !addCrimeRef.current.contains(target)) {
                setIsAddCrimeOpen(false);
            }
        };
        const onKey = (e: KeyboardEvent) => {
            if (e.key === "Escape") setIsAddCrimeOpen(false);
        };
        document.addEventListener("mousedown", onClick);
        window.addEventListener("keydown", onKey);
        return () => {
            document.removeEventListener("mousedown", onClick);
            window.removeEventListener("keydown", onKey);
        };
    }, [isAddCrimeOpen]);

    return (
        <AnimatePresence key="occurrencyActions" mode="wait">
            {isOpen && (
                <motion.div
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                    transition={{ duration: 0.3 }}
                    className="flex-1 flex w-full h-full bg-black/20 z-20 absolute fullCenter"
                >
                    {mode === "expanded" ? (
                        <div className="!p-9 !pt-6 default-box relative w-[53.9rem] gap-4 flex-col flex">
                            <h2 className="text-3xl font-bold">Geral</h2>

                            <button
                                type="button"
                                onClick={onClose}
                                className="size-8 absolute -right-3 -top-3 rounded-full bg-white/5 hover:bg-white/10 text-text-secondary hover:text-white transition-colors fullCenter"
                                aria-label="Limpar resultado e voltar para busca"
                            >
                                ✕
                            </button>

                            <div className="w-full flex items-center justify-between h-[17rem] gap-6">
                                <div className="flex-1 flex flex-col gap-2 justify-between h-full">
                                    {[
                                        { title: "Passaporte", value: selectedItem?.suspect.id },
                                        { title: "Nome", value: selectedItem?.suspect.name },
                                        { title: "Identidade", value: selectedItem?.suspect.identity },
                                    ].map((item, index) => (
                                        <div className="flex flex-col gap-2" key={index}>
                                            <h3 className="text-white/70 text-base font-normal">{item.title}:</h3>
                                            <div className=" w-full h-12 bg-black/20 relative flex  items-center rounded-lg">
                                                <input
                                                    className="w-full flex-1 h-full px-4 pr-12 bg-transparent text-xl text-text-secondary"
                                                    spellCheck={false}
                                                    maxLength={255}
                                                    value={item.value}
                                                    disabled
                                                />
                                            </div>
                                        </div>
                                    ))}
                                </div>
                                <div className="flex-1 flex flex-col w-full h-full gap-2">
                                    <h3 className="text-white/70 text-base font-normal">Descrição:</h3>
                                    <div className="flex-1 bg-black/20 relative rounded-lg">
                                        <textarea
                                            className="w-full h-full p-4 bg-transparent text-base text-text-secondary resize-none outline-none"
                                            spellCheck={false}
                                            value={selectedItem?.description ?? ""}
                                            onChange={(e) => onChangeDescription(e.target.value)}
                                            maxLength={255}
                                            placeholder="Descreva a aparência do indivíduo e ocorrência"
                                        />
                                    </div>
                                </div>
                            </div>

                            <div className="flex items-center justify-between mt-1 shrink-0 relative" ref={addCrimeRef}>
                                <h2 className="text-2xl font-bold">Crimes</h2>

                                <button
                                    type="button"
                                    onClick={() => setIsAddCrimeOpen((p) => !p)}
                                    className="h-9 rounded-lg px-4 bg-white/10 hover:bg-white/15 transition-colors text-white/90 text-base font-bold"
                                >
                                    Adicionar crime
                                </button>

                                {isAddCrimeOpen && (
                                    <div className="absolute right-0 top-full mt-3 w-[22rem] z-50 transition-all duration-300">
                                        <div className="bg-black/30 z-20 relative backdrop-blur-md border border-white/10 rounded-xl shadow-2xl p-4 ring-1 ring-white/10">
                                            <div className="h-48 overflow-y-auto overflow-x-hidden flex flex-col gap-2 pr-1">
                                                {crimes.map((crime) => (
                                                    <button
                                                        key={crime.id}
                                                        type="button"
                                                        className="text-left bg-white/10 py-1.5 text-base px-3 rounded-md text-white/90 hover:bg-white/10 hover:text-white focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/20 transition-colors"
                                                        onClick={() => {
                                                            onAddCrime(crime.id);
                                                            setIsAddCrimeOpen(false);
                                                        }}
                                                    >
                                                        <span className="text-blue-custom font-semibold mr-2">
                                                            {crime.article}.
                                                        </span>
                                                        <span className="capitalize">{crime.description}</span>
                                                    </button>
                                                ))}
                                            </div>
                                        </div>
                                    </div>
                                )}
                            </div>

                            <div className="flex flex-col w-full gap-2 max-h-[12.4rem] min-h-0 overflow-y-auto overscroll-y-contain pr-1">
                                {selectedItem?.crimes.map((crime, index) => {
                                    const crimeData = findCrimeData(crime.id, crimes, attenuants, aggravants);
                                    if (!crimeData) return null;
                                    return (
                                        <div
                                            key={index}
                                            className="w-full bg-black/20 py-3 rounded-lg flex items-center justify-between px-4"
                                        >
                                            <div className="flex items-center gap-1">
                                                <p className="text-2xl font-medium text-blue-custom">
                                                    {crimeArticleLabel(crimeData)}.
                                                </p>
                                                <p className="text-xl font-normal capitalize">{crimeData.description}</p>
                                            </div>

                                            {selectedItem.crimes.length > 1 && (
                                                <button
                                                    onClick={() => onRemoveCrime(crime, index)}
                                                    type="button"
                                                    className="size-8 rounded-full bg-white/5 hover:bg-white/10 text-text-secondary hover:text-white transition-colors fullCenter"
                                                    aria-label="Limpar resultado e voltar para busca"
                                                >
                                                    ✕
                                                </button>
                                            )}
                                        </div>
                                    );
                                })}
                            </div>

                            <button
                                type="button"
                                onClick={onSave}
                                className="mt-2.5 h-12 w-full rounded-lg bg-[#6F88D8] hover:bg-[#7B93E0] transition-colors text-white text-2xl font-bold"
                            >
                                Salvar
                            </button>
                        </div>
                    ) : (
                        <div className="!p-9 default-box w-[40rem] relative gap-4 flex-col flex">
                            <div className="space-y-1">
                                <h2 className="text-3xl font-bold">Deseja concluir o boletim?</h2>
                                <p className="text-xl mt-0.5 font-normal text-text-secondary">
                                    Essa ação irá finalizar o boletim de ocorrência! Todos os dados vinculados ao boletim
                                    de nº {selectedItem?.id} não poderão ser alterados futuramente.
                                </p>
                            </div>

                            <button
                                type="button"
                                onClick={onClose}
                                className="size-8 absolute -right-3 -top-3 rounded-full bg-white/5 hover:bg-white/10 text-text-secondary hover:text-white transition-colors fullCenter"
                                aria-label="Limpar resultado e voltar para busca"
                            >
                                ✕
                            </button>

                            <div className="mt-5 flex flex-col gap-6">
                                <div className="space-y-2">
                                    <h3 className="text-white text-xl font-bold leading-none">
                                        Passaporte:{" "}
                                        <span className="font-normal text-white/70">{selectedItem?.suspect.id}</span>
                                    </h3>
                                    <h3 className="text-white text-xl font-bold leading-none">
                                        Sentença:{" "}
                                        <span className="font-normal text-white/70">{selectedItem?.sentence} meses</span>
                                    </h3>
                                    <h3 className="text-white text-xl font-bold leading-none">
                                        Multa:
                                        <span className="font-normal text-white/70">
                                            {" "}
                                            {formatCurrencyBRL(selectedItem?.fine ?? 0)}
                                        </span>
                                    </h3>
                                    <h3 className="text-white text-xl font-bold leading-none">
                                        Fiança:
                                        <span className="font-normal text-white/70">
                                            {" "}
                                            {!selectedItem?.bailAmount
                                                ? "Inafiançável"
                                                : formatCurrencyBRL(selectedItem.bailAmount ?? 0)}
                                        </span>
                                    </h3>
                                </div>

                                <button
                                    type="button"
                                    onClick={onConfirmFinish}
                                    className="mt-2.5 h-[3.7rem] w-full rounded-lg bg-[#6F88D8] hover:bg-[#7B93E0] transition-colors text-white text-2xl font-bold"
                                >
                                    Prender
                                </button>
                            </div>
                        </div>
                    )}
                </motion.div>
            )}
        </AnimatePresence>
    );
}
