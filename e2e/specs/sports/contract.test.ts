import { expect, tv4, use } from "chai";
import ChaiJsonSchema = require("chai-json-schema");
import { SPORTS_URL } from "../URLs";
import httpClientFactory from "../utils/httpClientFactory";
import schema from "./sport_swagger.json";

use(ChaiJsonSchema);

tv4.addSchema("#/definitions/Sport", schema.definitions.Sport);
tv4.addSchema("#/definitions/PlayerStatistic", schema.definitions.PlayerStatistic);

const httpClient = httpClientFactory(SPORTS_URL);

describe("Sports", () => {
  describe("GET /:id", () => {
    it("matches schema", async () => {
      const { status, data: response } = await httpClient.get("basketball_5x5");
      expect(response).to.be.jsonSchema(schema.definitions.SportResponse);
      expect(status).to.be.equal(200);
    });
  });
});
