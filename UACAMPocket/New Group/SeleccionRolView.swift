//
//  SeleccionRolView.swift
//  UACAMPocket
//
//  Created by Alfredo on 09/11/26.
//


import SwiftUI

// Pantalla de selección de rol de demostración, no autenticación institucional.
struct SeleccionRolView: View {
    @ObservedObject var servicio: PocketDataService
    let continuar: (TipoUsuario) -> Void
    @State private var rolSeleccionado: TipoUsuario = .estudiante

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.xl) {
                VStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 45))
                        .foregroundStyle(.white)
                        .frame(width: 84, height: 84)
                        .background(AppTheme.Colors.blue, in: RoundedRectangle(cornerRadius: 20))

                    Text("UACAM Pocket")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Tu universidad, siempre contigo.")
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 52)
                .background(AppTheme.Gradients.header, in: RoundedRectangle(cornerRadius: AppTheme.Radius.extraLarge))

                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text("¿Cómo quieres entrar?")
                        .font(AppTheme.Typography.title3)
                        .foregroundStyle(AppTheme.Colors.primaryText)

                    opcion(.estudiante, titulo: "Estudiante", detalle: "Consulta tus materias, oportunidades y trámites.", simbolo: "graduationcap.fill")
                    opcion(.docente, titulo: "Docente", detalle: "Publica proyectos y revisa las postulaciones.", simbolo: "person.crop.rectangle.stack.fill")

                    PocketPrimaryButton(title: "Continuar", systemImage: "arrow.right") {
                        continuar(rolSeleccionado)
                    }

                    Label("Prototipo conceptual. No inicia sesión en los sistemas de la UACAM.", systemImage: "info.circle")
                        .font(AppTheme.Typography.small)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }
                .padding(AppTheme.Spacing.lg)
                .background(AppTheme.Colors.surface, in: RoundedRectangle(cornerRadius: AppTheme.Radius.card))
            }
            .padding(AppTheme.Spacing.screenHorizontal)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
    }

    private func opcion(_ rol: TipoUsuario, titulo: String, detalle: String, simbolo: String) -> some View {
        Button { rolSeleccionado = rol } label: {
            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: simbolo)
                    .font(.title2)
                    .foregroundStyle(AppTheme.Colors.blue)
                    .frame(width: 36)
                VStack(alignment: .leading, spacing: 4) {
                    Text(titulo)
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.Colors.primaryText)
                    Text(detalle)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }
                Spacer(minLength: 4)
                Image(systemName: rolSeleccionado == rol ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(AppTheme.Colors.blue)
            }
            .padding(AppTheme.Spacing.md)
            .background(
                rolSeleccionado == rol ? AppTheme.Colors.secondarySurface : AppTheme.Colors.surface,
                in: RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
            )
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                    .stroke(rolSeleccionado == rol ? AppTheme.Colors.blue : AppTheme.Colors.border, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}
