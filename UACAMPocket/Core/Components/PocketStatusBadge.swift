//
//  PocketStatusBadge.swift
//  UACAMPocket
//
//  Created by Alfredo on 09/11/26.
//


import SwiftUI

struct PocketStatusBadge: View {
    private let titulo: String
    private let simbolo: String
    private let color: Color

    init(oportunidad: Oportunidad) {
        if oportunidad.estaDisponible {
            titulo = "Disponible"
            simbolo = "checkmark.circle.fill"
            color = AppTheme.Colors.success
        } else if oportunidad.vacantes == 0 {
            titulo = "Sin vacantes"
            simbolo = "person.2.slash"
            color = AppTheme.Colors.warning
        } else {
            titulo = oportunidad.estado.rawValue
            simbolo = "clock"
            color = AppTheme.Colors.secondaryText
        }
    }

    init(estadoPostulacion: EstadoPostulacion) {
        titulo = estadoPostulacion.rawValue
        simbolo = estadoPostulacion.icono
        switch estadoPostulacion {
        case .aceptada: color = AppTheme.Colors.success
        case .rechazada, .cancelada: color = AppTheme.Colors.error
        case .enRevision: color = AppTheme.Colors.blue
        default: color = AppTheme.Colors.warning
        }
    }

    var body: some View {
        Label(titulo, systemImage: simbolo)
            .font(AppTheme.Typography.captionBold)
            .foregroundStyle(color)
            .padding(.horizontal, AppTheme.Spacing.xs)
            .padding(.vertical, 6)
            .background(color.opacity(0.11), in: Capsule())
            .fixedSize(horizontal: true, vertical: false)
    }
}
