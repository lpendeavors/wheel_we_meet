import axios from "axios";

export interface DirectionsRequest {
  truckWidth: number;
  truckHeight: number;
  truckWeight: number;
  originLat: number;
  originLng: number;
  destinationLat: number;
  destinationLng: number;
  truckHazardous: boolean;
  truckAvoidFerries: boolean;
  truckAvoidTolls: boolean;
  truckAvoidHighways: boolean;
  isImperial: boolean;
}

export const getDirections = async (request: DirectionsRequest) => {
  const mapboxAccessToken = process.env.MAPBOX_API_KEY;

  const {
    truckWidth,
    truckHeight,
    truckWeight,
    originLat,
    originLng,
    destinationLat,
    destinationLng,
    isImperial,
  } = request;

  let officialWidth = truckWidth;
  let officialHeight = truckHeight;
  let officialWeight = truckWeight;

  if (isImperial) {
    officialWidth = truckWidth / 12 * 0.3048;           // Convert from inches to meters
    officialHeight = truckHeight / 12 * 0.3048;         // Convert from inches to meters
    officialWeight = (truckWeight * 0.000453592);       // Convert from pounds to metric tons
  } else {
    officialWeight = truckWeight / 1000;                // Convert from kilograms to metric tons
  }

  const excludeString = constructExcludeParam(request);
  let mapboxUrl = `https://api.mapbox.com/directions/v5/mapbox/driving-traffic/${originLng},${originLat};${destinationLng},${destinationLat}?access_token=${mapboxAccessToken}&geometries=geojson&overview=full&max_width=${officialWidth}&max_height=${officialHeight}&max_weight=${officialWeight}`;

  if (excludeString) {
    mapboxUrl += `&exclude=${excludeString}`;
  }

  try {
    const response = await axios.get(mapboxUrl);
    return { route: response.data };
  } catch (error) {
    throw error;
  }
}

function constructExcludeParam(request: DirectionsRequest): string {
  const excludeValues: string[] = [];

  if (request.truckAvoidHighways) {
    excludeValues.push('motorway');
  }
  if (request.truckAvoidTolls) {
    excludeValues.push('toll');
  }
  if (request.truckAvoidFerries) {
    excludeValues.push('ferry');
  }

  return excludeValues.join(',');
}