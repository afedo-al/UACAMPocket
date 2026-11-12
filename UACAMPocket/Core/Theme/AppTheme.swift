//
//  AppTheme.swift
//  UACAMPocket
//
//  Created by Alfredo on 09/11/26.
//


import SwiftUI

// Design system del anteproyecto UACAM Pocket.
enum AppTheme {
    enum Colors {
        static let navy = Color(red: 13/255, green: 39/255, blue: 68/255)
        static let blue = Color(red: 23/255, green: 105/255, blue: 244/255)
        static let lightBlue = Color(red: 168/255, green: 209/255, blue: 255/255)
        static let background = Color(red: 245/255, green: 247/255, blue: 251/255)
        static let surface = Color.white
        static let secondarySurface = Color(red: 234/255, green: 242/255, blue: 255/255)
        static let primaryText = navy
        static let secondaryText = Color(red: 100/255, green: 117/255, blue: 138/255)
        static let tertiaryText = Color(red: 135/255, green: 149/255, blue: 165/255)
        static let border = Color(red: 225/255, green: 232/255, blue: 241/255)
        static let success = Color(red: 21/255, green: 148/255, blue: 89/255)
        static let warning = Color(red: 218/255, green: 149/255, blue: 14/255)
        static let error = Color(red: 214/255, green: 57/255, blue: 69/255)
        static let research = Color(red: 132/255, green: 72/255, blue: 213/255)
    }

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 28
        static let xxxl: CGFloat = 36
        static let section: CGFloat = 24
        static let screenHorizontal: CGFloat = 18
    }

    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let card: CGFloat = 18
        static let extraLarge: CGFloat = 22
    }

    enum Sizes {
        static let avatar: CGFloat = 48
        static let largeAvatar: CGFloat = 58
        static let minimumTouchTarget: CGFloat = 44
    }

    enum Typography {
        static let title2 = Font.system(size: 24, weight: .bold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .bold, design: .rounded)
        static let headline = Font.system(size: 16, weight: .semibold)
        static let subheadline = Font.system(size: 15, weight: .semibold)
        static let body = Font.system(size: 15)
        static let bodyMedium = Font.system(size: 15, weight: .medium)
        static let footnote = Font.system(size: 13)
        static let caption = Font.system(size: 12)
        static let captionBold = Font.system(size: 12, weight: .semibold)
        static let small = Font.system(size: 11)
    }

    enum Gradients {
        static let header = LinearGradient(
            colors: [Colors.navy, Color(red: 13/255, green: 61/255, blue: 115/255)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
