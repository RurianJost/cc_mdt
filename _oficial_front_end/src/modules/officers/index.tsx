import { ConfirmActionModal, DeleteOfficerConfirmModal, OfficerCard, PageHeader, SearchInput, SortSelect } from "@/components";
import { IOfficer } from "@/interfaces";
import { useUserSession } from "@/providers";
import { fetchNui, normalizeRegisterSearchInput, randomAvatar } from "@/utils";
import { AnimatePresence } from "framer-motion";
import { useDeferredValue, useEffect, useMemo, useRef, useState } from "react";
import { toast } from "sonner";

export default function Officers() {
    const [officers, setOfficers] = useState<IOfficer[]>([]);
    const [search, setSearch] = useState("");
    const deferredSearch = useDeferredValue(search);
    const [sort, setSort] = useState("date_desc_default");
    const [isDeleting, setIsDeleting] = useState(false);
    const [pendingDelete, setPendingDelete] = useState<{ officer: IOfficer; index: number } | null>(null);
    const { data: user } = useUserSession();
    const canManage = Boolean(user?.canManageOfficers);

    const [contextMenu, setContextMenu] = useState<{ x: number; y: number; officer: IOfficer; index: number } | null>(
        null
    );
    const contextMenuRef = useRef<HTMLDivElement | null>(null);

    const [pendingAction, setPendingAction] = useState<
        | { type: "promote"; officer: IOfficer }
        | { type: "demote"; officer: IOfficer }
        | null
    >(null);
    const [isActionPending, setIsActionPending] = useState(false);

    const [hireModalOpen, setHireModalOpen] = useState(false);
    const [hireOfficerId, setHireOfficerId] = useState("");
    const [isHiring, setIsHiring] = useState(false);

    const loadOfficers = async () => {
        const data = await fetchNui<IOfficer[]>("getOfficers", {}, [
            {
                id: "3703",
                name: "Tobias Bigger",
                avatarURL: null,
                policeRank: "Tenente",
                coords: { x: 0, y: 0, z: 0 },
                inService: true,
                serviceTime: "10 anos",
            },
            {
                id: "333",
                name: "Boss Fta",
                avatarURL: null,
                policeRank: "Tenente",
                coords: { x: 0, y: 0, z: 0 },
                inService: false,
                serviceTime: "10 anos",
            },
            {
                id: "police_002",
                name: "Carlos Mendes",
                avatarURL: randomAvatar(),
                policeRank: "Coronel",
                coords: { x: 0, y: 0, z: 0 },
                inService: true,
                serviceTime: "10 anos",
            },
        ]);

        if (!Array.isArray(data)) return;
        setOfficers(data ?? []);
    };

    useEffect(() => {
        loadOfficers();
    }, []);

    const changeSearchInput = (e: React.ChangeEvent<HTMLInputElement>) => {
        setSearch(normalizeRegisterSearchInput(e.target.value));
    };

    const officersList = useMemo(() => {
        const sorted = [...officers];
        const name = (o: IOfficer) => o?.name ?? "";

        const getList = () => {
            switch (sort) {
                case "date_desc":
                case "sentence_desc":
                case "fine_desc":
                    return sorted.sort((a, b) => String(b.id).localeCompare(String(a.id), undefined, { numeric: true }));
                case "date_asc":
                case "sentence_asc":
                case "fine_asc":
                    return sorted.sort((a, b) => String(a.id).localeCompare(String(b.id), undefined, { numeric: true }));
                case "name_asc":
                    return sorted.sort((a, b) => name(a).localeCompare(name(b)));
                case "name_desc":
                    return sorted.sort((a, b) => name(b).localeCompare(name(a)));
                default:
                    return officers;
            }
        };

        const list = getList().filter(o => {
            const q = deferredSearch?.toLowerCase() ?? "";
            const n = name(o).toLowerCase();
            const id = o.id?.toString().toLowerCase() ?? "";
            const rank = o.policeRank?.toLowerCase() ?? "";
            return n.includes(q) || id.includes(q) || rank.includes(q);
        });
        return list;
    }, [officers, sort, deferredSearch]);

    const markOfficerOnMap = (officer: IOfficer) => {
        void fetchNui("markCds", {
            officerId: officer.id,
            coords: officer.coords,
        });
    };

    useEffect(() => {
        if (!contextMenu) return;
        const onClick = (e: MouseEvent) => {
            const target = e.target as Node;
            if (contextMenuRef.current && !contextMenuRef.current.contains(target)) {
                setContextMenu(null);
            }
        };
        const onKey = (e: KeyboardEvent) => {
            if (e.key === "Escape") setContextMenu(null);
        };
        document.addEventListener("mousedown", onClick);
        window.addEventListener("keydown", onKey);
        return () => {
            document.removeEventListener("mousedown", onClick);
            window.removeEventListener("keydown", onKey);
        };
    }, [contextMenu]);

    const confirmDeleteOfficer = async () => {
        if (!pendingDelete) return;
        const { officer, index } = pendingDelete;
        setPendingDelete(null);
        setIsDeleting(true);
        try {
            const response = await fetchNui<{ errorMessage?: string }>(
                "deleteOfficer",
                {
                    index,
                    officerId: officer.id,
                },
                { errorMessage: void 0 }
            );

            if (response.errorMessage) {
                toast(response.errorMessage);
                return;
            };

            setOfficers(prev => prev.filter(o => o.id !== officer.id));
        } catch (error) {
            toast((error as Error).message);
        } finally {
            setIsDeleting(false);
        }
    };

    const runAction = async () => {
        if (!pendingAction) return;
        setIsActionPending(true);
        try {
            if (pendingAction.type === "promote") {
                const response = await fetchNui<{ errorMessage?: string }>("promoteOfficer", {
                    officerId: pendingAction.officer.id,
                }, { errorMessage: "" });
                if (response?.errorMessage) return toast(response.errorMessage);
                toast("Oficial promovido com sucesso.");
                void loadOfficers();
                return;
            }
            if (pendingAction.type === "demote") {
                const response = await fetchNui<{ errorMessage?: string }>("demoteOfficer", {
                    officerId: pendingAction.officer.id,
                }, { errorMessage: "" });
                if (response?.errorMessage) return toast(response.errorMessage);
                toast("Oficial rebaixado com sucesso.");
                void loadOfficers();
                return;
            }
        } catch (e) {
            toast((e as Error).message);
        } finally {
            setIsActionPending(false);
            setPendingAction(null);
        }
    };

    const confirmHire = async () => {
        const officerId = hireOfficerId.trim();
        if (!officerId) return;
        setIsHiring(true);
        try {
            const response = await fetchNui<{ errorMessage?: string }>(
                "hireOfficer",
                { officerId },
                { errorMessage: "" }
            );
            if (response?.errorMessage) {
                toast(response.errorMessage);
                return;
            }
            toast("Oficial contratado com sucesso.");
            setHireModalOpen(false);
            setHireOfficerId("");
            void loadOfficers();
        } catch (e) {
            toast((e as Error).message);
        } finally {
            setIsHiring(false);
        }
    };

    return (
        <>
            <AnimatePresence mode="wait" key="deleteOfficerConfirmModal">
                {!!pendingDelete && (
                    <DeleteOfficerConfirmModal
                        officerLabel={pendingDelete.officer.name ?? "—"}
                        officerId={pendingDelete.officer.id ?? ""}
                        isDeleting={isDeleting}
                        onClose={() => setPendingDelete(null)}
                        onConfirm={confirmDeleteOfficer}
                    />
                )}
            </AnimatePresence>

            <ConfirmActionModal
                isOpen={hireModalOpen}
                title="Contratar oficial"
                description="Informe o passaporte do oficial que deseja contratar."
                confirmLabel="Contratar"
                confirmVariant="primary"
                isPending={isHiring}
                onClose={() => {
                    if (isHiring) return;
                    setHireModalOpen(false);
                    setHireOfficerId("");
                }}
                onConfirm={() => void confirmHire()}
            >
                <div className="mt-3">
                    <div className="h-12 bg-black/20 relative flex items-center rounded-lg">
                        <input
                            value={hireOfficerId}
                            onChange={(e) => setHireOfficerId(e.target.value.replace(/\D/g, ""))}
                            className="w-full flex-1 h-full px-4 bg-transparent text-xl text-text-secondary"
                            spellCheck={false}
                            inputMode="numeric"
                            placeholder="Passaporte"
                            maxLength={12}
                        />
                    </div>
                </div>
            </ConfirmActionModal>
            <ConfirmActionModal
                isOpen={pendingAction?.type === "promote"}
                title="Promover oficial?"
                description={
                    pendingAction?.type === "promote"
                        ? `Tem certeza que deseja promover ${pendingAction.officer.name ?? "—"} (#${pendingAction.officer.id})?`
                        : ""
                }
                confirmLabel="Promover"
                confirmVariant="primary"
                isPending={isActionPending}
                onClose={() => setPendingAction(null)}
                onConfirm={runAction}
            />

            <ConfirmActionModal
                isOpen={pendingAction?.type === "demote"}
                title="Rebaixar oficial?"
                description={
                    pendingAction?.type === "demote"
                        ? `Tem certeza que deseja rebaixar ${pendingAction.officer.name ?? "—"} (#${pendingAction.officer.id})?`
                        : ""
                }
                confirmLabel="Rebaixar"
                confirmVariant="danger"
                isPending={isActionPending}
                onClose={() => setPendingAction(null)}
                onConfirm={runAction}
            />

            <AnimatePresence mode="wait" key="contextMenuOfficer">
                {!!contextMenu && canManage && (
                    <div
                        ref={contextMenuRef}
                        className="fixed z-[4000]"
                        style={{ left: contextMenu.x, top: contextMenu.y }}
                    >
                        <div className="bg-white/5 z-20 relative backdrop-blur-md border border-white/10 rounded-xl shadow-xl p-3 px-4 w-[13rem]">
                            <div className="flex flex-col gap-2">
                                <button
                                    type="button"
                                    className="text-left bg-white/10 py-1.5 text-base px-3 rounded-md text-white/70 hover:bg-white/10 hover:text-white transition-all"
                                    onClick={() => {
                                        setContextMenu(null);
                                        setPendingAction({ type: "promote", officer: contextMenu.officer });
                                    }}
                                >
                                    Promover
                                </button>
                                <button
                                    type="button"
                                    className="text-left bg-white/10 py-1.5 text-base px-3 rounded-md text-white/70 hover:bg-white/10 hover:text-white transition-all"
                                    onClick={() => {
                                        setContextMenu(null);
                                        setPendingAction({ type: "demote", officer: contextMenu.officer });
                                    }}
                                >
                                    Rebaixar
                                </button>
                                <button
                                    type="button"
                                    className="text-left bg-white/10 py-1.5 text-base px-3 rounded-md text-red-custom/90 hover:bg-white/10 hover:text-red-custom transition-all"
                                    onClick={() => {
                                        setContextMenu(null);
                                        setPendingDelete({ officer: contextMenu.officer, index: contextMenu.index });
                                    }}
                                >
                                    Deletar oficial
                                </button>
                            </div>
                        </div>
                    </div>
                )}
            </AnimatePresence>
            <div className="flex-1 pt-[3.3rem] px-[3.4rem] flex flex-col pb-[2.7rem] gap-5">
                <PageHeader
                    title="Gerenciar Oficiais"
                    description="Analise individualmente todos os oficiais cadastrados;"
                />

                <div className="default-box flex-1 flex flex-col gap-6 !pb-6 !pt-8 !px-6">
                    <header className="w-full h-10 items-center flex justify-between gap-6">
                        <div className="flex items-center gap-4 flex-1 h-full min-w-0">
                            <div className="flex-1 min-w-0 h-full">
                                <SearchInput
                                    value={search}
                                    onChange={changeSearchInput}
                                    placeholder="Busca por nome, passaporte ou patente;"
                                />
                            </div>
                            {canManage && (
                                <button
                                    type="button"
                                    onClick={() => setHireModalOpen(true)}
                                    className="h-10 rounded-lg px-6 bg-blue-custom font-bold text-xl text-white shrink-0"
                                >
                                    Contratar
                                </button>
                            )}
                        </div>
                        <SortSelect value={sort} onChange={setSort} />
                    </header>

                    <div className="flex-1 w-full flex flex-col gap-2 max-h-[calc(9.6rem*3+.6rem)] overflow-x-hidden overflow-y-auto">
                        {officersList.map((officer, index) => (
                            <OfficerCard
                                key={officer.id}
                                officer={officer}
                                onLocate={() => markOfficerOnMap(officer)}
                                canManage={canManage}
                                onContextMenu={(e) => {
                                    if (!canManage) return;
                                    e.preventDefault();
                                    setContextMenu({ x: e.clientX, y: e.clientY, officer, index });
                                }}
                            />
                        ))}
                    </div>
                </div>
            </div>
        </>
    );
}
