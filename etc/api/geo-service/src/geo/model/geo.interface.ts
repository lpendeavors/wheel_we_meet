export interface UserLocation {
  timestamp: Date;
  locationId: string;
  location: Location;
}

interface Location {
  type: string;
  coordinates: number[];
}
