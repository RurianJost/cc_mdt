import { isEnvBrowser } from "./misc"

interface DebugEvent<T = any> {
  action: string
  data: T
  timer?: number
}

export const debugData = <P>(events: Array<DebugEvent<P>>, timer = 1000): void => {
  if (import.meta.env.MODE === "development" && isEnvBrowser()) {
    for (const event of events) {
      setTimeout(() => {
        window.dispatchEvent(
          new MessageEvent("message", {
            data: {
              action: event.action,
              data: event.data
            }
          })
        );
      }, event.timer || timer)
    }
  }
}
