//
//  PocketPrimaryButton.swift
//  UACAMPocket
//
//  Created by Alfredo on 09/11/26.
//


import SwiftUI

struct PocketPrimaryButton: View {
    let title: String
    let systemImage: String?
    let isLoading: Bool
    let isDisabled: Bool
    let loadingTitle: String
    let action: () -> Void

    init(
        title: String,
        systemImage: String? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        loadingTitle: String = "Procesando...",
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.loadingTitle = loadingTitle
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.xs) {
                if isLoading {
                    ProgressView().tint(.white)
                } else if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(isLoading ? loadingTitle : title)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .font(AppTheme.Typography.bodyMedium)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 48)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .background(
                isDisabled || isLoading
                    ? AppTheme.Colors.blue.opacity(0.45)
                    : AppTheme.Colors.blue,
                in: RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isLoading)
    }
}
