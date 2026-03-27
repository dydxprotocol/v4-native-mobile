import { queryOptions, useQuery } from "@tanstack/react-query";
import {
  getRebateLeaderboard,
  getSurgeLeaderboard,
} from "../services/leaderboard-service";

const getRebateLeaderboardOptions = () =>
  queryOptions({
    queryKey: ["rebate-leaderboard"],
    queryFn: getRebateLeaderboard,
  });

export const useRebateLeaderboard = () => {
  return useQuery(getRebateLeaderboardOptions());
};

const getSurgeLeaderboardOptions = (address?: string | null) =>
  queryOptions({
    queryKey: ["surge-leaderboard", address],
    queryFn: () => getSurgeLeaderboard(address!!),
    enabled: !!address,
  });

export const useSurgeLeaderboard = (address?: string | null) => {
  return useQuery(getSurgeLeaderboardOptions(address));
};
