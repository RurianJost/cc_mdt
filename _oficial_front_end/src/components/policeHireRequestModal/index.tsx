import { useNuiEvent } from "@/hooks";
import { fetchNui } from "@/utils";
import clsx from "clsx";
import { AnimatePresence, motion } from "framer-motion";
import { useCallback, useEffect, useMemo, useState } from "react";

type PoliceHireRequestPayload = {
  title?: string;
  description?: string;
};

/**
 * Modal global (fora da NUI principal) para aceitar/recusar convite.
 *
 * Eventos NUI:
 * - `showRequest`: abre o modal (payload acima)
 * - `hideRequest`: fecha o modal
 *
 * Callbacks NUI:
 * - `respondPoliceHireRequest`: envia `{ accepted }`
 */
export function PoliceHireRequestModal() {
  const [queue, setQueue] = useState<PoliceHireRequestPayload[]>([]);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const current = queue[0] ?? null;

  const title = useMemo(() => {
    if (!current) return "";
    return current.title?.trim() ? current.title.trim() : "Convite";
  }, [current]);

  const message = useMemo(() => {
    if (!current) return "";
    return current.description?.trim() ? current.description.trim() : "";
  }, [current]);

  const closeCurrent = useCallback(() => {
    setQueue((prev) => prev.slice(1));
    setIsSubmitting(false);
  }, []);

  useNuiEvent<PoliceHireRequestPayload>("showRequest", (data?: PoliceHireRequestPayload) => {
    if (!data) return;
    setQueue((prev) => [...prev, data]);
  });

  useNuiEvent("hideRequest", () => {
    closeCurrent();
  });

  const respond = useCallback(
    async (accepted: boolean) => {
      if (!current || isSubmitting) return;
      setIsSubmitting(true);
      try {
        await fetchNui("respondPoliceHireRequest", { accepted }, undefined, 6000);
      } finally {
        closeCurrent();
      }
    },
    [closeCurrent, current, isSubmitting]
  );

  // useEffect(() => {
  //   if (!current) return;

  //   const onKeyDown = (e: KeyboardEvent) => {
  //     if (e.code === "Escape") {
  //       void respond(false);
  //     }
  //   };
  //   window.addEventListener("keydown", onKeyDown);
  //   return () => window.removeEventListener("keydown", onKeyDown);
  // }, [current, respond]);

  return (
    <AnimatePresence key="policeHireRequestModal" mode="wait">
      {!!current && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.2 }}
          className="fixed inset-0 z-[99999] bg-black/40 flex items-center justify-end pr-10"
        >
          <motion.div
            initial={{ scale: 0.98, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            exit={{ scale: 0.985, opacity: 0 }}
            transition={{ duration: 0.18 }}
            className="default-box w-[min(42rem,calc(100%-3rem))] !p-8 flex flex-col gap-4"
          >
            <div className="space-y-1">
              <h2 className="text-3xl font-bold">{title}</h2>
            </div>

            <div className="bg-black/20 rounded-lg p-4">
              <p className="text-base text-white/90 leading-relaxed">{message}</p>
            </div>

            <div className="flex items-center justify-end gap-3 pt-2 w-full">
              <button
                type="button"
                disabled={isSubmitting}
                onClick={() => void respond(false)}
                className={clsx(
                  "h-12 px-8 w-full rounded-lg border border-white/20 bg-white/5 hover:bg-white/10 transition-colors",
                  "text-white/90 font-bold disabled:opacity-60 disabled:cursor-default"
                )}
              >
                Recusar (U)
              </button>
              <button
                type="button"
                disabled={isSubmitting}
                onClick={() => void respond(true)}
                className={clsx(
                  "h-12 px-8 w-full rounded-lg bg-blue-custom hover:bg-blue-custom/90 transition-colors",
                  "text-white font-bold disabled:opacity-60 disabled:cursor-default"
                )}
              >
                Aceitar (Y)
              </button>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}

