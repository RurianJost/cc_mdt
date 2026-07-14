import type { DashboardExpandPanelId } from "@/interfaces";
import clsx from "clsx";
import type { ReactNode } from "react";
import { createPortal } from "react-dom";
import { FiMaximize2, FiMinimize2 } from "react-icons/fi";

export type ExpandableDashboardBoxProps = {
  boxId: DashboardExpandPanelId;
  title: string;
  expanded: DashboardExpandPanelId | null;
  onExpand: (id: DashboardExpandPanelId) => void;
  onCollapse: () => void;
  children: ReactNode;
};

export function ExpandableDashboardBox({
  boxId,
  title,
  expanded,
  onExpand,
  onCollapse,
  children,
}: ExpandableDashboardBoxProps) {
  const isOpen = expanded === boxId;


  const containerNUI = document.getElementById("app-content");
  if (!containerNUI) return null;

  return (
    <>
      <div
        className={clsx(
          "!px-6 !pb-6 default-box size-full flex flex-col gap-3.5 justify-between",
          isOpen && "invisible pointer-events-none"
        )}
      >
        <div className="flex items-center justify-between gap-2 shrink-0">
          <h2 className="text-white text-2xl font-bold">{title}</h2>
          <button
            type="button"
            aria-label="Expandir painel"
            onClick={() => onExpand(boxId)}
            className="text-white/90 hover:text-white p-1.5 rounded-lg hover:bg-white/10 transition-colors shrink-0"
          >
            <FiMaximize2 className="size-5" />
          </button>
        </div>
        {isOpen ? (
          <div className="flex-1 bg-white/[4%] rounded-md min-h-0" aria-hidden />
        ) : (
          children
        )}
      </div>
      {isOpen &&
        createPortal(
          <div className="absolute inset-0 z-[3000] flex items-center justify-center">
            <div
              className="absolute inset-0 bg-black/20 backdrop-blur-[2px]"
              onClick={onCollapse}
              aria-hidden
            />
            <div
              role="dialog"
              aria-modal="true"
              aria-labelledby={`expand-${boxId}-title`}
              className="relative z-[3001] !px-6 !pb-6 default-box flex flex-col gap-3.5 w-[min(52rem,calc(100%-3rem))] h-[min(58vh,38rem)] min-h-[18rem] overflow-hidden"
            >
              <div className="flex items-center justify-between gap-2 shrink-0">
                <h2 id={`expand-${boxId}-title`} className="text-white text-2xl font-bold">
                  {title}
                </h2>
                <button
                  type="button"
                  aria-label="Recolher painel"
                  onClick={onCollapse}
                  className="text-white/90 hover:text-white p-1.5 rounded-lg hover:bg-white/10 transition-colors shrink-0"
                >
                  <FiMinimize2 className="size-5" />
                </button>
              </div>
              <div className="flex-1 min-h-0 flex flex-col overflow-hidden">{children}</div>
            </div>
          </div>,
          containerNUI
        )}
    </>
  );
}
