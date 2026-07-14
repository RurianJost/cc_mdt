import { OfficersMapBlip } from "@/interfaces";
import { useNuiEvent } from "@/hooks";
import { fetchNui, isEnvBrowser } from "@/utils";
import {
  GTA_MAP_BOUNDS,
  GTA_MAP_CENTER_LAT,
  GTA_MAP_CENTER_LNG,
  GTA_MAP_MAX_ZOOM,
  GTA_MAP_MIN_RESOLUTION,
  GTA_MAP_MIN_ZOOM,
  gtaToLatLng,
} from "@/utils/gtaMapCoords";
import L from "leaflet";
import "leaflet/dist/leaflet.css";
import { useCallback, useEffect, useMemo, useState } from "react";
import { CircleMarker, MapContainer, Popup, TileLayer, useMap } from "react-leaflet";

const MOCK_OFFICERS: OfficersMapBlip[] = [
  // { id: "1", name: "Oficial Demo", coords: { x: 195.2, y: -933.8, z: 30.7 } },
  { id: "2", name: "Patrulha Centro", coords: { x: -1100.4, y: -2808.2, z: 27.3 }, color: "#1e40af" },
  { id: "3", name: "Aeroporto", coords: { x: -1037.2, y: -2737.8, z: 20.2 }, color: "#1e40af" },
];

function FitBounds() {
  const map = useMap();
  useEffect(() => {
    map.setMaxBounds(GTA_MAP_BOUNDS);
  }, [map]);
  return null;
};

function MapResize() {
  const map = useMap();
  const resize = useCallback(() => {
    map.invalidateSize();
  }, [map]);

  useEffect(() => {
    resize();
    const ro = new ResizeObserver(() => resize());
    const el = map.getContainer().parentElement;
    if (el) ro.observe(el);
    return () => ro.disconnect();
  }, [map, resize]);

  return null;
};

function AutoFocusOfficers({ officers }: { officers: OfficersMapBlip[] }) {
  const map = useMap();

  useEffect(() => {
    if (!officers.length) return;

    const points = officers
      .map((o) => {
        if (!o?.coords) return null;
        const [lat, lng] = gtaToLatLng(o.coords.x, o.coords.y);
        if (!Number.isFinite(lat) || !Number.isFinite(lng)) return null;
        return { officer: o, latLng: L.latLng(lat, lng) };
      })
      .filter(Boolean) as { officer: OfficersMapBlip; latLng: L.LatLng }[];

    if (!points.length) return;

    // 1 officer: center there with a sensible zoom
    if (points.length === 1) {
      map.setView(points[0].latLng, Math.min(2.5, GTA_MAP_MAX_ZOOM), { animate: true });
      return;
    }

    // Focus on the densest area (where there are basically more officers).
    // Heuristic: choose an anchor with minimal sum of distances to its nearest neighbors,
    // then fit bounds around its K nearest officers.
    const K = Math.min(6, points.length);
    const sumNearest = (idx: number) => {
      const base = points[idx].latLng;
      const dists = points
        .map((p, j) => (j === idx ? 0 : base.distanceTo(p.latLng)))
        .filter((d) => d > 0)
        .sort((a, b) => a - b);
      const take = dists.slice(0, Math.min(2, dists.length));
      return take.reduce((acc, d) => acc + d, 0);
    };

    let bestIdx = 0;
    let best = Number.POSITIVE_INFINITY;
    for (let i = 0; i < points.length; i++) {
      const score = sumNearest(i);
      if (score < best) {
        best = score;
        bestIdx = i;
      }
    }

    const anchor = points[bestIdx].latLng;
    const nearest = [...points]
      .sort((a, b) => anchor.distanceTo(a.latLng) - anchor.distanceTo(b.latLng))
      .slice(0, K)
      .map((p) => p.latLng);

    const bounds = L.latLngBounds(nearest);
    map.fitBounds(bounds, {
      padding: [24, 24],
      // keep a bit more open on large screens
      maxZoom: Math.min(5, GTA_MAP_MAX_ZOOM),
      animate: true,
    });
  }, [map, officers]);

  return null;
}

export function GtaOfficersMap() {
  const [officers, setOfficers] = useState<OfficersMapBlip[]>([]);

  const load = useCallback(async () => {
    const data = await fetchNui<OfficersMapBlip[]>("getOfficersOnMap", {}, MOCK_OFFICERS);
    if (data) setOfficers(data);
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  useNuiEvent("updateOfficersOnMap", (data?: OfficersMapBlip[]) => {
    if (data) setOfficers(data);
  });

  const handleLocateOfficer = useCallback((officer: OfficersMapBlip) => {
    void fetchNui("markCds", {
      officerId: officer.id,
      coords: officer.coords,
    });
  }, []);

  const InBrowser = isEnvBrowser();
  const directoryTiles = useMemo(() => {
    return !InBrowser
      ? `/web/build/assets/tiles/{z}/{x}/{y}.png`
      : `${import.meta.env.BASE_URL}assets/tiles/{z}/{x}/{y}.png`;
  }, [InBrowser]);

  return (
    <div className="flex-1 min-h-0 w-full rounded-md overflow-hidden [&_.leaflet-container]:bg-[#1a1b1e]">
      <MapContainer
        crs={L.Util.extend({}, L.CRS.Simple, {
          scale: (zoom: number) => Math.pow(2, zoom) / GTA_MAP_MIN_RESOLUTION,
        })}
        maxBounds={GTA_MAP_BOUNDS}
        maxBoundsViscosity={1.0}
        className="size-full [&_.leaflet-container]:size-full"
        style={{ height: "100%", width: "100%" }}
        zoomControl
        minZoom={GTA_MAP_MIN_ZOOM}
        maxZoom={GTA_MAP_MAX_ZOOM}
        scrollWheelZoom
        attributionControl={false}
        center={[GTA_MAP_CENTER_LAT, GTA_MAP_CENTER_LNG]}
        zoom={2}
      >
        <FitBounds />
        <MapResize />
        <AutoFocusOfficers officers={officers} />
        <TileLayer
          url={directoryTiles}
          minZoom={GTA_MAP_MIN_ZOOM}
          maxZoom={GTA_MAP_MAX_ZOOM}
          noWrap
          tms
        />
        {officers.map((o, index) => {
          const [lat, lng] = gtaToLatLng(o.coords.x, o.coords.y);
          return (
            <CircleMarker
              key={index}
              center={[lat, lng]}
              radius={5}
              pathOptions={{
                color: "#FFFFFF1d",
                fillColor: o.color ?? "#0084ff",
                fillOpacity: 0.95,
                weight: 2,
              }}
            >
              <Popup className="!p-0">
                <div className="flex items-center gap-6">
                  <span className="text-neutral-900 text-base font-medium">{o.name ?? ""} #{o.id}</span>
                  <button
                    type="button"
                    className="p-1.5 size-8 rounded-md hover:bg-black/15 bg-black/10 transition-colors"
                    aria-label="Localizar"
                    onClick={() => handleLocateOfficer(o)}
                  >
                    <svg
                      className="size-full  flex-1"
                      width="22"
                      height="22"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="#000"
                      strokeWidth="1.5"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      xmlns="http://www.w3.org/2000/svg"
                    >
                      <path d="M15 10.5a3 3 0 11-6 0 3 3 0 016 0z" />
                      <path d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1115 0z" />
                    </svg>
                  </button>
                </div>
              </Popup>
            </CircleMarker>
          );
        })}
      </MapContainer>
    </div>
  );
}
