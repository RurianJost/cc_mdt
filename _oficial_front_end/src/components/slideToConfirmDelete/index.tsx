import { animate, motion, useMotionValue, useTransform } from "framer-motion";
import { useLayoutEffect, useRef, useState } from "react";

export type SlideToConfirmDeleteProps = {
  onConfirm: () => void;
  disabled: boolean;
};

export function SlideToConfirmDelete({ onConfirm, disabled }: SlideToConfirmDeleteProps) {
  const trackRef = useRef<HTMLDivElement>(null);
  const x = useMotionValue(0);
  const [maxDrag, setMaxDrag] = useState(0);
  const progress = useTransform(x, [0, Math.max(1, maxDrag) * 0.88], [0, 1], { clamp: true });
  const labelOpacity = useTransform(progress, [0, 1], [0.45, 1]);
  const labelAlpha = useTransform(progress, [0, 1], [0.45, 1]);

  useLayoutEffect(() => {
    const el = trackRef.current;
    if (!el) return;
    const update = () => {
      const handleW = 44;
      const pad = 8;
      const w = el.offsetWidth;
      setMaxDrag(Math.max(0, w - handleW - pad * 2));
    };
    update();
    const ro = new ResizeObserver(update);
    ro.observe(el);
    return () => ro.disconnect();
  }, []);

  const handleDragEnd = () => {
    if (disabled || maxDrag <= 0) return;
    const current = x.get();
    if (current >= maxDrag * 0.88) {
      onConfirm();
    } else {
      animate(x, 0, { type: "spring", stiffness: 450, damping: 50, mass: 0.9 });
    }
  };

  return (
    <div
      ref={trackRef}
      className={`relative h-[3.25rem] w-full select-none overflow-hidden flex items-center rounded-xl bg-red-custom shadow-inner ${
        disabled ? "pointer-events-none opacity-45" : ""
      }`}
    >
      <motion.span
        className="pointer-events-none absolute inset-0 flex items-center justify-center text-lg font-semibold tracking-wide transition-opacity duration-200"
        style={{
          opacity: labelOpacity,
          color: useTransform(labelAlpha, (a) => `rgba(255,255,255,${a})`),
        }}
      >
        Confirmar
      </motion.span>

      <div
        className="pointer-events-none absolute right-2.5 h-9 w-9 rounded-lg border-2 border-white/20 bg-white/10"
        aria-hidden
      />

      <motion.div
        style={{ x }}
        drag={disabled ? false : "x"}
        dragConstraints={{ left: 0, right: maxDrag }}
        dragElastic={0.12}
        dragMomentum={false}
        dragTransition={{ power: 0.05, timeConstant: 120 }}
        onDragEnd={handleDragEnd}
        className="absolute left-2.5  flex size-8 cursor-grab items-center justify-center rounded-xl bg-white/10 shadow-md active:cursor-grabbing"
        whileTap={disabled ? undefined : { scale: 0.98 }}
      >
        <svg className="size-[1.8rem] text-zinc-600" width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden>
          <path
            d="M9 6l6 6-6 6"
            stroke="currentColor"
            strokeWidth="2.2"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      </motion.div>
    </div>
  );
}

