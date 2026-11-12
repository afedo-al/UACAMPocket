//
//  PocketSectionHeader.swift
//  UACAMPocket
//
//  Created by Alfredo on 09/11/26.
//

import SwiftUI

struct PocketSectionHeader: View {
    let title: String
    let subtitle: String?
    let actionTitle: String?
    let actionSystemImage: String?
    let action: (() -> Void)?

    init(
        title: String,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        actionSystemImage: String? = "arrow.right",
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.actionSystemImage = actionSystemImage
        self.action = action
    }

    var body: some View {
        HStack(alignment: .center, spacing: AppTheme.Spacing.sm) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text(title)
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }
            }
            Spacer(minLength: 4)
            if let actionTitle, let action {
                Button(action: action) {
                    HStack(spacing: 4) {
                        Text(actionTitle)
                        if let actionSystemImage {
                            Image(systemName: actionSystemImage)
                        }
                    }
                    .font(AppTheme.Typography.captionBold)
                    .foregroundStyle(AppTheme.Colors.blue)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
