export function SuspectInfoRecordForm({ id, description, setId, setDescription }: {
    id: string
    description: string
    setId: (e: string) => void
    setDescription: (e: string) => void
}) {
    return (
        <>
            <div className="w-full default-box !px-6 flex flex-col gap-3">
                <h2 className="text-white text-2xl font-bold">Passaporte</h2>
                <div className="h-12 bg-black/20 relative flex  items-center rounded-lg">
                    <input
                        className="w-full flex-1 h-full font-normal text-base px-4 pr-12 bg-transparent text-text-secondary"
                        spellCheck={false}
                        type="text"
                        inputMode="numeric"
                        placeholder="Digite o passaporte"
                        value={id}
                        maxLength={10}
                        onChange={(e) => {
                            const onlyNumbers = e.target.value.replace(/\D/g, "")
                            setId(onlyNumbers)
                        }}
                    />
                </div>
            </div>

            <div className="w-full default-box !px-6 !pb-6 flex flex-col gap-3 flex-1">
                <h2 className="text-white text-2xl font-bold">Descreva o indivíduo</h2>

                <div className="flex-1 bg-black/20 relative rounded-lg">
                    <textarea
                        className="w-full h-full p-4 bg-transparent font-normal text-base text-text-secondary resize-none outline-none"
                        spellCheck={false}
                        value={description}
                        onChange={(e) => setDescription(e.target.value ?? "")}
                        maxLength={255}
                        placeholder="Descreva a aparência do indivíduo e ocorrência"
                    />
                </div>
            </div>
        </>
    )
};