import { IOfficer } from "@/interfaces";
import defaultAvatar from "@/assets/defaultAvatar.png";

type OfficerCardProps = {
    officer: IOfficer;
    onLocate: () => void;
    onRequestDelete?: () => void;
    onContextMenu?: (e: React.MouseEvent) => void;
    canManage?: boolean;
};


export function OfficerCard({ officer, onLocate, onRequestDelete, onContextMenu, canManage }: OfficerCardProps) {
    const displayName = officer.name ?? "—";
    const avatarSrc = officer.avatarURL || defaultAvatar;
    const serviceTimeLabel = officer.serviceTime ?? "";
    const rankLabel = officer.policeRank ?? "—";

    return (
        <div
            onContextMenu={onContextMenu}
            className="w-full bg-black/20 p-3 rounded-[10px] flex flex-row items-center justify-between gap-4"
        >
            <div className="flex items-center gap-3 min-w-0 flex-1">
                <div className="relative shrink-0">
                    <img src={avatarSrc} alt="" className="size-12 rounded-full object-cover bg-white/10" />
                    <span
                        className={`absolute bottom-0 right-0 size-3 rounded-full border-2 border-[#1a1d24] ${
                            officer.inService ? "bg-emerald-500" : "bg-zinc-500"
                        }`}
                        aria-hidden
                    />
                </div>
                <div className="flex flex-col gap-0.5 min-w-0">
                    <p className="text-base font-bold text-white truncate">
                        {displayName}{" "}
                        <span className="font-normal text-white/50">#{officer.id}</span>
                    </p>
                    <div className="flex items-center gap-2 text-sm text-white/50 min-w-0 flex-wrap">
                        <span className="truncate">{rankLabel}</span>
                        <span className="truncate">
                            {/* {officer.inService ? "Em serviço" : "Fora de serviço"} */}
                            {serviceTimeLabel ? ` • ${serviceTimeLabel}` : ""}
                        </span>
                    </div>
                </div>
            </div>
            <div className="flex items-center gap-2.5 shrink-0">
                <button
                    type="button"
                    className="p-1 size-8 rounded-md text-white/80 hover:text-white hover:bg-white/10 transition-colors"
                    aria-label="Localizar"
                    onClick={onLocate}
                >
                    <svg
                        className="size-full flex-1"
                        width="22"
                        height="22"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="1.5"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        xmlns="http://www.w3.org/2000/svg"
                    >
                        <path d="M15 10.5a3 3 0 11-6 0 3 3 0 016 0z" />
                        <path d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1115 0z" />
                    </svg>
                </button>
                {/* {!canManage && (
                    <button
                        type="button"
                        className="p-1 size-8 rounded-md text-white/80 hover:text-red-custom hover:bg-white/10 transition-colors"
                        aria-label="Remover"
                        onClick={onRequestDelete}
                    >
                        <svg
                            className="size-full flex-1"
                            width="22"
                            height="22"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            strokeWidth="1.5"
                            xmlns="http://www.w3.org/2000/svg"
                        >
                            <path d="M3 6h18M8 6V4a2 2 0 012-2h4a2 2 0 012 2v2m3 0v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6h14zM10 11v6M14 11v6" />
                        </svg>
                    </button>
                )} */}
            </div>
        </div>
    );
}
