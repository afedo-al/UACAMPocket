//
//  ContentView.swift
//  UACAMPocket
//
//  Created by Alfredo on 09/11/26.
//

import SwiftUI

// MARK: - NAVEGACIÓN PRINCIPAL
// Una sola instancia para los datos académicos y otra para tareas.
// Acceso ficticio controlado por PocketDemoAuthService, no por la
// elección antigua de rol sin credenciales.

struct ContentView: View {

    @StateObject private var servicio = PocketDataService()
    @StateObject private var servicioTareas = PocketTaskService()

    @StateObject private var autenticacion = PocketDemoAuthService()
    @State private var confirmarSalida = false

    @State private var pestanaSeleccionada = 0
    @State private var mostrarTramites = false
    @State private var mostrarCampus = false
    @State private var mostrarTareas = false

    private var rolActual: TipoUsuario? {
        autenticacion.rolAutenticado
    }

    var body: some View {
        Group {
            if let rol = rolActual {
                VStack(spacing: 0) {
                    barraDePerfil(rol)
                    Divider()

                    if rol == .estudiante {
                        pestanasEstudiante
                    } else {
                        DocentesView(servicio: servicio)
                    }
                }
                .background(
                    AppTheme.Colors.background.ignoresSafeArea()
                )
            } else {
                InicioSesionView(autenticacion: autenticacion)
            }
        }
        .tint(AppTheme.Colors.blue)
        .onAppear(perform: sincronizarUsuario)
        .onChange(of: autenticacion.usuarioAutenticado) { _, _ in
            sincronizarUsuario()
        }
        .confirmationDialog(
            "¿Cerrar sesión de demostración?",
            isPresented: $confirmarSalida,
            titleVisibility: .visible
        ) {
            Button("Cerrar sesión", role: .destructive) {
                cerrarSesion()
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Volverás al inicio de sesión. Tus tareas, proyectos, favoritos y postulaciones seguirán guardados en este dispositivo.")
        }
    }

    // MARK: - Barra superior de sesión

    private func barraDePerfil(_ rol: TipoUsuario) -> some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            Text("UACAM Pocket")
                .font(AppTheme.Typography.subheadline)
                .foregroundStyle(AppTheme.Colors.navy)
                .lineLimit(1)

            Spacer(minLength: 4)

            Text(rol.rawValue)
                .font(AppTheme.Typography.small)
                .foregroundStyle(AppTheme.Colors.secondaryText)

            Button {
                confirmarSalida = true
            } label: {
                Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                    .font(AppTheme.Typography.captionBold)
                    .foregroundStyle(AppTheme.Colors.blue)
                    .padding(.horizontal, AppTheme.Spacing.xs)
                    .frame(minHeight: AppTheme.Sizes.minimumTouchTarget)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Cerrar sesión de demostración")
        }
        .padding(.horizontal, AppTheme.Spacing.screenHorizontal)
        .padding(.vertical, AppTheme.Spacing.xxs)
        .background(AppTheme.Colors.surface)
    }

    // MARK: - Cuatro pestañas del estudiante

    private var pestanasEstudiante: some View {
        TabView(selection: $pestanaSeleccionada) {

            InicioView(
                servicio: servicio,
                servicioTareas: servicioTareas,
                abrirCalendario: {
                    pestanaSeleccionada = 1
                },
                abrirOportunidades: {
                    pestanaSeleccionada = 2
                },
                abrirTramites: {
                    mostrarTramites = true
                },
                abrirCampus: {
                    mostrarCampus = true
                },
                abrirTareas: {
                    mostrarTareas = true
                }
            )
            .tabItem {
                Label("Inicio", systemImage: "house.fill")
            }
            .tag(0)

            CalendarioView(servicioTareas: servicioTareas)
                .tabItem {
                    Label("Calendario", systemImage: "calendar")
                }
                .tag(1)

            OportunidadesView(servicio: servicio)
                .tabItem {
                    Label("Oportunidades", systemImage: "briefcase.fill")
                }
                .tag(2)

            PerfilView(
                servicio: servicio,
                abrirOportunidades: {
                    pestanaSeleccionada = 2
                },
                cerrarSesion: {
                    // Perfil ya solicita confirmación; evitar repetirla.
                    cerrarSesion()
                }
            )
            .tabItem {
                Label("Perfil", systemImage: "person.fill")
            }
            .tag(3)
        }
        .sheet(isPresented: $mostrarTramites) {
            TramitesView(
                abrirOportunidades: {
                    mostrarTramites = false
                    pestanaSeleccionada = 2
                }
            )
        }
        .sheet(isPresented: $mostrarCampus) {
            CampusView()
        }
        .sheet(isPresented: $mostrarTareas) {
            TareasView(servicioTareas: servicioTareas)
        }
    }

    // MARK: - Salir sin alterar almacenamiento académico

    private func sincronizarUsuario() {
        servicio.establecerUsuarioActivo(
            autenticacion.usuarioAutenticado,
            usuarios: autenticacion.todosLosUsuarios
        )
    }

    private func cerrarSesion() {
        mostrarTramites = false
        mostrarCampus = false
        mostrarTareas = false
        pestanaSeleccionada = 0
        autenticacion.cerrarSesion()
        sincronizarUsuario()
    }
}

#Preview("UACAM Pocket") {
    ContentView()
}
