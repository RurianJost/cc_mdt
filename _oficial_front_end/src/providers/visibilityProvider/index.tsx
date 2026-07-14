import React, { type Context, createContext, useContext, useEffect, useState } from "react"
import { useNavigate } from "react-router-dom"
import { fetchNui, isEnvBrowser } from "@/utils"
import { useNuiEvent } from "@/hooks"

const VisibilityCtx = createContext<VisibilityProviderValue | null>(null);

interface VisibilityProviderValue {
  setVisible: (visible: boolean) => void
  visible: boolean
}

export const VisibilityProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [visible, setVisible] = useState<boolean>(false);
  const navigate = useNavigate();

  useEffect(() => {
    navigate("/");
  }, []);

  useNuiEvent<boolean>("setVisible", (data: boolean) => {
    setVisible(data);
  });

  useEffect(() => {
    if (!visible) return

    const keyHandler = (e: KeyboardEvent): void => {
      if (["Escape"].includes(e.code)) {
        fetchNui("removeFocus");
        setVisible(!visible);
      }
    }

    window.addEventListener("keydown", keyHandler)
    return () => { window.removeEventListener("keydown", keyHandler) }
  }, [visible])

  useEffect(() => {
    isEnvBrowser() && setVisible(true);
  }, []);

  return (
    <VisibilityCtx.Provider
      value={{
        visible,
        setVisible
      }}
    >
      {visible && <>{children}</>}
    </VisibilityCtx.Provider>
  )
}

export const useVisibility = (): VisibilityProviderValue => useContext(VisibilityCtx as Context<VisibilityProviderValue>)
