
import policeLogo from "@/assets/policeLogo.png";
import { fetchNui } from "@/utils";
import { useEffect, useState } from "react";

export function PageHeader({ title, description }: { title?: string, description?: string }) {
    const [serverLogo, setServerLogo] = useState<string>("");

    const isImageValid = (image: string) => {
        return new Promise<boolean>((resolve, reject) => {
            const img = new Image();
            img.src = image;
            img.onload = () => {
                resolve(true);
            };
        });
    }

    useEffect(() => {
        fetchNui<string>("getServerLogo", {}, "https://via.placeholder.com/150",)
            .then(async (logo) => {
                const isValid = await isImageValid(logo);
                if (!isValid) {
                    setServerLogo("");
                } else {
                    setServerLogo(policeLogo);
                }
            });
    }, []);

    //         RegisterNUICallback('getServerLogo', function (data, callBack)
    //     callBack({
    //             logoURL = GENERAL_CONFIG.SERVER_LOGO_URL
    //         })
    // end)
    return (
        <header className="flex items-center justify-between">
            <div className="flex-col flex gap-0.5">
                {title && <h2 className="text-white text-3xl font-bold">{title}</h2>}
                {description && <h2 className="text-text-secondary font-normal text-2xl">{description}</h2>}
            </div>
            {serverLogo && <img
                src={serverLogo}
                className="size-[5.5rem] object-contain"
            />}
        </header>
    )
};