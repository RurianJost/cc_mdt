import defaultAvatar from "@/assets/defaultAvatar.png";
import { PageHeader } from "@/components";
import { useNuiEvent } from "@/hooks";
import { Communication } from "@/interfaces";
import { useUserSession } from "@/providers";
import { fetchNui } from "@/utils";
import clsx from "clsx";
import { useCallback, useEffect, useMemo, useState } from "react";

function AvatarUser({ avatarURL }: { avatarURL?: string | null }) {
  return (
    <div className="size-[3.2rem] relative shrink-0">
      <img
        src={avatarURL ?? defaultAvatar}
        alt=""
        className="size-full object-cover rounded-full border-[#3A3C40] border-solid"
      />
      <div className="size-3 bg-[#3A3C40] p-[.15rem] rounded-full fullCenter absolute right-0.5 bottom-0.5">
        <div className="size-full flex-1 rounded-full bg-green-500" />
      </div>
    </div>
  );
}

export default function Communications() {
  const { data: user } = useUserSession();
  const canSend = Boolean(user?.canManageOfficers);

  const [communications, setCommunications] = useState<Communication[]>([]);
  const [message, setMessage] = useState("");

  const loadAll = useCallback(async () => {
    const data = await fetchNui<Communication[]>("getAllCommunications", {}, []);
    if (!data) return;
    setCommunications(data ?? []);
  }, []);

  useEffect(() => {
    void loadAll();
  }, [loadAll]);

  useNuiEvent("newCommunicationMessage", (data?: Communication) => {
    if (!data) return;
    setCommunications((prev) => [...prev, data]);
  });
  useNuiEvent("updateAllCommunications", (data?: Communication[]) => {
    setCommunications(data ?? []);
  });

  const handleSend = useCallback(async () => {
    if (!canSend) return;
    const trimmed = message.trim();
    if (!trimmed) return;
    setMessage("");
    await fetchNui("sendCommunicationMessage", { message: trimmed });
  }, [canSend, message]);

  const emptyState = useMemo(() => communications.length === 0, [communications.length]);

  return (
    <div className="flex-1 pt-[3.3rem] px-[3.4rem] flex flex-col pb-[2.7rem] gap-5 min-h-0">
      <PageHeader
        title="Comunicados"
        description="Visualize os comunicados enviados pela corporação;"
      />

      <div className="default-box flex-1 flex flex-col !pb-6 !pt-8 !px-6 min-h-0 gap-5">
        <div className="flex-1 min-h-0 overflow-hidden rounded-xl bg-white/[2%] relative">
          <div className="w-full h-full overflow-y-auto overflow-x-hidden pr-1">
            <div className="flex flex-col gap-3 p-4">
              {emptyState ? (
                <div className="size-full absolute top-0 left-0 fullCenter">
                  <span className="text-text-secondary text-lg">
                    Nenhum comunicado ainda.
                  </span>
                </div>
              ) : (
                communications.map((item, idx) => (
                  <div key={`${item.id ?? "msg"}-${idx}`} className="flex gap-4">
                    <AvatarUser avatarURL={item.avatarURL} />
                    <div className="flex-1 min-w-0">
                      <h4 className="text-white font-medium text-xl">
                        {item.author}
                      </h4>
                      <p className="text-text-secondary font-normal text-base break-words">
                        {item.message}
                      </p>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>

        {canSend && (
          <div className="w-full bg-white/10 rounded-2xl relative flex items-center shrink-0 h-12">
            <input
              className="w-full flex-1 h-full bg-transparent text-text-secondary text-base px-4 pr-12"
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              onKeyDown={(e) => {
                if (e.key !== "Enter" || e.shiftKey) return;
                e.preventDefault();
                void handleSend();
              }}
              spellCheck={false}
              maxLength={255}
              placeholder="Envie seu comunicado;"
            />

            <button
              type="button"
              aria-label="Enviar comunicado"
              onClick={() => void handleSend()}
              className={clsx(
                "right-2 size-9 p-2 bg-blue-custom cursor-pointer aspect-square rounded-xl absolute fullCenter"
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
        )}
      </div>
    </div>
  );
}

