export const isEnvBrowser = (): boolean => !(window as any).invokeNative
export const noop = (): any => {}
export const randomAvatar = () => `https://api.dicebear.com/8.x/bottts-neutral/svg?seed=${Math.random()}`
export function formatCurrencyBRL(value: number): string {
  return value.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
}

export const sortOptions = [
    { title: "Padrão", key: "date_desc_default" },
    { title: "Mais recente", key: "date_desc" },
    { title: "Mais antigo", key: "date_asc" },

    { title: "A-Z (Nome)", key: "name_asc" },
    { title: "Z-A (Nome)", key: "name_desc" },

    { title: "Maior sentença", key: "sentence_desc" },
    { title: "Menor sentença", key: "sentence_asc" },

    { title: "Maior multa", key: "fine_desc" },
    { title: "Menor multa", key: "fine_asc" },
]
export const parseBRDateToTime = (dateStr: string): number => {
    if (!dateStr) return 0;
    const [datePart, timePart] = dateStr.split(" ")
    const [day, month, year] = datePart.split("/")
    const [hour, minute] = timePart.split(":")

    const date = new Date(
        Number(year),
        Number(month) - 1, // mês começa em 0
        Number(day),
        Number(hour),
        Number(minute)
    )

    return date.getTime()
};