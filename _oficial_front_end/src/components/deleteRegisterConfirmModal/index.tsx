import { AnimatePresence, motion } from "framer-motion";

type DeleteRegisterConfirmModalProps = {
    isOpen: boolean;
    registerId: string;
    isDeleting?: boolean;
    onClose: () => void;
    onConfirm: () => void;
};

export function DeleteRegisterConfirmModal({
    isOpen,
    registerId,
    isDeleting = false,
    onClose,
    onConfirm,
}: DeleteRegisterConfirmModalProps) {
    return (
        <AnimatePresence>
            {isOpen && (
                <motion.div
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                    transition={{ duration: 0.2 }}
                    className="flex-1 flex w-full h-full bg-black/20 z-30 absolute inset-0 fullCenter"
                >
                    <motion.div
                        initial={{ opacity: 0, scale: 0.96 }}
                        animate={{ opacity: 1, scale: 1 }}
                        exit={{ opacity: 0, scale: 0.96 }}
                        transition={{ duration: 0.2 }}
                        className="!p-9 !py-6 default-box w-[28rem] relative gap-4 flex flex-col"
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
                            <h2 className="text-2xl font-bold">Excluir registro?</h2>
                            <p className="text-lg font-normal text-text-secondary">
                                Tem certeza que deseja excluir o boletim de ocorrência{" "}
                                <span className="text-white font-medium">Nº {registerId}</span>? Essa ação não poderá ser
                                desfeita.
                            </p>
                        </div>

                        <div className="mt-2 flex gap-4">
                            <button
                                type="button"
                                onClick={onClose}
                                disabled={isDeleting}
                                className="flex-1 h-12 rounded-lg border-[.15rem] bg-white/5 border-white/20 font-bold text-lg text-white/90 hover:bg-white/10 transition-colors disabled:opacity-50"
                            >
                                Cancelar
                            </button>
                            <button
                                type="button"
                                onClick={onConfirm}
                                disabled={isDeleting}
                                className="flex-1 h-12 rounded-lg bg-red-custom/90 hover:bg-red-custom font-bold text-lg text-white transition-colors disabled:opacity-50"
                            >
                                {isDeleting ? "Excluindo…" : "Excluir"}
                            </button>
                        </div>
                    </motion.div>
                </motion.div>
            )}
        </AnimatePresence>
    );
}
