import { ModifierPenalCodeItem, PenalCodeItem } from "@/interfaces";
import { fetchNui } from "@/utils";
import React, { type Context, createContext, useContext, useEffect, useState } from "react";

const Context = createContext<CrimesProviderValue | null>(null);

interface CrimesProviderValue {
  crimes: PenalCodeItem[]
  attenuants: ModifierPenalCodeItem[]
  aggravants: ModifierPenalCodeItem[]
}


export const NUICrimesProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [crimes, setCrimes] = useState<PenalCodeItem[]>([])
  const [attenuants, setAttenuants] = useState<ModifierPenalCodeItem[]>([])
  const [aggravants, setAggravants] = useState<ModifierPenalCodeItem[]>([])

  const updateCrimes = async () => {
    const response = await fetchNui<{
      data: PenalCodeItem[],
      attenuants: ModifierPenalCodeItem[]
      aggravants: ModifierPenalCodeItem[]
    }>("getPenalCodes", {}, {
      data: [
        {
          id: "ART_11",
          article: "I",
          description: "desacato a funcionário público",
          sentence: 15,
          fine: 0,
        },
        {
          id: "ART_12",
          article: "I",
          description: "latrocinio",
          sentence: 15,
          fine: 50000,
        },
      ],
      attenuants: [
        {
          id: "ART_14",
          percentage: -40,
          description: "latrocinio",
        },
      ],
      aggravants: [
        {
          id: "ART_15",
          percentage: -40,
          description: "latrocinio",
        },
      ],
    });

    if (!response) return;

    setCrimes(response.data ?? []);
    setAttenuants(response.attenuants ?? []);
    setAggravants(response.aggravants ?? []);
  };

  useEffect(() => {
    updateCrimes();
  }, [])
  return (
    <Context.Provider
      value={{
        crimes,
        attenuants,
        aggravants
      }}
    >
      <>{children}</>
    </Context.Provider>
  )
}

export const useCrimesProvider = (): CrimesProviderValue => useContext(Context as Context<CrimesProviderValue>)
