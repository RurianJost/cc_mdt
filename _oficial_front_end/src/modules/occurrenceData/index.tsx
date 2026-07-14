import defaultAvatar from "@/assets/defaultAvatar.png";
import { PageHeader } from "@/components";
import { IOccurrenceDataSearched } from "@/interfaces";
import { fetchNui } from "@/utils";
import { KeyboardEvent, useState } from "react";
import { useNavigate } from "react-router-dom";

export default function OccurrenceData() {
    const [search, setSearch] = useState("");
    const [searchError, setSearchError] = useState<string | null>(null);
    const [resultSearch, setResultSearch] = useState<IOccurrenceDataSearched | null>(null);
    const navigate = useNavigate();

    const handleSearch = async (termOverride?: string) => {
        const term = (termOverride ?? search).trim();
        if (!term) return;

        setSearchError(null);

        try {
            const response = await fetchNui<IOccurrenceDataSearched>("getOccurrenceData", { search: term }, {
                user: {
                    avatarURL: null,
                    id: "3",
                    name: "Gtn dev",
                    age: 25,
                    identity: "RREAISMRIAFA",
                    fineValue: 5000,
                    status: "em aberto",
                },
                occurrences: [
                    {
                        id: "1",
                        title: "ART. 155 - Furto",
                        createdAt: "27/04/2022 - 16:23",
                        officer: {
                            name: "Antonio Alberto",
                            id: "4433",
                        },
                        fine: 50000,
                        status: "Em aberto",
                    },
                ],
            }, 1000);

            if (!response) return;

            if (response.errorMessage) {
                setSearchError(response.errorMessage);
                setResultSearch(null);
                return;
            }

            if (!response.user && !response.vehicle) {
                setSearchError("Nenhum dado encontrado para esta busca.");
                setResultSearch(null);
                return;
            }

            setResultSearch(response);
        } catch {
            setSearchError("Falha ao buscar dados. Tente novamente.");
            setResultSearch(null);
        }
    };

    const handleSearchKeyDown = (event: KeyboardEvent<HTMLInputElement>) => {
        if (event.key !== "Enter") return;
        event.preventDefault();
        void handleSearch(event.currentTarget.value);
    };

    const handleClearResult = () => {
        setResultSearch(null);
        setSearchError(null);
    };

    const occurrences = (resultSearch?.vehicle
        ? resultSearch.fines
        : resultSearch?.occurrences) ?? [];
        
    const showResults = Boolean(resultSearch);

    return (
        <div className="flex-1 pt-[3.3rem] px-[3.4rem] flex flex-col pb-[2.7rem] gap-5">
            <PageHeader
                title="Dados"
                description="Procure indivíduos ou veículos na database policial;"
            />

            {(!showResults || searchError) && (
                <div className="w-full default-box !px-6 flex flex-col gap-2">
                    <h2 className="text-white text-2xl font-bold">Busca</h2>
                    <div className="h-12 bg-black/20 relative flex items-center rounded-lg">
                        <input
                            className="w-full flex-1 h-full px-4 pr-12 bg-transparent text-base text-text-secondary"
                            spellCheck={false}
                            value={search}
                            onChange={(e) => setSearch(e.target.value)}
                            maxLength={255}
                            placeholder="Pesquise um passaporte ou placa de um veículo;"
                            onKeyDown={handleSearchKeyDown}
                        />

                        <button
                            type="button"
                            className="absolute right-4 p-0 border-0 bg-transparent cursor-pointer"
                            aria-label="Buscar"
                            onClick={() => void handleSearch()}
                        >
                            <svg className="size-6" width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">
                                <path d="M6.25 11.25C7.35936 11.2498 8.43675 10.8784 9.31063 10.195L12.0581 12.9425L12.9419 12.0588L10.1944 9.31125C10.8781 8.43729 11.2497 7.35965 11.25 6.25C11.25 3.49313 9.00688 1.25 6.25 1.25C3.49313 1.25 1.25 3.49313 1.25 6.25C1.25 9.00688 3.49313 11.25 6.25 11.25ZM6.25 2.5C8.31812 2.5 10 4.18187 10 6.25C10 8.31812 8.31812 10 6.25 10C4.18187 10 2.5 8.31812 2.5 6.25C2.5 4.18187 4.18187 2.5 6.25 2.5Z" fill="white" />
                            </svg>
                        </button>
                    </div>

                    {searchError && (
                        <p className="text-red-400 text-sm mt-1" role="alert">
                            {searchError}
                        </p>
                    )}
                </div>
            )}

            {showResults && (
                <div className="w-full default-box relative flex-1 !p-6 flex flex-col gap-4">
                    <button
                        type="button"
                        onClick={handleClearResult}
                        className="size-8 absolute -right-3 -top-3 rounded-full bg-white/5 hover:bg-white/10 text-text-secondary hover:text-white transition-colors fullCenter"
                        aria-label="Limpar resultado e voltar para busca"
                    >
                        ✕
                    </button>

                    {resultSearch?.vehicle && (
                        <div className="w-full bg-black/20 rounded-2xl px-6 py-5 flex flex-col gap-5">
                            <div className="flex items-center justify-between gap-4">
                                <h3 className="text-white text-2xl font-bold">Veículo</h3>
                                <button
                                    type="button"
                                    onClick={() => {
                                        if (!resultSearch?.vehicle) return;
                                        navigate("/fines", {
                                            state: {
                                                prefillVehicle: {
                                                    plate: resultSearch.vehicle.plate ?? "",
                                                    reason: "",
                                                },
                                                startStep: 2,
                                            },
                                        });
                                    }}
                                    className="h-10 rounded-lg px-6 bg-blue-custom font-bold text-xl text-white shrink-0"
                                >
                                    Multar
                                </button>
                            </div>

                            <div className="flex gap-6 items-stretch">
                                <div className="w-[7.5rem] h-[7.5rem] bg-white/10 fullCenter shrink-0 rounded-lg overflow-hidden">
                                    {resultSearch.vehicle.imageURL ? (
                                        <img
                                            src={resultSearch.vehicle.imageURL}
                                            alt={resultSearch.vehicle.model}
                                            className="size-full object-contain"
                                        />
                                    ) : (
                                        <span className="text-text-secondary text-xs px-2 text-center">Sem imagem</span>
                                    )}
                                </div>

                                <div className="flex-1 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-x-10 gap-y-4">
                                    <div className="flex flex-col gap-0.5">
                                        <span className="text-text-secondary text-sm font-normal">Placa</span>
                                        <span className="text-white text-xl font-medium uppercase">
                                            {resultSearch.vehicle.plate}
                                        </span>
                                    </div>
                                    <div className="flex flex-col gap-0.5">
                                        <span className="text-text-secondary text-sm font-normal">Modelo</span>
                                        <span className="text-white text-xl font-medium">{resultSearch.vehicle.model}</span>
                                    </div>
                                    <div className="flex flex-col gap-0.5">
                                        <span className="text-text-secondary text-sm font-normal">Situação</span>
                                        <span
                                            className={
                                                resultSearch.vehicle.isDetained
                                                    ? "text-amber-400 text-xl font-medium"
                                                    : "text-[#3BA55D] text-xl font-medium"
                                            }
                                        >
                                            {resultSearch.vehicle.isDetained ? "Apreendido" : "Em circulação"}
                                        </span>
                                    </div>
                                    <div className="flex flex-col gap-0.5 sm:col-span-2 lg:col-span-3">
                                        <span className="text-text-secondary text-sm font-normal">Proprietário</span>
                                        <span className="text-white text-xl font-medium">
                                            {resultSearch.vehicle.owner ? (
                                                <>
                                                    {resultSearch.vehicle.owner.name}{" "}
                                                    <span className="text-text-secondary font-normal">
                                                        #{resultSearch.vehicle.owner.id}
                                                    </span>
                                                </>
                                            ) : (
                                                <span className="text-text-secondary">Não informado</span>
                                            )}
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    )}

                    {resultSearch?.user && (
                        <div className="w-full bg-black/20 rounded-2xl px-6 py-5 flex flex-col gap-5">
                            <div className="flex items-center justify-between gap-4">
                                <h3 className="text-white text-2xl font-bold">Indivíduo</h3>
                                <button
                                    type="button"
                                    onClick={() => {
                                        if (!resultSearch?.user) return;
                                        navigate("/toRegister", {
                                            state: {
                                                prefillSuspect: {
                                                    id: String(resultSearch.user.id ?? ""),
                                                    name: resultSearch.user.name ?? "",
                                                    avatarURL: resultSearch.user.avatarURL ?? null,
                                                },
                                                startStep: 2,
                                            },
                                        });
                                    }}
                                    className="h-10 rounded-lg px-6 bg-blue-custom font-bold text-xl text-white shrink-0"
                                >
                                    Abrir BO
                                </button>
                            </div>

                            <div className="flex gap-6 items-stretch">
                                <div className="w-[7.5rem] h-[7.5rem] bg-white/10 fullCenter shrink-0 rounded-lg overflow-hidden">
                                    <img
                                        src={resultSearch.user.avatarURL ?? defaultAvatar}
                                        alt=""
                                        className="size-full object-contain"
                                    />
                                </div>

                                <div className="flex-1 grid grid-cols-3 gap-x-10 gap-y-4">
                                    <div className="flex flex-col gap-3">
                                        <div className="flex flex-col gap-0.5">
                                            <span className="text-text-secondary text-sm font-normal">Nome</span>
                                            <span className="text-white text-xl font-medium">{resultSearch.user.name}</span>
                                        </div>
                                        <div className="flex flex-col gap-0.5">
                                            <span className="text-text-secondary text-sm font-normal">Identidade</span>
                                            <span className="text-white text-xl font-medium">{resultSearch.user.identity}</span>
                                        </div>
                                    </div>

                                    <div className="flex flex-col gap-3">
                                        <div className="flex flex-col gap-0.5">
                                            <span className="text-text-secondary text-sm font-normal">Passaporte</span>
                                            <span className="text-white text-xl font-medium">{resultSearch.user.id}</span>
                                        </div>
                                        <div className="flex flex-col gap-0.5">
                                            <span className="text-text-secondary text-sm font-normal">Multa</span>
                                            <span className="text-white text-xl font-medium">
                                                {resultSearch.user.fineValue.toLocaleString("pt-BR", {
                                                    style: "currency",
                                                    currency: "BRL",
                                                })}
                                            </span>
                                        </div>
                                    </div>

                                    <div className="flex flex-col gap-3">
                                        <div className="flex flex-col gap-0.5">
                                            <span className="text-text-secondary text-sm font-normal">Idade</span>
                                            <span className="text-white text-xl font-medium">{resultSearch.user.age}</span>
                                        </div>
                                        <div className="flex flex-col gap-0.5">
                                            <span className="text-text-secondary text-sm font-normal">Status</span>
                                            <span className="text-white text-xl font-medium">{resultSearch.user.status}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    )}

                    <div className="w-full bg-black/20 rounded-2xl px-6 py-5 flex flex-col gap-4">
                        <h3 className="text-white text-2xl font-bold">
                            {resultSearch?.vehicle ? "Multas" : "Boletim de Ocorrência"}
                        </h3>

                        {occurrences.length === 0 ? (
                            <div className="w-full min-h-[5.5rem] rounded-xl bg-black/10 fullCenter">
                                <span className="text-text-secondary text-lg">
                                    Nenhuma informação encontrada;
                                </span>
                            </div>
                        ) : (
                            <div className="flex flex-col gap-3 max-h-[14rem] overflow-x-hidden overflow-y-auto pr-1">
                                {occurrences.map((occurrence) => (
                                    <div
                                        key={occurrence.id}
                                        className="w-full rounded-2xl bg-black/10 px-5 py-3 flex flex-col gap-2"
                                    >
                                        <div className="flex items-center justify-between gap-4">
                                            <span className="text-white text-2xl font-semibold">{occurrence.title}</span>
                                            <span className="text-text-secondary text-sm shrink-0">{occurrence.createdAt}</span>
                                        </div>

                                        <div className="flex flex-wrap items-end justify-between gap-2 text-sm">
                                            <p className="text-text-secondary">
                                                <span>Oficial: </span>
                                                <span className="text-white">
                                                    {occurrence.officer.name} #{occurrence.officer.id}
                                                </span>
                                            </p>

                                            <div className="flex items-center gap-4 flex-wrap">
                                                <p className="text-text-secondary">
                                                    <span>Multa: </span>
                                                    <span className="text-white">
                                                        {occurrence.fine.toLocaleString("pt-BR", {
                                                            style: "currency",
                                                            currency: "BRL",
                                                        })}
                                                    </span>
                                                </p>

                                                <span className="text-xs font-medium px-4 py-1 rounded-full bg-white/10 text-text-secondary">
                                                    {occurrence.status}
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>
                </div>
            )}
        </div>
    );
}
