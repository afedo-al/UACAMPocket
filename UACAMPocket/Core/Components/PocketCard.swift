//
//  PocketCard.swift
//  UACAMPocket
//
//  Created by Alfredo on 09/11/26.
//


import SwiftUI

struct PocketCard<Content: View>: View {
    let padding: CGFloat
    let showBorder: Bool
    let showShadow: Bool
    @ViewBuilder let content: Content

    init(
        padding: CGFloat = AppTheme.Spacing.md,
        showBorder: Bool = false,
        showShadow: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.showBorder = showBorder
        self.showShadow = showShadow
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(padding)
            .background(
                AppTheme.Colors.surface,
                in: RoundedRectangle(cornerRadius: AppTheme.Radius.card)
            )
            .overlay {
                if showBorder {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                        .stroke(AppTheme.Colors.border, lineWidth: 1)
                }
            }
            .shadow(
                color: Color.black.opacity(showShadow ? 0.055 : 0),
                radius: showShadow ? 10 : 0,
                x: 0, y: 3
            )
    }
}
