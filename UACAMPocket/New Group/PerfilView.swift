//
//  PerfilView.swift
//  UACAMPocket
//
//  Created by Alfredo on 09/11/26.
//


import SwiftUI

// MARK: - PERFIL DEL ESTUDIANTE
// Archivo 26 - UACAM Pocket
// Diseño inspirado en la página 4 del anteproyecto.
// Todas las postulaciones y oportunidades guardadas proceden
// de la misma instancia de PocketDataService usada en ContentView.

struct PerfilView: View {

    @ObservedObject var servicio: PocketDataService
    let abrirOportunidades: () -> Void
    let cerrarSesion: () -> Void

    @State private var mostrarError = false
    @State private var mensajeError = ""
    @State private var confirmarCambioDePerfil = false

    // MARK: - Información existente

    private var estudiante: Usuario {
        servicio.estudianteDemo
    }

    private var iniciales: String {
        estudiante.nombre.split(separator: " ").prefix(2)
            .compactMap { $0.first }
            .map { String($0) }
            .joined().uppercased()
    }

    private var misPostulaciones: [Postulacion] {
        servicio.postulacionesDe(estudiante)
            .sorted { $0.fechaPostulacion > $1.fechaPostulacion }
    }

    private var misFavoritas: [Oportunidad] {
        servicio.oportunidades
            .filter { servicio.esFavorita($0.id) }
            .sorted { $0.titulo.localizedStandardCompare($1.titulo) == .orderedAscending }
    }

    // MARK: - Pantalla principal

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                    Text("Tu información en un solo lugar")
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(AppTheme.Colors.secondaryText)

