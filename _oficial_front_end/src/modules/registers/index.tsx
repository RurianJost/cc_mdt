import {
    DeleteRegisterConfirmModal,
    PageHeader,
    RegisterCard,
    RegisterModal,
    SearchInput,
    SortSelect,
} from "@/components";
import { IRegisterItem, SelectedCrimeDetailed } from "@/interfaces";
import { useCrimesProvider } from "@/providers/crimesProvider";
import { fetchNui, filterSortRegisters, normalizeRegisterSearchInput } from "@/utils";
import { useDeferredValue, useEffect, useMemo, useState } from "react";
import { toast } from "sonner";
import { ActionModal } from "./types";

export default function Registers() {
    const [inOccurrencyActions, setInOccurencyActions] = useState<ActionModal>(ActionModal.CLOSED);
    const [registers, setRegisters] = useState<IRegisterItem[]>([]);
    const [selectedItem, setSelectedItem] = useState<(IRegisterItem & { index: number }) | null>(null);
    const { crimes, attenuants, aggravants } = useCrimesProvider();
    const [search, setSearch] = useState("");
    const deferredSearch = useDeferredValue(search);
    const [sort, setSort] = useState("date_desc_default");
    const [pendingDelete, setPendingDelete] = useState<{ register: IRegisterItem; index: number } | null>(null);
    const [isDeleting, setIsDeleting] = useState(false);

    const getAllRegisters = async () => {
        const data = await fetchNui<IRegisterItem[]>("getRegistersData", {}, [
            {
                id: "4",
                police: {
                    name: "Boss Fta",
                    id: "3031",
                },
                formattedDate: "20/03/2026 14:32",
                suspect: {
                    name: "João da Silva",
                    id: "44",
                    identity: "P-45821",
                },
                crimes: [{ id: "ART_11" }, { id: "ART_12" }, { id: "ART_14" }],
                description:
                    "Indivíduo abordado em atitude suspeita, apresentou resistência à prisão e portava substâncias ilícitas.",
                sentence: 80,
                fine: 0,
                bailAmount: 0,
            },
            {
                id: "4sdfsdf",
                police: {
                    name: "Boss Fta",
                    id: "3031",
                },
                formattedDate: "20/03/2026 14:32",
                suspect: {
                    name: "João da Silva",
                    id: "44",
                    identity: "P-45821",
                },
                crimes: [{ id: "ART_11" }, { id: "ART_12" }, { id: "ART_14" }, { id: "ART_15" }, { id: "ART_16" }, { id: "ART_12" }, { id: "ART_14" }],
                description:
                    "Indivíduo abordado em atitude suspeita, apresentou resistência à prisão e portava substâncias ilícitas.",
                sentence: 80,
                fine: 0,
                bailAmount: 0,
            },
        ]);

        if (!Array.isArray(data)) return;
        setRegisters(data ?? []);
    };

    const getItemData = (id: string) => {
        if (!registers?.length) return { item: null, index: null };
        const itemRegister = registers.find(e => e.id === id);
        const itemRegisterIndex = registers.findIndex(e => e.id === id);
        return { item: itemRegister, index: itemRegisterIndex };
    };

    const removeSelectedCrime = (crime: SelectedCrimeDetailed, index: number) => {
        const crimesList = selectedItem?.crimes;
        if (!crimesList?.length || crimesList.length === 1) return;

        const newCrimes = crimesList.filter((_, key) => key !== index);
        setSelectedItem(prev => (!prev ? prev : { ...prev, crimes: newCrimes }));
    };

    const addSelectedCrime = (crimeId: string) => {
        setSelectedItem((prev) => {
            if (!prev) return prev;
            const exists = prev.crimes.some((c) => c.id === crimeId);
            if (exists) return prev;
            return { ...prev, crimes: [...prev.crimes, { id: crimeId }] };
        });
    };

    const changeSelectedDescription = (description: string) => {
        setSelectedItem((prev) => (!prev ? prev : { ...prev, description }));
    };

    const saveSelectedItem = async () => {
        if (!selectedItem) return;
        const { item, index } = getItemData(selectedItem.id);
        if (!item || index === null || index === undefined) return;

        try {
            const response = await fetchNui<{ errorMessage?: boolean }>(
                "updateRegister",
                {
                    ...item,
                    index,
                    crimes: selectedItem.crimes.map(e => e.id),
                    description: selectedItem.description,
                },
                {
                    errorMessage: false,
                }
            );

            if (response.errorMessage) {
                toast(response.errorMessage);
            }

            getAllRegisters();
        } catch (error) {
            toast((error as any).message);
        } finally {
            setSelectedItem(null);
            setInOccurencyActions(ActionModal.CLOSED);
        }
    };

    const handleFinishRegister = async () => {
        if (!selectedItem) return;

        const { item, index } = getItemData(selectedItem.id);

        try {
            const response = await fetchNui<{ errorMessage?: string }>(
                "finishRegister",
                {
                    ...item,
                    index,
                },
                { errorMessage: "" }
            );

            if (response.errorMessage) {
                toast(response.errorMessage);
            }
        } catch (error) {
            toast((error as any).message);
        } finally {
            setSelectedItem(null);
            setInOccurencyActions(ActionModal.CLOSED);
            getAllRegisters();
        }
    };

    useEffect(() => {
        getAllRegisters();
    }, []);

    const changeSearchInput = (e: React.ChangeEvent<HTMLInputElement>) => {
        setSearch(normalizeRegisterSearchInput(e.target.value));
    };

    const registersList = useMemo(
        () => filterSortRegisters(registers, sort, deferredSearch),
        [registers, sort, deferredSearch]
    );

    const modalOpen = inOccurrencyActions !== ActionModal.CLOSED;
    const modalMode = inOccurrencyActions === ActionModal.EXPANDED ? "expanded" : "finish";

    const confirmDeleteRegister = async () => {
        if (!pendingDelete) return;
        const { register, } = pendingDelete;
        const { item, index } = getItemData(register.id);
        setIsDeleting(true);
        try {
            const response = await fetchNui<{ errorMessage?: string }>(
                "deleteRegister",
                {
                    ...item,
                    index,
                },
                { errorMessage: "" }
            );

            if (response.errorMessage) {
                toast(response.errorMessage);
                return;
            }

            setPendingDelete(null);
            if (selectedItem?.id === register.id) {
                setSelectedItem(null);
                setInOccurencyActions(ActionModal.CLOSED);
            }
            await getAllRegisters();
        } catch (error) {
            toast((error as Error).message);
        } finally {
            setIsDeleting(false);
        }
    };

    return (
        <>
            <DeleteRegisterConfirmModal
                isOpen={!!pendingDelete}
                registerId={pendingDelete?.register.id ?? ""}
                isDeleting={isDeleting}
                onClose={() => !isDeleting && setPendingDelete(null)}
                onConfirm={confirmDeleteRegister}
            />

            <RegisterModal
                isOpen={modalOpen}
                mode={modalMode}
                selectedItem={selectedItem}
                crimes={crimes}
                attenuants={attenuants}
                aggravants={aggravants}
                onClose={() => setInOccurencyActions(ActionModal.CLOSED)}
                onSave={saveSelectedItem}
                onConfirmFinish={handleFinishRegister}
                onRemoveCrime={removeSelectedCrime}
                onAddCrime={addSelectedCrime}
                onChangeDescription={changeSelectedDescription}
            />

            <div className="flex-1 pt-[3.3rem] px-[3.4rem] flex flex-col pb-[2.7rem] gap-5">
                <PageHeader
                    title="Registros"
                    description="Verifique os últimos boletins de ocorrências policiais;"
                />

                <div className="default-box flex-1 flex flex-col gap-6 !pb-6 !pt-8 !px-6">
                    <header className="w-full h-10 items-center flex justify-between gap-6">
                        <SearchInput value={search} onChange={changeSearchInput} />
                        <SortSelect value={sort} onChange={setSort} />
                    </header>

                    <div className="flex-1 w-full flex flex-col gap-2 max-h-[calc(9.6rem*3+.6rem)] overflow-x-hidden">
                        {registersList.map((register, index) => (
                            <RegisterCard
                                key={`${register.id}-${index}`}
                                register={register}
                                onFinalize={() => {
                                    setSelectedItem({ ...register, index });
                                    setInOccurencyActions(ActionModal.TO_FINISHED);
                                }}
                                onExpand={() => {
                                    setSelectedItem({ ...register, index });
                                    setInOccurencyActions(ActionModal.EXPANDED);
                                }}
                                onRequestDelete={() => setPendingDelete({ register, index })}
                            />
                        ))}
                    </div>
                </div>
            </div>
        </>
    );
}
