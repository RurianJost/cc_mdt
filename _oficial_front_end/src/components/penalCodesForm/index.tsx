import { PenalCodeItem } from "@/interfaces";

export function PenalCodesForm({ crimes, onSelectCrime, selected }: {
    crimes: PenalCodeItem[],
    onSelectCrime: (e: PenalCodeItem['id']) => void
    selected: string[]

}) {
    return (
        <>
            <div className="default-box flex-1 !p-6 flex flex-col gap-4">

                <h2 className="text-white text-xl font-bold">
                    Código Penal<span className="text-red-500 ml-2">*</span>
                </h2>

                {/* HEADER */}
                <div className="grid grid-cols-[4rem_8rem_1fr_12rem_12rem] text-text-secondary text-base">
                    <div />
                    <span>Artigo</span>
                    <span>Descrição</span>
                    <span>Sentença</span>
                    <span>Multa</span>
                </div>

                {/* LISTA */}
                <div className="flex flex-col gap-3 overflow-y-auto max-h-[20rem] w-full overflow-x-hidden pr-2">
                    {crimes.map((crime, index) => (
                        <div
                            onClick={() => onSelectCrime(crime.id)}
                            key={index}
                            className="!grid !cursor-default grid-cols-[4rem_8rem_1fr_12rem_12rem] text-base items-center text-white"
                        >
                            <input
                                type="checkbox"
                                checked={selected.includes(crime.id)}
                                onChange={() => onSelectCrime(crime.id)}
                                onClick={(e) => e.stopPropagation()}
                                className="custom-checkbox"
                            />
                            <span className="capitalize">{crime.article}</span>

                            <span className="truncate ">{crime.description}</span>

                            <span className="pl-2">{crime.sentence}</span>

                            <span>
                                {crime.fine.toLocaleString("pt-BR", {
                                    style: "currency",
                                    currency: "BRL",
                                })}
                            </span>
                        </div>
                    ))}
                </div>
            </div>
        </>
    )
};