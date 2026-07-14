import en from '@/locales/en.json'
import es from '@/locales/es.json'
import fr from '@/locales/fr.json'
import it from '@/locales/it.json'
import ptBR from '@/locales/pt-BR.json'
import { UserSessionProvider, VisibilityProvider } from "@/providers"
import "@/styles/global.css"
import i18next from 'i18next'
import Backend from 'i18next-http-backend'
import { createRoot } from "react-dom/client"
import { useEffect, useMemo, useState } from "react"
import { initReactI18next } from 'react-i18next'
import { BrowserRouter } from 'react-router-dom'
import { Router } from "./components"
import { NUICrimesProvider } from './providers/crimesProvider'
import { PoliceHireRequestModal } from "./components/policeHireRequestModal"
import { useNuiEvent } from "./hooks/use-nui-event"
import { debugData } from './utils'

const PrisionInfos = () => {
  const [isOpen, setIsOpen] = useState<boolean>(false);
  const [sentence, setSentence] = useState<number>(0);

  useNuiEvent<{ sentence: number }>("showSentence", (data) => {
    if (!data?.sentence) return;
    const next = Number(data?.sentence ?? 0)
    setSentence(Number.isFinite(next) ? next : 0)
    setIsOpen(true)
  })

  useNuiEvent("hideSentence", () => {
    setIsOpen(false)
  });

  const formatted = useMemo(() => {
    const raw = Math.max(0, Math.trunc(sentence))
    if (raw < 1000) {
      return { prefix: "00", value: String(raw).padStart(2, "0") }
    }
    return { prefix: "", value: String(raw) }
  }, [sentence]);

  return (
    <div className="fixed left-1/2 top-8 z-[99999] touch-none -translate-x-1/2 pointer-events-none">
      <div
        className={[
          "flex items-center gap-10",
          "transition-all duration-200 ease-out",
          isOpen ? "opacity-100 translate-y-0" : "opacity-0 -translate-y-2",
        ].join(" ")}
        aria-hidden={!isOpen}
      >
        <svg className='h-24' viewBox="0 0 65 61" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path
            d="M58.52 12.0633C52.6167 6.12792 43.7938 4.90875 36.6392 8.30958L33.5592 5.22958C33.2624 4.93216 32.9098 4.6962 32.5217 4.5352C32.1335 4.3742 31.7175 4.29133 31.2973 4.29133C30.8771 4.29133 30.461 4.3742 30.0729 4.5352C29.6848 4.6962 29.3322 4.93216 29.0354 5.22958L28.7788 5.51833C28.3296 2.40625 25.6667 0 22.4583 0C18.9292 0 16.0417 2.8875 16.0417 6.41667C16.0417 6.70542 16.0417 6.99417 16.1379 7.25083C14.1808 8.37375 12.8333 10.4271 12.8333 12.8333C12.8333 14.3092 13.3467 15.6246 14.1808 16.7154C13.7693 16.9987 13.4319 17.3769 13.1974 17.8181C12.9629 18.2592 12.838 18.7504 12.8333 19.25V23.5813C5.35792 26.2121 0 33.3346 0 41.7083C0 52.3279 8.63042 60.9583 19.25 60.9583C29.8696 60.9583 38.5 52.3279 38.5 41.7083C38.5001 37.7302 37.2657 33.85 34.9671 30.6032C32.6685 27.3564 29.4189 24.9029 25.6667 23.5813V19.25C25.662 18.7504 25.5371 18.2592 25.3026 17.8181C25.0681 17.3769 24.7307 16.9987 24.3192 16.7154C25.1533 15.6246 25.6667 14.3092 25.6667 12.8333C25.6667 12.5446 25.6667 12.2558 25.5704 11.9992C26.1479 11.6783 26.6292 11.2292 27.0463 10.8442C30.03 12.4483 32.0833 15.5925 32.0833 19.25V19.5067C32.5004 19.7313 32.8854 20.0521 33.3025 20.3088C33.9121 18.9613 34.7463 17.6458 35.8371 16.5871C38.2475 14.1836 41.5127 12.8339 44.9167 12.8339C48.3207 12.8339 51.5858 14.1836 53.9963 16.5871C56.3998 18.9975 57.7495 22.2627 57.7495 25.6667C57.7495 29.0707 56.3998 32.3358 53.9963 34.7463C51.4296 37.3129 48.125 38.5 44.6921 38.5C44.9167 39.5267 44.9167 40.6175 44.9167 41.7083C44.9167 42.7992 44.8204 43.8579 44.6921 44.9167C49.7292 44.9167 54.7021 43.0879 58.52 39.27C60.3123 37.4869 61.7345 35.3672 62.705 33.0326C63.6755 30.6981 64.1751 28.1949 64.1751 25.6667C64.1751 23.1385 63.6755 20.6352 62.705 18.3007C61.7345 15.9662 60.3123 13.8465 58.52 12.0633ZM22.4583 3.20833C24.2229 3.20833 25.6667 4.65208 25.6667 6.41667C25.6667 7.47542 25.1213 8.37375 24.3192 8.95125C23.1642 7.41125 21.3354 6.41667 19.25 6.41667C19.25 4.65208 20.6938 3.20833 22.4583 3.20833ZM17.3892 10.2988C18.5442 11.8388 20.3729 12.8333 22.4583 12.8333C22.4583 14.5979 21.0146 16.0417 19.25 16.0417C17.4854 16.0417 16.0417 14.5979 16.0417 12.8333C16.0417 11.7746 16.5871 10.8763 17.3892 10.2988ZM32.0833 41.7083C32.0833 48.7988 26.3404 54.5417 19.25 54.5417C12.1596 54.5417 6.41667 48.7988 6.41667 41.7083C6.41667 34.6179 12.1596 28.875 19.25 28.875C26.3404 28.875 32.0833 34.6179 32.0833 41.7083Z"
            fill="#fff"
          />
        </svg>

        <div className="flex flex-col fullCenter">
          <div
            className="font-bold text-7xl text-white tracking-wide"
            style={{
              fontFamily: "Montserrat"
            }}
          >
            {formatted.prefix && <span className="opacity-30">{formatted.prefix}</span>}
            <span>{formatted.value}</span>
          </div>
          <div
            className="text-[2.8rem] font-medium tracking-[23%] text-white/95"
            style={{
              fontFamily: "Montserrat"
            }}
          >
            MESES
          </div>
        </div>
      </div>
    </div>
  )
}

i18next
  .use(initReactI18next)
  .use(Backend)
  .init({
    resources: {
      'pt-BR': {
        translation: ptBR,
      },
      en: {
        translation: en,
      },
      fr: {
        translation: fr,
      },
      it: {
        translation: it,
      },
      es: {
        translation: es,
      },
    },
    fallbackLng: 'pt-BR',
    // debug: true,
  })
  ; ('')

const rootEl = document.getElementById("root")
rootEl && createRoot(rootEl!)
  .render(
    <>
      <BrowserRouter>
        <PoliceHireRequestModal />
        <PrisionInfos />
        <VisibilityProvider>
          <UserSessionProvider>
            <NUICrimesProvider>
              <Router />
            </NUICrimesProvider>
          </UserSessionProvider>
        </VisibilityProvider>
      </BrowserRouter>
    </>
  );
