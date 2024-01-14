import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

admin.initializeApp();

import { getDirections } from "./getDirections";
import { getAddressAutoComplete } from "./getAddressAutoComplete";

const validateAuth = async (request: any): Promise<string | null> => {
  const { authorization } = request.headers;

  if (!authorization) {
    return null;
  }

  const token = authorization.split("Bearer ")[1];

  if (!token) {
    return null;
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    return decodedToken.uid;
  } catch (error) {
    logger.error("Error", error);
    return null;
  }
};

export const generateRoute = onRequest(
  { maxInstances: 10 },
  async (request, response) => {
    if (request.method !== "POST") {
      response.status(405).send("Method Not Allowed");
      return;
    }

    const uid =  await validateAuth(request);

    if (!uid) {
      response.status(401).send("Unauthorized");
      return;
    }

    logger.info("Request body", { body: request.body });

    try {
      const { route } = await getDirections(request.body.data);

      logger.info("Response", { route });

      // TODO: Check if route crosses with friends' routes

      response.status(200).send({ data: route });
    } catch (error) {
      logger.error("Error", error);
      response.status(500).send("Internal Server Error");
    }
  }
);

export const getAddresses = onRequest(
  { maxInstances: 10 },
  async (request, response) => {
    if (request.method !== "POST") {
      response.status(405).send("Method Not Allowed");
      return;
    }

    const uid =  await validateAuth(request);

    if (!uid) {
      response.status(401).send("Unauthorized");
      return;
    }

    logger.info("Request body", { body: request.body });

    try {
      const addresses = await getAddressAutoComplete(request.body.data.query);

      response.status(200).send({ data: addresses });
    } catch (error) {
      logger.error("Error", error);
      response.status(500).send("Internal Server Error");
    }
  }
);
