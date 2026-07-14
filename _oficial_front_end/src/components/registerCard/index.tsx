import { IRegisterItem } from "@/interfaces";
import { useId } from "react";

type RegisterCardProps = {
    register: IRegisterItem;
    onFinalize: () => void;
    onExpand: () => void;
    onRequestDelete: () => void;
};

export function RegisterCard({ register, onFinalize, onExpand, onRequestDelete }: RegisterCardProps) {
    const uid = useId().replace(/:/g, "");

    return (
        <div className="w-full  bg-black/20 p-4 rounded-lg gap-6 flex flex-col">
            <div className="w-full flex items-center justify-between">
                <span className="text-2xl font-bold text-blue-custom">Nº {register.id}</span>
                {register.isFinished ? (
                    <svg className="size-5" width="16" height="14" viewBox="0 0 16 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <g clipPath={`url(#clip_finished_${uid})`}>
                            <path d="M4 5.25V3.9375C4 1.76285 5.79167 0 8 0C10.2083 0 12 1.76285 12 3.9375V5.25H12.4444C13.425 5.25 14.2222 6.03477 14.2222 7V12.25C14.2222 13.2152 13.425 14 12.4444 14H3.55556C2.57361 14 1.77778 13.2152 1.77778 12.25V7C1.77778 6.03477 2.57361 5.25 3.55556 5.25H4ZM5.77778 5.25H10.2222V3.9375C10.2222 2.72945 9.22778 1.75 8 1.75C6.77222 1.75 5.77778 2.72945 5.77778 3.9375V5.25Z" fill="rgb(var(--panel-primary, 114 137 218))" />
                        </g>
                        <defs>
                            <clipPath id={`clip_finished_${uid}`}>
                                <rect width="16" height="14" fill="white" />
                            </clipPath>
                        </defs>
                    </svg>
                ) : (
                    <svg className="size-5" width="16" height="14" viewBox="0 0 16 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <g clipPath={`url(#clip_open_${uid})`}>
                            <path d="M9.77778 5.25H10.6667C11.6472 5.25 12.4444 6.03477 12.4444 7V12.25C12.4444 13.2152 11.6472 14 10.6667 14H1.77778C0.795833 14 0 13.2152 0 12.25V7C0 6.03477 0.795833 5.25 1.77778 5.25H8V3.9375C8 1.76285 9.79167 0 12 0C14.2083 0 16 1.76285 16 3.9375V5.25C16 5.73398 15.6028 6.125 15.1111 6.125C14.6194 6.125 14.2222 5.73398 14.2222 5.25V3.9375C14.2222 2.72945 13.2278 1.75 12 1.75C10.7722 1.75 9.77778 2.72945 9.77778 3.9375V5.25Z" fill="rgb(var(--panel-primary, 114 137 218))" />
                        </g>
                        <defs>
                            <clipPath id={`clip_open_${uid}`}>
                                <rect width="16" height="14" fill="white" />
                            </clipPath>
                        </defs>
                    </svg>
                )}
            </div>

            <div className="w-full flex items-center justify-between">
                <div className="flex items-center gap-3">
                    <svg className="size-[1.4rem]" width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M12.8327 2.33341L11.666 1.16675C10.9952 1.54008 10.1493 1.75008 9.33268 1.75008C8.51602 1.75008 7.66435 1.53425 6.99935 1.16675C6.33435 1.53425 5.48268 1.75008 4.66602 1.75008C3.84935 1.75008 3.00352 1.54008 2.33268 1.16675L1.16602 2.33341C1.16602 2.33341 2.33268 3.50008 2.33268 4.66675C2.33268 5.83342 1.16602 8.16675 1.16602 9.33342C1.16602 11.6667 6.99935 12.8334 6.99935 12.8334C6.99935 12.8334 12.8327 11.6667 12.8327 9.33342C12.8327 8.16675 11.666 5.83342 11.666 4.66675C11.666 3.50008 12.8327 2.33341 12.8327 2.33341ZM8.77852 9.59592L6.98185 8.51092L5.19102 9.59592L5.66935 7.55425L4.08268 6.18925L6.17102 6.00842L6.98185 4.08342L7.79852 6.00258L9.88685 6.18342L8.30018 7.54841L8.77852 9.59592Z" fill="white" />
                    </svg>
                    <p className="text-white font-normal text-base capitalize">
                        {register.police.name} #{register.police.id}
                    </p>
                </div>
                <div className="flex items-center gap-3">
                    <svg className="size-[1.4rem]" width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M12.8327 2.33341L11.666 1.16675C10.9952 1.54008 10.1493 1.75008 9.33268 1.75008C8.51602 1.75008 7.66435 1.53425 6.99935 1.16675C6.33435 1.53425 5.48268 1.75008 4.66602 1.75008C3.84935 1.75008 3.00352 1.54008 2.33268 1.16675L1.16602 2.33341C1.16602 2.33341 2.33268 3.50008 2.33268 4.66675C2.33268 5.83342 1.16602 8.16675 1.16602 9.33342C1.16602 11.6667 6.99935 12.8334 6.99935 12.8334C6.99935 12.8334 12.8327 11.6667 12.8327 9.33342C12.8327 8.16675 11.666 5.83342 11.666 4.66675C11.666 3.50008 12.8327 2.33341 12.8327 2.33341ZM8.77852 9.59592L6.98185 8.51092L5.19102 9.59592L5.66935 7.55425L4.08268 6.18925L6.17102 6.00842L6.98185 4.08342L7.79852 6.00258L9.88685 6.18342L8.30018 7.54841L8.77852 9.59592Z" fill="white" />
                    </svg>
                    <p className="text-white font-normal text-base">{register.formattedDate}</p>
                </div>
                <div className="flex items-center gap-3">
                    <svg className="size-[1.4rem]" width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M9.09578 1.76586C8.56367 1.19137 7.82047 0.875 7.00015 0.875C6.17547 0.875 5.4298 1.18945 4.90015 1.76039C4.36476 2.33762 4.10391 3.12211 4.16516 3.96922C4.28656 5.64047 5.55832 7 7.00015 7C8.44199 7 9.71156 5.64074 9.83488 3.96977C9.89695 3.13031 9.63445 2.34746 9.09578 1.76586ZM11.8127 13.125H2.18766C2.06167 13.1266 1.93691 13.1002 1.82244 13.0475C1.70798 12.9949 1.60668 12.9174 1.52594 12.8207C1.3482 12.6082 1.27656 12.3181 1.32961 12.0247C1.56039 10.7445 2.28062 9.66902 3.41266 8.91406C4.41836 8.24387 5.6923 7.875 7.00015 7.875C8.308 7.875 9.58195 8.24414 10.5877 8.91406C11.7197 9.66875 12.4399 10.7442 12.6707 12.0244C12.7237 12.3178 12.6521 12.6079 12.4744 12.8204C12.3936 12.9172 12.2924 12.9947 12.1779 13.0474C12.0634 13.1001 11.9387 13.1266 11.8127 13.125Z" fill="white" />
                    </svg>

                    <p className="text-white font-normal text-base capitalize">
                        {register.suspect.name} #{register.suspect.id}
                    </p>
                </div>
            </div>

            <div className="w-full flex items-center justify-between gap-2.5 h-10">
                {!register.isFinished && (
                    <button
                        type="button"
                        onClick={onFinalize}
                        className="h-full rounded-lg w-full flex-1 bg-blue-custom font-bold text-xl text-white"
                    >
                        Prender
                    </button>
                )}
                <button
                    type="button"
                    onClick={onExpand}
                    className="h-full rounded-lg w-full flex-1 bg-transparent border-[.2rem] border-solid border-blue-custom font-bold text-xl text-blue-custom"
                >
                    Expandir
                </button>
                <button
                    type="button"
                    onClick={onRequestDelete}
                    className="h-full rounded-lg w-full flex-1 bg-transparent border-[.2rem] border-solid border-red-custom font-bold text-xl text-red-custom"
                >
                    Deletar
                </button>
            </div>
        </div>
    );
}
