import defaultAvatar from "@/assets/defaultAvatar.png";
import { formatCurrencyBRL } from "@/utils"

export function EndRegisterForm({ photoURL, suspect, totalMonth, finalFine }: {
    photoURL: string | null
    suspect: {
        id: string
        name: string
    }
    finalFine?: number
    totalMonth: number
}) {
    return (
        <div className="w-full default-box !px-6 !flex-1 flex flex-col gap-3">
            <h2 className="text-white text-2xl font-bold">Resumo</h2>
            <div className="flex flex-col items-center flex-1">

                <div className="w-52 h-52 border border-white/30 rounded-md flex items-center justify-center">
                    <img
                        src={photoURL ?? defaultAvatar}
                        alt="Foto"
                        className="w-full h-full object-cover rounded-md"
                    />
                </div> 
                
                <div className="flex-1 w-full flex items-center justify-around">
                    <div className="flex flex-col fullCenter">
                        <span className="text-gray-400 text-sm">Indivíduo</span>
                        <span className="text-white text-2xl font-semibold capitalize">
                            {suspect.name} #{suspect.id}
                        </span>
                    </div>

                    <div className="flex flex-col fullCenter">
                        <span className="text-gray-400 text-sm">Sentença</span>
                        <span className="text-white text-2xl font-semibold">
                            {totalMonth} meses
                        </span>
                    </div>

                    <div className="flex flex-col fullCenter">
                        <span className="text-gray-400 text-sm">Multa</span>
                        <span className="text-white text-2xl font-semibold">
                            {formatCurrencyBRL(finalFine ?? 0)}
                        </span>
                    </div>

                </div>
            </div>
        </div>

    )
}