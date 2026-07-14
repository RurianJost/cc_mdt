import { sortOptions } from "@/utils";
import { useEffect, useRef, useState } from "react";

type SortSelectProps = {
    value: string;
    onChange: (key: string) => void;
    /** Chave que exibe o placeholder em vez do título da opção (ex.: "Ordenar por") */
    placeholderKey?: string;
    placeholderLabel?: string;
};

export function SortSelect({
    value,
    onChange,
    placeholderKey = "date_desc_default",
    placeholderLabel = "Ordenar por",
}: SortSelectProps) {
    const [isOpen, setIsOpen] = useState(false);
    const containerRef = useRef<HTMLDivElement | null>(null);

    useEffect(() => {
        function handleClickOutside(e: MouseEvent) {
            if (
                isOpen &&
                containerRef.current &&
                !containerRef.current.contains(e.target as Node)
            ) {
                setIsOpen(false);
            }
        }
        document.addEventListener("mousedown", handleClickOutside);
        return () => document.removeEventListener("mousedown", handleClickOutside);
    }, [isOpen]);

    const label =
        value === placeholderKey
            ? placeholderLabel
            : sortOptions.find(e => e.key === value)?.title;

    return (
        <div
            ref={containerRef}
            className="cursor-pointer h-full w-fit bg-black/20 relative rounded-lg"
        >
            {isOpen && (
                <div
                    className="absolute left-1/2 z-20 -translate-x-1/2 top-full mt-3 w-[12rem] transition-all duration-300"
                >
                    <div className="bg-white/5 z-20 relative backdrop-blur-md border border-white/10 rounded-xl shadow-xl p-3 px-4">
                        <div className="h-40 overflow-y-auto overflow-x-hidden flex flex-col gap-2 pr-1">
                            {sortOptions.map((option, index) => (
                                <button
                                    key={index}
                                    type="button"
                                    className="text-left bg-white/10 py-1.5 text-base px-3 rounded-md text-white/70 hover:bg-white/10 hover:text-white transition-all"
                                    onClick={() => {
                                        onChange(option.key);
                                        setIsOpen(false);
                                    }}
                                >
                                    {option.title}
                                </button>
                            ))}
                        </div>
                    </div>
                </div>
            )}
            <button
                type="button"
                onClick={() => setIsOpen(prev => !prev)}
                className="flex-1 size-full px-3 gap-14 flex items-center justify-between"
            >
                <p className="text-base text-text-secondary">{label}</p>

                <svg
                    className="size-5"
                    width="16"
                    height="13"
                    viewBox="0 0 16 13"
                    fill="none"
                    xmlns="http://www.w3.org/2000/svg"
                    aria-hidden
                >
                    <path
                        d="M8.66653 5.25H11.3332C11.824 5.25 12.2221 4.85816 12.2221 4.375C12.2221 3.89184 11.824 3.5 11.3332 3.5H8.69153C8.2007 3.5 7.80264 3.89184 7.80264 4.375C7.80264 4.85816 8.17486 5.25 8.66653 5.25ZM8.66653 8.75H13.111C13.6018 8.75 13.9999 8.35816 13.9999 7.875C13.9999 7.39184 13.6018 7 13.111 7H8.69153C8.2007 7 7.80264 7.39184 7.80264 7.875C7.80264 8.35816 8.17486 8.75 8.66653 8.75ZM8.66653 1.75H9.55542C10.0463 1.75 10.4193 1.35816 10.4193 0.875C10.4193 0.391836 10.0213 0 9.55542 0H8.66653C8.1757 0 7.77764 0.391836 7.77764 0.875C7.77764 1.35816 8.17486 1.75 8.66653 1.75ZM14.8887 10.5H8.69153C8.2007 10.5 7.80264 10.8918 7.80264 11.375C7.80264 11.8582 8.2007 12.25 8.69153 12.25H14.8887C15.3796 12.25 15.7776 11.8582 15.7776 11.375C15.7776 10.8918 15.3804 10.5 14.8887 10.5ZM5.12209 8.16758L4.22209 9.13555V0.87582C4.22209 0.391836 3.82486 0 3.3332 0C2.84153 0 2.44431 0.391836 2.44431 0.87582V9.13363L1.54431 8.16758C1.36898 7.97937 1.12931 7.88375 0.888476 7.88375C0.666133 7.88352 0.451843 7.96565 0.288198 8.11382C-0.0737463 8.44058 -0.097913 8.99484 0.233504 9.35167L2.65295 11.9791C2.98961 12.3417 3.62684 12.3417 3.96378 11.9791L6.38322 9.35167C6.71489 8.99484 6.69045 8.44085 6.32853 8.11382C6.01653 7.7875 5.45542 7.81211 5.12209 8.16758Z"
                        fill="white"
                    />
                </svg>
            </button>
        </div>
    );
}