                    tarjetaEstudiante
                    menuPerfil
                    avisoPrototipo
                }
                .padding(.horizontal, AppTheme.Spacing.screenHorizontal)
                .padding(.top, AppTheme.Spacing.sm)
                .padding(.bottom, AppTheme.Spacing.xxxl)
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())
            .navigationTitle("Mi perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        vistaConfiguracion
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title3)
                            .foregroundStyle(AppTheme.Colors.navy)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Abrir configuración")
                }
            }
            .alert("No se pudo actualizar", isPresented: $mostrarError) {
                Button("Entendido", role: .cancel) { }
            } message: {
                Text(mensajeError)
            }
            .confirmationDialog(
                "¿Quieres cerrar sesión?",
                isPresented: $confirmarCambioDePerfil,
                titleVisibility: .visible
            ) {
                Button("Cerrar sesión", role: .destructive) {
                    cerrarSesion()
                }
                Button("Cancelar", role: .cancel) { }
            } message: {
                Text("Volverás a la pantalla de inicio de sesión. Tus postulaciones, favoritos, proyectos y tareas seguirán guardados en este dispositivo.")
            }
        }
    }

    // MARK: - Tarjeta del estudiante

    private var tarjetaEstudiante: some View {
        NavigationLink {
            vistaDatosPersonales
        } label: {
            HStack(spacing: AppTheme.Spacing.md) {
                Text(iniciales)
                    .font(AppTheme.Typography.title2)
                    .foregroundStyle(.white)
                    .frame(
                        width: AppTheme.Sizes.largeAvatar,
                        height: AppTheme.Sizes.largeAvatar
                    )
                    .background(AppTheme.Colors.blue, in: Circle())
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                    Text(estudiante.nombre)
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.Colors.primaryText)

                    Text(estudiante.rol.rawValue)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)

                    Text(estudiante.carrera ?? "Carrera no especificada")
                        .font(AppTheme.Typography.small)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                        .lineLimit(2)
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
            .padding(AppTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                AppTheme.Colors.surface,
                in: RoundedRectangle(cornerRadius: AppTheme.Radius.large)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Ver datos del estudiante: \(estudiante.nombre)")
    }

    // MARK: - Menú principal de la maqueta

    private var menuPerfil: some View {
        VStack(spacing: 0) {
            NavigationLink {
                vistaPostulaciones
            } label: {
                filaMenu(
                    titulo: "Mis postulaciones",
                    icono: "doc.text",
                    contador: misPostulaciones.count
                )
            }

            separadorMenu

            NavigationLink {
                vistaGuardadas
            } label: {
                filaMenu(
                    titulo: "Oportunidades guardadas",
                    icono: "bookmark",
                    contador: misFavoritas.count
                )
            }

            separadorMenu

            NavigationLink {
                vistaNotificaciones
            } label: {
                filaMenu(
                    titulo: "Notificaciones",
                    icono: "bell"
                )
            }

            separadorMenu

            NavigationLink {
                vistaConfiguracion
            } label: {
                filaMenu(
                    titulo: "Configuración",
                    icono: "gearshape"
                )
            }
        }
        .buttonStyle(.plain)
        .background(
            AppTheme.Colors.surface,
            in: RoundedRectangle(cornerRadius: AppTheme.Radius.large)
        )
    }

    private var separadorMenu: some View {
        Divider()
            .padding(.leading, 55)
    }

    private func filaMenu(
        titulo: String,
        icono: String,
        contador: Int? = nil
    ) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icono)
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(AppTheme.Colors.navy)
                .frame(width: 26, height: 28)
                .accessibilityHidden(true)

            Text(titulo)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundStyle(AppTheme.Colors.primaryText)

            Spacer(minLength: 4)

            if let contador {
                Text("\(contador)")
                    .font(AppTheme.Typography.captionBold)
                    .foregroundStyle(.white)
                    .frame(minWidth: 28, minHeight: 28)
                    .padding(.horizontal, contador > 99 ? 4 : 0)
                    .background(AppTheme.Colors.blue, in: Capsule())
                    .accessibilityLabel("\(contador) registros")
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.Colors.secondaryText)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .frame(minHeight: 61)
        .contentShape(Rectangle())
    }

    // MARK: - Detalle: datos personales

    private var vistaDatosPersonales: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                PocketSectionHeader(
                    title: "Datos del estudiante",
                    subtitle: "Información utilizada en este prototipo"
                )

                PocketCard {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        datoPersonal("Nombre", valor: estudiante.nombre, icono: "person")
                        Divider()
                        datoPersonal("Perfil", valor: estudiante.rol.rawValue, icono: "person.crop.circle")
                        Divider()
                        datoPersonal(
                            "Carrera",
                            valor: estudiante.carrera ?? "No especificada",
                            icono: "graduationcap"
                        )
                        Divider()
                        datoPersonal(
                            "Facultad",
                            valor: estudiante.facultad ?? "No especificada",
                            icono: "building.2"
                        )
                        Divider()
                        datoPersonal("Correo de demostración", valor: estudiante.correo, icono: "envelope")
                    }
                }

                Text("Los datos de este perfil son de demostración; no se verifican contra sistemas de la UACAM.")
                    .font(AppTheme.Typography.small)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
            .padding(.horizontal, AppTheme.Spacing.screenHorizontal)
            .padding(.vertical, AppTheme.Spacing.md)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationTitle("Mis datos")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func datoPersonal(
        _ titulo: String,
        valor: String,
        icono: String
    ) -> some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
            Image(systemName: icono)
                .font(.title3)
                .foregroundStyle(AppTheme.Colors.blue)
                .frame(width: 26)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text(titulo)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                Text(valor)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .textSelection(.enabled)
            }
            Spacer(minLength: 0)
        }
    }

    // MARK: - Detalle: postulaciones reales

    private var vistaPostulaciones: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                PocketSectionHeader(
                    title: "Mis postulaciones",
                    subtitle: "\(misPostulaciones.count) solicitud(es) guardada(s) en este dispositivo",
                    actionTitle: "Explorar",
                    action: abrirOportunidades
                )

                if misPostulaciones.isEmpty {
                    PocketEmptyState(
                        title: "Sin postulaciones todavía",
                        message: "Explora oportunidades y encuentra un proyecto en el que quieras participar.",
                        systemImage: "tray",
                        actionTitle: "Explorar oportunidades",
                        actionSystemImage: "magnifyingglass",
                        action: abrirOportunidades
                    )
                } else {
                    ForEach(misPostulaciones) { postulacion in
                        if let oportunidad = servicio.oportunidad(
                            conID: postulacion.oportunidadId
                        ) {
                            NavigationLink {
                                OportunidadDetalleView(
                                    oportunidad: oportunidad,
                                    servicio: servicio
                                )
                            } label: {
                                tarjetaPostulacion(postulacion, oportunidad: oportunidad)
                            }
                            .buttonStyle(.plain)
                        } else {
                            PocketCard(showBorder: true) {
                                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                                    Text("Proyecto no disponible")
                                        .font(AppTheme.Typography.headline)
                                        .foregroundStyle(AppTheme.Colors.primaryText)
                                    PocketStatusBadge(estadoPostulacion: postulacion.estado)
                                    Text("La convocatoria relacionada ya no aparece en los datos locales.")
                                        .font(AppTheme.Typography.caption)
                                        .foregroundStyle(AppTheme.Colors.secondaryText)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.screenHorizontal)
            .padding(.vertical, AppTheme.Spacing.md)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationTitle("Mis postulaciones")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func tarjetaPostulacion(
        _ postulacion: Postulacion,
        oportunidad: Oportunidad
    ) -> some View {
        PocketCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                HStack(alignment: .top, spacing: AppTheme.Spacing.xs) {
                    Text(oportunidad.titulo)
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.Colors.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }

                Text(oportunidad.tipo.rawValue)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)

                HStack(spacing: AppTheme.Spacing.xs) {
                    PocketStatusBadge(estadoPostulacion: postulacion.estado)
                    Spacer(minLength: 4)
                    Text(
                        postulacion.fechaPostulacion,
                        format: .dateTime.day().month(.abbreviated).year()
                    )
                    .font(AppTheme.Typography.small)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                }

                if let observaciones = postulacion.observaciones,
                   !observaciones.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Divider()
                    Text("Observaciones: \(observaciones)")
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }
            }
        }
    }

    // MARK: - Detalle: oportunidades guardadas

    private var vistaGuardadas: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                PocketSectionHeader(
                    title: "Oportunidades guardadas",
                    subtitle: "\(misFavoritas.count) proyecto(s) en tu lista",
                    actionTitle: "Explorar",
                    action: abrirOportunidades
                )

                if misFavoritas.isEmpty {
                    PocketEmptyState(
                        title: "Aún no guardas oportunidades",
                        message: "Toca el marcador de una convocatoria para encontrarla aquí después.",
                        systemImage: "bookmark",
                        actionTitle: "Buscar oportunidades",
                        actionSystemImage: "magnifyingglass",
                        action: abrirOportunidades
                    )
                } else {
                    ForEach(misFavoritas) { oportunidad in
                        PocketCard {
                            HStack(alignment: .center, spacing: AppTheme.Spacing.md) {
                                NavigationLink {
                                    OportunidadDetalleView(
                                        oportunidad: oportunidad,
                                        servicio: servicio
                                    )
                                } label: {
                                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                                        Text(oportunidad.titulo)
                                            .font(AppTheme.Typography.headline)
                                            .foregroundStyle(AppTheme.Colors.primaryText)

                                        Text(oportunidad.tipo.rawValue)
                                            .font(AppTheme.Typography.caption)
                                            .foregroundStyle(AppTheme.Colors.secondaryText)

                                        PocketStatusBadge(oportunidad: oportunidad)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)

                                Button {
                                    quitarFavorito(oportunidad)
                                } label: {
                                    Image(systemName: "bookmark.slash")
                                        .foregroundStyle(AppTheme.Colors.blue)
                                        .font(.title3)
                                        .frame(width: 44, height: 44)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Quitar de guardadas: \(oportunidad.titulo)")
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.screenHorizontal)
            .padding(.vertical, AppTheme.Spacing.md)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationTitle("Oportunidades guardadas")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func quitarFavorito(_ oportunidad: Oportunidad) {
        do {
            _ = try servicio.alternarFavorito(
                oportunidadID: oportunidad.id,
                estudiante: estudiante
            )
        } catch {
            mensajeError = error.localizedDescription
            mostrarError = true
        }
    }

    // MARK: - Detalle: notificaciones (solo actividad local)

    private var vistaNotificaciones: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                PocketSectionHeader(
                    title: "Actividad de postulaciones",
                    subtitle: "Estados actuales de tus solicitudes"
                )

                if misPostulaciones.isEmpty {
                    PocketEmptyState(
                        title: "Sin actividad reciente",
                        message: "Cuando te postules a una oportunidad, podrás consultar aquí su estado guardado en la aplicación.",
                        systemImage: "bell.slash"
                    )
                } else {
                    ForEach(misPostulaciones) { postulacion in
                        PocketCard {
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                                Text(
                                    servicio.oportunidad(conID: postulacion.oportunidadId)?.titulo
                                    ?? "Proyecto no disponible"
                                )
                                .font(AppTheme.Typography.headline)
                                .foregroundStyle(AppTheme.Colors.primaryText)

                                PocketStatusBadge(estadoPostulacion: postulacion.estado)

                                Text(
                                    postulacion.fechaPostulacion,
                                    format: .dateTime.day().month(.abbreviated).year()
                                )
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.secondaryText)

                                if let observaciones = postulacion.observaciones,
                                   !observaciones.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    Text("Observaciones: \(observaciones)")
                                        .font(AppTheme.Typography.footnote)
                                        .foregroundStyle(AppTheme.Colors.secondaryText)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                Text("Esta sección muestra información local. No envía notificaciones push ni consulta los sistemas oficiales de la UACAM.")
                    .font(AppTheme.Typography.small)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
            .padding(.horizontal, AppTheme.Spacing.screenHorizontal)
            .padding(.vertical, AppTheme.Spacing.md)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationTitle("Notificaciones")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Detalle: configuración y cerrar sesión

    private var vistaConfiguracion: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                PocketSectionHeader(
                    title: "Configuración",
                    subtitle: "Preferencias de esta demostración"
                )

                PocketCard {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        Label("Modo demostración", systemImage: "info.circle")
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.Colors.primaryText)

                        Text("Cuenta local de demostración. Las solicitudes y los favoritos se muestran para el estudiante que inició sesión. No existe autenticación institucional.")
                            .font(AppTheme.Typography.footnote)
                            .foregroundStyle(AppTheme.Colors.secondaryText)

                        Divider()

                        Button {
                            confirmarCambioDePerfil = true
                        } label: {
                            HStack(spacing: AppTheme.Spacing.sm) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.title3)
                                Text("Cerrar sesión")
                                    .font(AppTheme.Typography.bodyMedium)
                                Spacer(minLength: 0)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }
                            .foregroundStyle(AppTheme.Colors.blue)
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }

                Text("Para entrar con el otro rol, cierra sesión e inicia con la cuenta de prueba correspondiente. No se eliminan los registros académicos locales.")
                    .font(AppTheme.Typography.small)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
            .padding(.horizontal, AppTheme.Spacing.screenHorizontal)
            .padding(.vertical, AppTheme.Spacing.md)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationTitle("Configuración")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Aviso de demostración

    private var avisoPrototipo: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.xs) {
            Image(systemName: "info.circle")
            Text("Perfil de demostración. Tus postulaciones y oportunidades guardadas se conservan en este dispositivo; no son trámites oficiales de la UACAM.")
        }
        .font(AppTheme.Typography.small)
        .foregroundStyle(AppTheme.Colors.secondaryText)
        .padding(.top, AppTheme.Spacing.sm)
    }
}

// MARK: - Vista previa

#Preview("Perfil - UACAM Pocket") {
    PerfilView(
        servicio: PocketDataService(),
        abrirOportunidades: { },
        cerrarSesion: { }
    )
}
