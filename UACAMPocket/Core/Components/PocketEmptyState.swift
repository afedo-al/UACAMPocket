//
//  PocketEmptyState.swift
//  UACAMPocket
//
//  Created by Alfredo on 09/11/26.
//


import SwiftUI

struct PocketEmptyState: View {
    let title: String
    let message: String
    let systemImage: String
    let actionTitle: String?
    let actionSystemImage: String?
    let action: (() -> Void)?

    init(
        title: String,
        message: String,
        systemImage: String,
        actionTitle: String? = nil,
        actionSystemImage: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.actionTitle = actionTitle
        self.actionSystemImage = actionSystemImage
        self.action = action
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 32))
                .foregroundStyle(AppTheme.Colors.blue)
            Text(title)
                .font(AppTheme.Typography.headline)
                .foregroundStyle(AppTheme.Colors.primaryText)
                .multilineTextAlignment(.center)
            Text(message)
                .font(AppTheme.Typography.footnote)
                .foregroundStyle(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
            if let actionTitle, let action {
                Button(action: action) {
                    Label(actionTitle, systemImage: actionSystemImage ?? "arrow.right")
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundStyle(AppTheme.Colors.blue)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.xl)
        .background(
            AppTheme.Colors.surface,
            in: RoundedRectangle(cornerRadius: AppTheme.Radius.card)
        )
    }
}
