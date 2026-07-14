declare global {
  interface Window { GetParentResourceName: () => string; }
}

import { isEnvBrowser } from "./misc"

export async function fetchNui<T = any>(eventName: string, data?: any, mockData?: T, delay?: number) {
  const options = {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=UTF-8"
    },
    body: JSON.stringify(data)
  };

  if (isEnvBrowser())
    return new Promise((resolve) =>
      setTimeout(() =>
        resolve(mockData ? mockData : {} as T), delay ?? 400)
    ) as Promise<T>;

  const resourceName: string = window.GetParentResourceName
    ? window.GetParentResourceName()
    : "cc_mdt";


  const resp: Response = await fetch(`https://${resourceName}/${eventName}`, options);
  return await resp.json() as T;
};
