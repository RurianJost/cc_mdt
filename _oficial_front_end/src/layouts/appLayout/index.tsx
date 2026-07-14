import background from "@/assets/bg.png";
import { SideBar } from "@/components";
import clsx from "clsx";
import { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { Outlet, useSearchParams } from "react-router-dom";
import { Toaster } from "sonner";

export function AppLayout() {
    const { i18n } = useTranslation()
    const [settings, setSettings] = useState<any>(null);
    // const { isAuth } = useUserSession();
    const [searchParams, setSearchParams] = useSearchParams();
    const hidden = searchParams.get("hidden") === "true";
    useEffect(() => {
        if (i18n && settings?.language && i18n.resolvedLanguage !== settings.language)
            i18n.changeLanguage(settings.language)
    }, [settings]);

    return (
        <div id="app"
            className={clsx(
                hidden && "!hidden",
                "w-[111.7rem] border-none flex h-[75.4rem] pt-[12.7rem] bg-cover bg-no-repeat pb-[13rem] px-[11.4rem]"
            )}
            style={{
                backgroundImage: `url(${background})`,
            }}
        >
            <div id="app-content" className="flex-1 flex bg-[#373840] relative overflow-hidden">
                <Toaster
                    position="top-center"
                    richColors
                    expand={false}
                    theme="dark"
                />
                {/* {isAuth && (
                )} */}
                <SideBar />
                <Outlet />
                <div className="bg-gradient-to-bl from-white opacity-10 to-white/0 h-[56.4rem] w-[41.1rem] pointer-events-none -right-16 -bottom-12 absolute -rotate-[10deg]" />
            </div>
        </div>
    )
}