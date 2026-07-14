
import policeLogo from "@/assets/policeLogo.png";
import { useUserSession } from "@/providers";
import { useEffect, useState } from "react";

const isImageValid = (image: string) => {
    return new Promise<boolean>((resolve) => {
        if (!image) {
            resolve(false);
            return;
        }

        const img = new Image();
        img.onload = () => resolve(true);
        img.onerror = () => resolve(false);
        img.src = image;
    });
};

export function PageHeader({ title, description }: { title?: string, description?: string }) {
    const { data: user } = useUserSession();
    const [serverLogo, setServerLogo] = useState<string>(policeLogo);

    useEffect(() => {
        let isActive = true;

        isImageValid(user?.panelLogoURL || "").then((isValid) => {
            if (isActive) {
                setServerLogo(isValid ? user?.panelLogoURL || policeLogo : policeLogo);
            }
        });

        return () => {
            isActive = false;
        };
    }, [user?.panelLogoURL]);

    return (
        <header className="flex items-center justify-between">
            <div className="flex-col flex gap-0.5">
                {title && <h2 className="text-white text-3xl font-bold">{title}</h2>}
                {description && <h2 className="text-text-secondary font-normal text-2xl">{description}</h2>}
            </div>
            {serverLogo && <img
                src={serverLogo}
                alt={user?.organization ? `Logo ${user.organization}` : "Logo da organização"}
                className="size-[5.5rem] object-contain"
            />}
        </header>
    )
};
