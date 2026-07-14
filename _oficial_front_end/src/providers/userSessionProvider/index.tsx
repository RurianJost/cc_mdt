import { useNuiEvent } from "@/hooks";
import { User } from "@/interfaces";
import { fetchNui } from "@/utils";
import React, { type Context, createContext, useContext, useEffect, useState } from "react";

const DEFAULT_PANEL_PRIMARY_COLOR = "#7289DA";
const HEX_COLOR_PATTERN = /^#([0-9a-f]{6})$/i;

const getColorChannels = (color?: string): string => {
  const match = (color || "").match(HEX_COLOR_PATTERN);
  const hex = match?.[1] || DEFAULT_PANEL_PRIMARY_COLOR.slice(1);

  return [0, 2, 4]
    .map((offset) => Number.parseInt(hex.slice(offset, offset + 2), 16))
    .join(" ");
};

const Context = createContext<UserProviderValue | null>(null);
type IUserData = User | null

interface UserProviderValue {
  data?: IUserData
  isAuth: boolean
}


export const UserSessionProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [userData, setUserData] = useState<IUserData>(null);

  useNuiEvent<IUserData>("updateUserData", (data?: IUserData) => {
    if (!data) return;
    setUserData(data ?? null);
  });

  useEffect(() => {
    fetchNui<IUserData>("getUserData", {}, {
      avatarURL: `https://api.dicebear.com/8.x/bottts-neutral/svg?seed=${Math.random()}`,
      id: "",
      name: "Rodrigo carioca",
      policeRank: "Sem patente",
      canManageOfficers: true,
      serviceTime: "asdasdasd",
      organization: "22 BPM",
      panelLogoURL: "",
      panelPrimaryColor: DEFAULT_PANEL_PRIMARY_COLOR,
    }).then(data => {
      setUserData(data ?? null);
    })
  }, []);

  useEffect(() => {
    document.documentElement.style.setProperty(
      "--panel-primary",
      getColorChannels(userData?.panelPrimaryColor)
    );
  }, [userData?.panelPrimaryColor]);

  return (
    <Context.Provider
      value={{
        data: userData,
        isAuth: !!userData
      }}
    >
      <>{children}</>
    </Context.Provider>
  )
}

export const useUserSession = (): UserProviderValue => useContext(Context as Context<UserProviderValue>)
