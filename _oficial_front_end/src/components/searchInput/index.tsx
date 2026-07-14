import { ChangeEventHandler } from "react";

export function SearchInput({ value, onChange }: { value: string, onChange: ChangeEventHandler<HTMLInputElement> }) {
    return (
        <div className="flex-1 h-full bg-black/20 relative flex  items-center rounded-lg">
            <input
                className="w-full flex-1 h-full px-4 pr-12 bg-transparent text-base text-text-secondary"
                spellCheck={false}
                value={value}
                onChange={onChange}
                maxLength={255}
                placeholder="Busca por passaporte ou nº do boletim;"
            />

            <svg className="size-6 absolute right-4" width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M6.25 11.25C7.35936 11.2498 8.43675 10.8784 9.31063 10.195L12.0581 12.9425L12.9419 12.0588L10.1944 9.31125C10.8781 8.43729 11.2497 7.35965 11.25 6.25C11.25 3.49313 9.00688 1.25 6.25 1.25C3.49313 1.25 1.25 3.49313 1.25 6.25C1.25 9.00688 3.49313 11.25 6.25 11.25ZM6.25 2.5C8.31812 2.5 10 4.18187 10 6.25C10 8.31812 8.31812 10 6.25 10C4.18187 10 2.5 8.31812 2.5 6.25C2.5 4.18187 4.18187 2.5 6.25 2.5Z" fill="white" />
            </svg>
        </div>
    )
}