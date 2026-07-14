/**
 * Config e conversão compatíveis com PolyZoneCreator (Leaflet CRS.Simple + tiles TMS).
 * Baseado no exemplo HTML fornecido.
 */

export const GTA_MAP_MIN_ZOOM = 0;
/** Zoom máximo da pirâmide de tiles usada no CRS (PolyZone / geração original). Não alterar sem retilar. */
const GTA_MAP_PYRAMID_MAX_ZOOM = 7;
export const GTA_MAP_MAX_RESOLUTION = 0.25;
export const GTA_MAP_MIN_RESOLUTION =
  Math.pow(2, GTA_MAP_PYRAMID_MAX_ZOOM) * GTA_MAP_MAX_RESOLUTION;
/** Zoom máximo no app (só precisamos dos níveis 0..este; tiles acima podem ser removidos do bundle). */
export const GTA_MAP_MAX_ZOOM = 3;

export const GTA_MAP_CENTER_LAT = -5525;
export const GTA_MAP_CENTER_LNG = 3755;
export const GTA_OFFSET = 0.66;

export const GTA_MAP_BOUNDS: [[number, number], [number, number]] = [
  [-8192, 0],
  [0, 8192],
];

// Leaflet latlng -> GTA coords (x,y) (útil para debug)
export function latlngToGTA(lat: number, lng: number): [number, number] {
  const x = (lng - GTA_MAP_CENTER_LNG) / GTA_OFFSET;
  const y = (lat - GTA_MAP_CENTER_LAT) / GTA_OFFSET;
  return [Number(x.toFixed(2)), Number(y.toFixed(2))];
}

// GTA coords (x,y) -> Leaflet latlng
export function gtaToLatLng(x: number, y: number): [number, number] {
  const lng = x * GTA_OFFSET + GTA_MAP_CENTER_LNG;
  const lat = y * GTA_OFFSET + GTA_MAP_CENTER_LAT;
  return [lat, lng];
}
