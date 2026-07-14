
export interface User {
    name?: string,
    avatarURL?: string | null
    id: string
    policeRank: string
    inService?: boolean
    serviceTime?: string
    canManageOfficers?: boolean
}

type Coords = {
    x: number
    y: number
    z: number
}
export interface IOfficer extends User {
    coords: Coords
}

export type OfficersMapBlip = Pick<IOfficer, "id" | "name" | "coords"> & {
    color: string;
};

export interface IOccurrence {

    id: string,
    title: string,
    createdAt: string,//  "27/04/2022 - 16:23"
    officer: {
        name: string,
        id: string,
    },
    fine: number,
    status: string,
}
/** Resposta de `getOccurrenceData` — campos opcionais conforme tipo de resultado da busca. */
export interface IOccurrenceDataVehicle {
    plate: string;
    model: string;
    isDetained: boolean;
    imageURL: string | null;
    owner: {
        name: string;
        id: string;
    } | null;
}

export interface IOccurrenceDataUser {
    avatarURL: string | null;
    id: string;
    name: string;
    age: number;
    identity: string;
    fineValue: number;
    status: string;
}

export interface IOccurrenceDataSearched {
    errorMessage?: string;
    vehicle?: IOccurrenceDataVehicle;
    fines?: IOccurrence[];
    user?: IOccurrenceDataUser;
    occurrences?: IOccurrence[];
}

export interface ModifierPenalCodeItem {
    id: string,
    percentage: number,
    description: string,
}


export interface PenalCodeItem {
    id: string;             // ex: "ART_1"
    article: string;        // "I", "II", etc
    description: string;    // descrição do crime
    sentence: number;       // tempo de prisão
    fine: number;           // valor da multa
}

export interface SelectedCrimeDetailed {
    id: string;
    // sentence: number;
}

interface RegisterOccurrence {
    suspect: {
        id: string;
        description: string;
    };

    crimes: SelectedCrimeDetailed[];
    photo?: string

    modifiers: {
        attenuants: string[];
        aggravants: string[];
    };
}


export interface IRegisterItem {
    id: string //"Nº 4"
    police: {
        name: string
        id: string
    },
    formattedDate: string
    suspect: {
        name: string
        id: string
        identity: string,
    },
    isFinished?: boolean // caso esteja finalizado e nao permita editar
    crimes: SelectedCrimeDetailed[]
    description: string
    sentence: number       // tempo de prisão
    fine: number // valor da multa
    bailAmount?: number // valor da fiança (undefined) é "inafiançável"
}


export interface SelectedCrimeDetailed {
    id: string;
    // sentence: number;
}

export type IReport = {
    id: string,
    createdBy: string,
    description: string,
    handledBy: string,

    coords: Coords
}

export type Communication = {
    id: string;
    author: string;
    avatarURL?: string;
    message: string;
};

/** Painéis do dashboard que podem expandir em modal (oficiais / comunicados). */
export type DashboardExpandPanelId = "officers" | "communications";

export type CommunicationsCardProps = {
    title?: string;
    communications?: Communication[];
    expandable?: boolean;
    expanded?: boolean;
    onExpand?: () => void;
    onCollapse?: () => void;
};
