
import { CommunicationsCard, ExpandableDashboardBox, GtaOfficersMap, PageHeader } from "@/components";
import { useEffect, useState } from "react";
import { Communication, DashboardExpandPanelId, IReport } from "@/interfaces";
import { useNuiEvent } from "@/hooks";
import { fetchNui } from "@/utils";

export default function Home(): JSX.Element {
  const [recentTickets, setRecentTickets] = useState<IReport[]>([]);

  const [communications, setCommunications] = useState<Communication[]>([]);

  const [expandedPanel, setExpandedPanel] = useState<DashboardExpandPanelId | null>(null);

  const updateAllReports = async () => {
    const data = await fetchNui<IReport[]>("getAllReports", {}, [
      {
        id: "1",
        createdBy: "Rodrigo Carioca",
        description: "Alguem me assaltou e preciso de ajuda!",
        handledBy: "Rodrigo Carioca",
        coords: { x: 0, y: 0, z: 0 }
      },
      {
        id: "2",
        createdBy: "Rodrigo Carioca",
        description: "Alguem me assaltou e preciso de ajuda!",
        handledBy: "Rodrigo Carioca",
        coords: { x: 0, y: 0, z: 0 }
      },
      {
        id: "3",
        createdBy: "Rodrigo Carioca",
        description: "Alguem me assaltou e preciso de ajuda!",
        handledBy: "Rodrigo Carioca",
        coords: { x: 0, y: 0, z: 0 }
      },
      {
        id: "4",
        createdBy: "Rodrigo Carioca",
        description: "Alguem me assaltou e preciso de ajuda!",
        handledBy: "Rodrigo Carioca",
        coords: { x: 0, y: 0, z: 0 }
      },
      {
        id: "5",
        createdBy: "Rodrigo Carioca",
        description: "Alguem me assaltou e preciso de ajuda!",
        handledBy: "Rodrigo Carioca",
        coords: { x: 0, y: 0, z: 0 }
      },
    ]);
    if (!data) return;
    setRecentTickets(data ?? []);
  };
  const updateAllCommunications = async () => {
    const data = await fetchNui<Communication[]>("getAllChatMessages", {}, [
      {
        id: "1",
        author: "Rodrigo Carioca",
        message: "Sejam bem vindos!Sejam bem vindos!Sejam bem vindos!Sejam bem vindos",
      },
      {
        id: "2",
        author: "Rodrigo Carioca",
        message:
          "Sejam bem vindos!Sejam bem vindos!Sejam bem vindos!Sejam bem vindos!Sejam bem vindos!Sejam bem vindos!Sejam bem vindos!",
      },
      {
        id: "2",
        author: "Rodrigo Carioca",
        message:
          "Sejam bem vindos!Sejam bem vindos!Sejam bem vindos!Sejam bem vindos!Sejam bem vindos!Sejam bem vindos!Sejam bem vindos!",
      },
      {
        id: "2",
        author: "Rodrigo Carioca",
        message:
          "Sejam bem vindos!Sejam bem vindos!Sejam bem vindos!Sejam bem vindos!Sejam bem vindos!Sejam bem vindos!Sejam bem vindos!",
      },
      {
        id: "2",
        author: "Rodrigo Carioca",
        message:
          "Sejam bem vindos!Sejam bem vindos!Sejam bem vindos!Sejam bem vindos!Sejam bem vindos!Sejam bem vindos!Sejam bem vindos!",
      },
    ]);
    if (!data) return;
    setCommunications(data ?? []);
  };

  useEffect(() => {
    Promise.all([
      updateAllReports(),
      updateAllCommunications(),
    ])
  }, [])

  useNuiEvent("updateAllReports", (data?: IReport[]) => {
    setRecentTickets(data ?? []);
  });
  useNuiEvent("updateNewReport", (data?: IReport) => {
    if (!data) return;
    setRecentTickets(prev => ([...prev, data]))
  });

  useNuiEvent("newChatMessage", (data?: Communication) => {
    if (!data) return;
    setCommunications(prev => ([...prev, data]))
  });
  useNuiEvent("updateAllChatMessages", (data?: Communication[]) => {
    setCommunications(data ?? [])
  });

  const markCds = (ticket: IReport) => {
    void fetchNui("markReportCds", ticket);
  };
  
  const acceptReport = (ticket: IReport) => {
    if (!ticket) return;
    void fetchNui("acceptReport", { id: ticket.id });
  };

  useEffect(() => {
    if (!expandedPanel) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") setExpandedPanel(null);
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [expandedPanel]);

  return (

    <div className="flex-1 pt-[3.3rem] px-[3.4rem]">
      <PageHeader
        title="Dashboard"
        description="Você poderá visualizar de forma geral nossos sistemas;"
      />
      <div className="flex w-full h-[19.5rem] gap-7 mt-5">
        <ExpandableDashboardBox
          boxId="officers"
          title="Oficiais em serviço"
          expanded={expandedPanel}
          onExpand={setExpandedPanel}
          onCollapse={() => setExpandedPanel(null)}
        >
          <GtaOfficersMap />
        </ExpandableDashboardBox>
        <CommunicationsCard
          communications={communications}
          expandable
          expanded={expandedPanel === "communications"}
          onExpand={() => setExpandedPanel("communications")}
          onCollapse={() => setExpandedPanel(null)}
        />
      </div>

      <div className="w-full default-box !px-6 mt-[1.8rem] h-[15.7rem] flex flex-col gap-2">
        <h2 className="text-white text-2xl font-bold">Chamados Recentes</h2>

        <div className="flex flex-1 min-h-0 overflow-hidden rounded-lg ">
          <div className="w-full h-full overflow-y-auto overflow-x-hidden">
            <table className="w-full table-fixed border-separate border-spacing-0 bg-white/[2%]">

              <thead className=" z-10">
                <tr className="text-left text-text-secondary text-base font-normal">
                  <th className="font-normal  py-2 px-4 w-[24%] text-text-secondary">Chamado por</th>
                  <th className="font-normal py-2 text-text-secondary">Descrição</th>
                  <th className="font-normal  py-2 w-[22%] text-text-secondary">Atendido por</th>
                  <th className="font-normal py-2 w-[3.25rem]" />
                </tr>
              </thead>

              <tbody className="">
                {recentTickets.map((ticket, idx) => (
                  <tr
                    key={idx}
                    className="odd:bg-black/10"
                  >
                    <td className="py-1.5 px-4 text-white text-base font-normal truncate">
                      {ticket.createdBy}
                    </td>
                    <td className="py-1.5 text-white text-base font-normal truncate">
                      {ticket.description}
                    </td>
                    <td className="py-1.5 text-white text-base font-normal truncate">
                      {ticket.handledBy}
                    </td>
                    <td className="py-1.5">
                      <button
                        onClick={() => acceptReport(ticket)}
                        type="button"
                        aria-label="Ver detalhes do chamado"
                        className="size-7 aspect-square rounded-xl bg-text-secondary  transition-all hover:bg-blue-custom fullCenter"
                      >
                        <span className="text-lg leading-none font-semibold text-[#37393E]">i</span>
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

  )
}

