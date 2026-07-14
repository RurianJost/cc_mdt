import { AnimatePresence, motion } from "framer-motion";
import { SlideToConfirmDelete } from "@/components/";

type DeleteOfficerConfirmModalProps = {
    officerLabel: string;
    officerId: string;
    isDeleting?: boolean;
    onClose: () => void;
    onConfirm: () => void;
};

export function DeleteOfficerConfirmModal({
    officerLabel,
    officerId,
    isDeleting = false,
    onClose,
    onConfirm,
}: DeleteOfficerConfirmModalProps) {
    return (
       
            <div
                className="flex-1 flex w-full h-full bg-black/20 z-30 absolute inset-0 fullCenter"
            >
                <motion.div
                    initial={{ opacity: 0, scale: 0.96 }}
                    animate={{ opacity: 1, scale: 1 }}
                    exit={{ opacity: 0, scale: 0.96 }}
                    transition={{ duration: 0.2 }}
                    className="!p-9 !py-6 default-box w-[34rem] relative gap-4 flex flex-col"
                >
                    <button
                        type="button"
                        onClick={onClose}
                        disabled={isDeleting}
                        className="size-8 absolute -right-3 -top-3 rounded-full bg-white/5 hover:bg-white/10 text-text-secondary hover:text-white transition-colors fullCenter disabled:opacity-50"
                        aria-label="Fechar"
                    >
                        ✕
                    </button>

                    <div className="space-y-2">
                        <h2 className="text-2xl font-bold">Deseja deletar o cadastro?</h2>
                        <p className="text-lg font-normal text-text-secondary">
                            Essa ação é <b>irreversível</b>! Todos os dados vinculados ao oficial{" "}
                            <span className="text-white font-medium">{officerLabel}</span> de passaporte{" "}
                            <span className="text-white/60">{officerId}</span> serão apagados.
                        </p>
                    </div>

                    <div className="mt-2 flex flex-col gap-3">
                        <button
                            type="button"
                            onClick={onClose}
                            disabled={isDeleting}
                            className="h-12 w-full rounded-lg border-[.15rem] bg-white/5 border-white/20 font-bold text-lg text-white/90 hover:bg-white/10 transition-colors disabled:opacity-50"
                        >
                            Cancelar
                        </button>

                        <div className="relative">
                            <SlideToConfirmDelete onConfirm={onConfirm} disabled={isDeleting} />
                        </div>
                    </div>
                </motion.div>
            </div>
    );
}
