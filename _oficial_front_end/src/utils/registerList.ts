import { IRegisterItem } from "@/interfaces";
import { parseBRDateToTime } from "@/utils/misc";

export function normalizeRegisterSearchInput(raw: string): string {
    let value = raw.replace(/\s+/g, " ");
    value = value.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
    value = value.replace(/[^a-zA-Z0-9 ]/g, "");
    return value.toLowerCase();
}

export function filterSortRegisters(
    registers: IRegisterItem[],
    sort: string,
    searchQuery: string
): IRegisterItem[] {
    const sorted = [...registers];

    const getList = (): IRegisterItem[] => {
        switch (sort) {
            case "date_desc":
                return sorted.sort(
                    (a, b) => parseBRDateToTime(b.formattedDate) - parseBRDateToTime(a.formattedDate)
                );
            case "date_asc":
                return sorted.sort(
                    (a, b) => parseBRDateToTime(a.formattedDate) - parseBRDateToTime(b.formattedDate)
                );
            case "name_asc":
                return sorted.sort((a, b) => a.suspect.name.localeCompare(b.suspect.name));
            case "name_desc":
                return sorted.sort((a, b) => b.suspect.name.localeCompare(a.suspect.name));
            case "sentence_desc":
                return sorted.sort((a, b) => b.sentence - a.sentence);
            case "sentence_asc":
                return sorted.sort((a, b) => a.sentence - b.sentence);
            case "fine_desc":
                return sorted.sort((a, b) => b.fine - a.fine);
            case "fine_asc":
                return sorted.sort((a, b) => a.fine - b.fine);
            default:
                return [...registers];
        }
    };

    const q = searchQuery?.toLowerCase() ?? "";
    return getList().filter(
        e =>
            e.suspect.id?.toLowerCase().includes(q) ||
            e.police.id?.toLowerCase().includes(q) ||
            e.id.toLowerCase().includes(q)
    );
}
