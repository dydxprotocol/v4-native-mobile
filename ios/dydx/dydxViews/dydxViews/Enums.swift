//
//  Enums.swift
//  dydxViews
//
//  Created by Rui Huang on 2/27/23.
//

import Foundation

public enum AppOrderSide {
    case unknown
    case BUY
    case SELL
}

public enum TransferStatus {
   case unknown
   case PENDING
   case CONFIRMED
}

public enum AppPositionSide {
    case unknown
    case LONG
    case SHORT
}

public enum PortfolioSection: String {
    case details
    case positions
    case trades
    case orders
    case funding
}

public enum TileType: Int {
    case price
    case depth
    case funding
    case orderbook
    case recent
}
