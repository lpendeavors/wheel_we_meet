export interface Place {
  name: string;
  address?: string;
  description?: string;
  categories?: string[];
  contact?: Contact[];
  amenities?: string[];
  parkingSpaces?: number;
  showers?: number;
  scales?: boolean;
  fuelLanes?: number;
  paymentsAccepted?: string[];
  serviceBays?: number;
  serviceRadius?: number;
  parkingTypes?: string[];
  parkingPrices?: ParkingPrices;
  location: any;
  distance?: number;
}

export interface Contact {
  name: string;
  phone: string;
  email: string;
}

export interface ParkingPrices {
  monthly: number;
  daily: number;
  weekly: number;
}
