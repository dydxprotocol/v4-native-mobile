import axios from "axios";
import {
  RebateLeaderboardResponse,
  SurgeLeaderboardResponse,
} from "../models/leaderboard";

export const getRebateLeaderboard = async () => {
  const response = await axios.get<RebateLeaderboardResponse[]>(
    "https://pp-external-api-ffb2ad95ef03.herokuapp.com/api/dydx-weekly-clc",
    {
      params: {
        perPage: 50,
      },
    }
  );
  return response.data;
};

export const getSurgeLeaderboard = async (address: string) => {
  const response = await axios.get<SurgeLeaderboardResponse[]>(
    "https://pp-external-api-ffb2ad95ef03.herokuapp.com/api/dydx-fee-leaderboard",
    {
      params: {
        perPage: 50,
        address: address,
      },
    }
  );
};
