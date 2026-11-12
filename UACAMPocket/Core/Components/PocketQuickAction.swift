//
//  PocketQuickAction.swift
//  UACAMPocket
//
//  Created by Alfredo on 09/11/26.
//


import SwiftUI

struct PocketQuickAction: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: systemImage)
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(color)
                    .frame(height: 30)
                Text(title)
                    .font(AppTheme.Typography.small)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
            }
            .frame(maxWidth: .infinity, minHeight: 76)
            .padding(.horizontal, 3)
            .background(
                AppTheme.Colors.surface,
                in: RoundedRectangle(cornerRadius: AppTheme.Radius.large)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}
