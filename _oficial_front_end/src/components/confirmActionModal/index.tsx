import { AnimatePresence, motion } from "framer-motion";
import { ReactNode } from "react";

type ConfirmActionModalProps = {
  isOpen: boolean;
  title: string;
  description: string;
  children?: ReactNode;
  confirmLabel: string;
  confirmVariant?: "danger" | "primary";
  isPending?: boolean;
  onClose: () => void;
  onConfirm: () => void;
};

export function ConfirmActionModal({
  isOpen,
  title,
  description,
  children,
  confirmLabel,
  confirmVariant = "primary",
  isPending = false,
  onClose,
  onConfirm,
}: ConfirmActionModalProps) {
  const confirmClass =
    confirmVariant === "danger"
      ? "bg-red-custom/90 hover:bg-red-custom"
      : "bg-blue-custom/90 hover:bg-blue-custom";

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
            className="!p-6 !py-6 default-box w-[30rem] relative gap-4 flex flex-col"
          >
            <button
              type="button"
              onClick={onClose}
              disabled={isPending}
              className="size-8 absolute -right-3 -top-3 rounded-full bg-white/5 hover:bg-white/10 text-text-secondary hover:text-white transition-colors fullCenter disabled:opacity-50"
              aria-label="Fechar"
            >
              ✕
            </button>

            <div className="space-y-2">
              <h2 className="text-2xl font-bold">{title}</h2>
              <p className="text-lg font-normal text-text-secondary">{description}</p>
            </div>

            {children}

            <div className="mt-2 flex gap-4">
              <button
                type="button"
                onClick={onClose}
                disabled={isPending}
                className="flex-1 h-12 rounded-lg border-[.15rem] bg-white/5 border-white/20 font-bold text-lg text-white/90 hover:bg-white/10 transition-colors disabled:opacity-50"
              >
                Cancelar
              </button>
              <button
                type="button"
                onClick={onConfirm}
                disabled={isPending}
                className={`flex-1 h-12 rounded-lg font-bold text-lg text-white transition-colors disabled:opacity-50 ${confirmClass}`}
              >
                {isPending ? "Aguarde…" : confirmLabel}
              </button>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}

