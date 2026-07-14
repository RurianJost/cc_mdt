import { ModifierPenalCodeItem, PenalCodeItem } from "@/interfaces";

export function MitigationSuspectForm({
    attenuants,
    aggravants,
    selectedAttenuants,
    selectedAggravants,
    onSelectAggravant,
    onSelectAttenuant

}: {
    attenuants: ModifierPenalCodeItem[]
    selectedAttenuants: string[]
    selectedAggravants: string[]
    aggravants: ModifierPenalCodeItem[]
    onSelectAttenuant: (id: string) => void
    onSelectAggravant: (id: string) => void
}) {
    return (
        <>
            <div className="w-full default-box !px-6 !flex-1 flex flex-col gap-3">
                <h2 className="text-white text-2xl font-bold">Atenuantes</h2>

                {/* HEADER */}
                <div className="grid grid-cols-[4rem_1fr_12rem] opacity-70 text-text-secondary text-base">
                    <div />
                    <span>Descrição</span>
                    <span>Porcentagem</span>
                </div>

                <div className="relative flex items-center rounded-lg">
                    <div className="flex flex-col gap-3 overflow-y-auto max-h-[6rem] w-full overflow-x-hidden pr-2">
                        {attenuants.map((crime, index) => <div
                            key={index}
                            onClick={() => onSelectAttenuant(crime.id)}
                            className="grid grid-cols-[4rem_1fr_12rem] text-xl items-center text-white"
                        >
                            <input
                                type="checkbox"
                                checked={selectedAttenuants.includes(crime.id)}
                                onChange={() => onSelectAttenuant(crime.id)}
                                onClick={(e) => e.stopPropagation()}
                                className="custom-checkbox"
                            />
                            {/* <span>{crime.article}</span> */}

                            <span className="truncate">{crime.description}</span>

                            <span className="pl-2">{crime.percentage ?? 0}%</span>
                        </div>)}
                    </div>
                </div>
            </div>
            <div className="w-full default-box !px-6 !flex-1 flex flex-col gap-3">
                <h2 className="text-white text-2xl font-bold">Agravantes</h2>

                {/* HEADER */}
                <div className="grid grid-cols-[4rem_1fr_12rem] opacity-70 text-text-secondary text-base">
                    <div />
                    <span>Descrição</span>
                    <span>Porcentagem</span>
                </div>

                <div className="relative flex items-center rounded-lg">
                    <div className="flex flex-col gap-3 overflow-y-auto max-h-[6rem] w-full overflow-x-hidden pr-2">

                        {aggravants.map((crime, index) => (
                            <div
                                key={index}
                                onClick={() => onSelectAggravant(crime.id)}
                                className="grid grid-cols-[4rem_1fr_12rem] text-xl items-center text-white"
                            >
                                <input
                                    type="checkbox"
                                    checked={selectedAggravants.includes(crime.id)}
                                    onChange={() => onSelectAggravant(crime.id)}
                                    onClick={(e) => e.stopPropagation()}
                                    className="custom-checkbox"
                                />
                                {/* <span>{crime.article}</span> */}

                                <span className="truncate">{crime.description}</span>

                                <span className="pl-2">{crime.percentage ?? 0}%</span>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </>
    )
};