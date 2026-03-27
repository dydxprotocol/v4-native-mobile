export type RebateLeaderboardResponse = {
  position: number;
  address: string;
  pnl: number;
  dollarReward: number;
};

export type SurgeLeaderboardResponse = {
  address: string;
  rank: number;
  total_fees: number;
};
