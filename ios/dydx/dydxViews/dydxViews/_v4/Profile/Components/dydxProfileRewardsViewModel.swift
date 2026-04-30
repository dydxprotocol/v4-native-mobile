//
//  dydxProfileRewardsViewModel.swift
//  dydxUI
//
//  Created by Rui Huang on 9/18/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import Combine

public class dydxProfileRewardsViewModel: dydxTitledCardViewModel {
    @Published public var countdownText: String = "-"

    private var timerCancellable: AnyCancellable?

    public init() {
        super.init(title: DataLocalizer.localize(path: "APP.GENERAL.LIQUIDATION_REBATES"),
                   verticalContentPadding: 16,
                   horizontalContentPadding: 16)
        updateCountdown()
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateCountdown()
            }
    }

    deinit {
        timerCancellable?.cancel()
    }

    private func updateCountdown() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .current

        let now = Date()
        let nowComponents = calendar.dateComponents([.year, .month], from: now)
        guard let year = nowComponents.year, let month = nowComponents.month else {
            countdownText = "-"
            return
        }

        var nextMonthComponents = DateComponents()
        nextMonthComponents.year = month == 12 ? year + 1 : year
        nextMonthComponents.month = month == 12 ? 1 : month + 1
        nextMonthComponents.day = 1
        nextMonthComponents.hour = 0
        nextMonthComponents.minute = 0
        nextMonthComponents.second = 0

        guard let nextMonth = calendar.date(from: nextMonthComponents) else {
            countdownText = "-"
            return
        }

        let interval = max(0, Int(nextMonth.timeIntervalSince(now)))
        let days = interval / 86400
        let hours = (interval % 86400) / 3600
        let minutes = (interval % 3600) / 60
        let seconds = interval % 60

        countdownText = String(format: "%dd %dh %dm %ds", days, hours, minutes, seconds)
    }

    override func createTitleAccessoryView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> AnyView? {
        Text(DataLocalizer.localize(path: "APP.GENERAL.ACTIVE"))
            .themeColor(foreground: .colorGreen)
            .themeFont(fontType: .base, fontSize: .smaller)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .border(borderWidth: 1, cornerRadius: 4, borderColor: ThemeColor.SemanticColor.colorGreen.color)
            .wrappedInAnyView()
    }

    override func createContentView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> AnyView? {
        VStack(alignment: .leading, spacing: 12) {
            Text(Self.localizedBody)
                .themeFont(fontType: .base, fontSize: .small)
                .themeColor(foreground: .textTertiary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                PlatformIconViewModel(type: .system(name: "clock"),
                                      size: CGSize(width: 14, height: 14),
                                      templateColor: .colorPurple)
                    .createView()
                Text(Self.localizedCountdownLabel)
                    .themeFont(fontType: .base, fontSize: .small)
                    .themeColor(foreground: .colorPurple)
                Text(countdownText)
                    .themeFont(fontType: .base, fontSize: .small)
                    .themeColor(foreground: .textPrimary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .themeColor(background: .layer4)
            .cornerRadius(20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .wrappedInAnyView()
    }

    private static var localizedBody: String {
        let body = DataLocalizer.localize(path: "APP.REWARDS_SURGE_APRIL_2025.LIQUIDATION_REBATES_BODY")
        let subBody = DataLocalizer.localize(
            path: "APP.REWARDS_SURGE_APRIL_2025.LIQUIDATION_REBATES_SUB_BODY",
            params: [
                "LOSS_REBATES_LINK": DataLocalizer.localize(path: "APP.REWARDS_SURGE_APRIL_2025.LOSS_REBATES"),
                "CHECK_ELIGIBILITY_LINK": DataLocalizer.localize(path: "APP.GENERAL.HERE")
            ]
        )
        return "\(body) \(subBody)"
    }

    private static var localizedCountdownLabel: String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .current
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM"
        let monthName = formatter.string(from: Date())
        return DataLocalizer.localize(
            path: "APP.REWARDS_SURGE_APRIL_2025.MONTH_COUNTDOWN",
            params: ["MONTH": monthName]
        )
    }

    public static var previewValue: dydxProfileRewardsViewModel {
        let vm = dydxProfileRewardsViewModel()
        vm.countdownText = "0d 9h 51m 46s"
        return vm
    }

}

#if DEBUG
struct dydxProfileRewardsViewModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxProfileRewardsViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxProfileRewardsViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxProfileRewardsViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
