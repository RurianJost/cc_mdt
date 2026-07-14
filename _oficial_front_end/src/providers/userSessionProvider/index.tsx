import { useNuiEvent } from "@/hooks";
import { User } from "@/interfaces";
import { fetchNui } from "@/utils";
import React, { type Context, createContext, useContext, useEffect, useState } from "react";

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
    }).then(data => {
      setUserData(data ?? null);
    })
  }, []);

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
