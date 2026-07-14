import defaultAvatar from "@/assets/defaultAvatar.png";
import { Communication, CommunicationsCardProps } from "@/interfaces";
import { fetchNui } from "@/utils";
import clsx from "clsx";
import { createPortal } from "react-dom";
import { FiMaximize2, FiMinimize2 } from "react-icons/fi";
import { useCallback, useState } from "react";

const AvatarUserModel = ({ avatarURL }: { avatarURL?: string }) => {
  return (
    <div className="size-[3.2rem] relative">
      <img
        src={avatarURL ?? defaultAvatar}
        className="size-full object-cover rounded-full border-[#3A3C40] border-solid"
      />

      <div className="size-3 bg-[#3A3C40] p-[.15rem] rounded-full fullCenter absolute right-0.5 bottom-0.5">
        <div className="size-full flex-1 rounded-full bg-green-500" />
      </div>
    </div>
  );
};

function CommunicationsCardContent({
  title,
  communications,
  expandable,
  isModal,
  onExpand,
  onCollapse,
}: {
  title: string;
  communications?: Communication[];
  expandable?: boolean;
  isModal: boolean;
  onExpand?: () => void;
  onCollapse?: () => void;
}) {
  const [message, setMessage] = useState("");

  const handleSend = useCallback(async () => {
    const trimmed = message.trim();
    if (!trimmed) return;

    setMessage("");
    await fetchNui("sendChatMessage", { message: trimmed });
  }, [message]);

  return (
    <div
      className={clsx(
        "!px-6 default-box flex flex-col gap-2 justify-between",
        isModal
          ? "size-full max-h-full min-h-0 flex-1 overflow-hidden rounded-2xl p-6"
          : "size-full pb-6"
      )}
    >
      <div className="flex items-center justify-between gap-2 shrink-0">
        <h2
          id={isModal ? "communications-expanded-title" : undefined}
          className={clsx(
            "text-white font-bold",
            isModal ? "text-[2.4rem] tracking-tight" : "text-2xl"
          )}
        >
          {title}
        </h2>
        {expandable && (
          <button
            type="button"
            aria-label={isModal ? "Recolher painel" : "Expandir painel"}
            onClick={isModal ? onCollapse : onExpand}
            className="text-white/90 hover:text-white p-1.5 rounded-lg hover:bg-white/10 transition-colors shrink-0"
          >
            {isModal ? <FiMinimize2 className="size-5" /> : <FiMaximize2 className="size-5" />}
          </button>
        )}
      </div>
      <div className={clsx("w-full shrink-0", isModal ? "h-px bg-white/10 mb-5 mt-1" : "h-1 bg-white/10")} />

      <div
        className={clsx(
          "flex-1 rounded-md relative min-h-0",
          isModal ? "overflow-y-auto" : "max-h-[10.5rem]"
        )}
      >
        <div className={clsx("w-full h-full overflow-x-hidden flex flex-col", isModal ? "gap-3" : "gap-2.5")}>
          {communications?.map((item, index) => (
            <div key={index} className={clsx("flex w-fit", isModal ? "gap-3" : "gap-4")}>
              <AvatarUserModel avatarURL={item.avatarURL} />
              <div className="flex-1">
                <h4
                  className={clsx(
                    "text-white font-medium",
                    isModal ? "text-[1.8rem]" : "text-xl"
                  )}
                >
                  {item.author}
                </h4>
                <h4
                  className={clsx(
                    "text-text-secondary font-normal text-wrap",
                    isModal ? "text-[1.5rem] leading-snug" : "text-base"
                  )}
                >
                  {item.message}
                </h4>
              </div>
            </div>
          ))}
        </div>
      </div>

      <div
        className={clsx(
          "w-full bg-white/10 rounded-2xl mt-1 relative flex items-center shrink-0",
          isModal ? "h-[4.2rem] rounded-xl bg-white/10" : "h-10"
        )}
      >
        <input
          className={clsx(
            "w-full flex-1 h-full bg-transparent text-text-secondary",
            isModal ? "text-[1.5rem] px-6 pr-20" : "text-base px-4 pr-12"
          )}
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          onKeyDown={(e) => {
            if (e.key !== "Enter" || e.shiftKey) return;
            e.preventDefault();
            handleSend();
          }}
          spellCheck={false}
          maxLength={255}
          placeholder="Envie seu comunicado;"
        />

        <button
          type="button"
          aria-label="Enviar comunicado"
          onClick={handleSend}
          className={clsx(
            isModal ? "!right-4 size-10 p-2.5" : " right-1.5 size-[1.9rem] p-2",
            "bg-blue-custom cursor-pointer aspect-square rounded-xl absolute fullCenter"
          )}
        >
          <svg
            className="size-full flex-1"
            width="11"
            height="11"
            viewBox="0 0 11 11"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="M10.3667 0.127415C10.3077 0.0686471 10.2331 0.0279584 10.1517 0.0101329C10.0703 -0.00769254 9.98555 -0.00191367 9.90734 0.0267901L0.282342 3.52679C0.199334 3.55828 0.127869 3.61427 0.077439 3.68733C0.0270088 3.7604 0 3.84707 0 3.93585C0 4.02463 0.0270088 4.11131 0.077439 4.18437C0.127869 4.25744 0.199334 4.31343 0.282342 4.34492L4.04047 5.84554L6.81422 3.06304L7.43109 3.67992L4.64422 6.46679L6.14922 10.2249C6.18164 10.3063 6.23775 10.3761 6.3103 10.4253C6.38284 10.4744 6.46847 10.5006 6.55609 10.5005C6.6445 10.4987 6.73029 10.4702 6.80214 10.4186C6.874 10.3671 6.92854 10.295 6.95859 10.2118L10.4586 0.58679C10.4884 0.509386 10.4956 0.425103 10.4793 0.343769C10.4631 0.262435 10.424 0.187401 10.3667 0.127415Z"
              fill="white"
            />
          </svg>
        </button>
      </div>
    </div>
  );
}

export function CommunicationsCard({
  title = "Chat",
  communications,
  expandable,
  expanded,
  onExpand,
  onCollapse,
}: CommunicationsCardProps) {

  const containerNUI = document.getElementById("app-content");
  if (!containerNUI) return null;
  return (
    <>
      <div
        className={clsx(
          "size-full flex flex-col min-h-0",
          expanded && " pointer-events-none"
        )}
      >
        <CommunicationsCardContent
          title={title}
          communications={communications}
          expandable={expandable}
          isModal={false}
          onExpand={onExpand}
          onCollapse={onCollapse}
        />
      </div>
      {expanded &&
        onCollapse &&
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
              aria-labelledby="communications-expanded-title"
              className="relative z-[9999] flex flex-col w-[min(52rem,calc(100%-3rem))] h-[min(58vh,38rem)] min-h-[18rem]"
            >
              <CommunicationsCardContent
                title={title}
                communications={communications}
                expandable={expandable}
                isModal
                onExpand={onExpand}
                onCollapse={onCollapse}
              />
            </div>
          </div>,
          containerNUI
        )}
    </>
  );
}
