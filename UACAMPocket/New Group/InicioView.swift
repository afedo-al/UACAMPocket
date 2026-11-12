//
//  InicioView.swift
//  UACAMPocket
//
//  Created by Alfredo on 09/11/26.
//


import SwiftUI

// MARK: - INICIO
// Pantalla principal del estudiante. Las clases son de demostración.
// Las próximas entregas se leen del PocketTaskService compartido.
// Biblioteca abre eLibro UACAM; Campus y Trámites conservan su navegación.

struct InicioView: View {
    @ObservedObject var servicio: PocketDataService
    @ObservedObject var servicioTareas: PocketTaskService
    @Environment(\.openURL) private var openURL

    let abrirCalendario: () -> Void
    let abrirOportunidades: () -> Void
    let abrirTramites: (() -> Void)?
    let abrirCampus: (() -> Void)?
    let abrirTareas: (() -> Void)?

    @State private var mostrarAviso = false
    @State private var mensajeAviso = ""

    private let columnas = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.sm),
        GridItem(.flexible(), spacing: AppTheme.Spacing.sm),
        GridItem(.flexible(), spacing: AppTheme.Spacing.sm)
    ]

    init(
        servicio: PocketDataService,
        servicioTareas: PocketTaskService,
        abrirCalendario: @escaping () -> Void,
        abrirOportunidades: @escaping () -> Void,
        abrirTramites: (() -> Void)? = nil,
        abrirCampus: (() -> Void)? = nil,
        abrirTareas: (() -> Void)? = nil
    ) {
        self.servicio = servicio
        self.servicioTareas = servicioTareas
        self.abrirCalendario = abrirCalendario
        self.abrirOportunidades = abrirOportunidades
        self.abrirTramites = abrirTramites
        self.abrirCampus = abrirCampus
        self.abrirTareas = abrirTareas
    }

    // Muestra hasta 3 tareas futuras pendientes, ordenadas por vencimiento.
    // La lista reacciona a cambios en TareasView y CalendarioView.
    private var entregasDestacadas: [PocketTask] {
        Array(servicioTareas.proximasEntregas.prefix(3))
    }

    private var oportunidadDestacada: Oportunidad? {
        servicio.buscarOportunidades(soloDisponibles: true).first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.section) {
                    encabezado
                    seccionClases
                    seccionEntregas
                    seccionAccesos
                    seccionOportunidad
                    avisoPrototipo
                }
                .padding(.horizontal, AppTheme.Spacing.screenHorizontal)
                .padding(.top, AppTheme.Spacing.xs)
                .padding(.bottom, AppTheme.Spacing.xxxl)
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .alert("Módulo en desarrollo", isPresented: $mostrarAviso) {
                Button("Entendido", role: .cancel) {}
            } message: {
                Text(mensajeAviso)
            }
        }
    }

    private var encabezado: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            HStack {
                HStack(spacing: AppTheme.Spacing.xxs) {
                    Text("UACAM").foregroundStyle(.white)
                    Text("POCKET").foregroundStyle(AppTheme.Colors.lightBlue)
                }
                .font(.system(size: 25, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

                Spacer()

                Button {
                    avisar("Notificaciones")
                } label: {
                    Image(systemName: "bell")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(.white.opacity(0.1), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Notificaciones")
            }

            Text("Tu universidad, siempre contigo.")
                .font(AppTheme.Typography.footnote)
                .foregroundStyle(.white.opacity(0.8))

            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: "person.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: AppTheme.Sizes.avatar, height: AppTheme.Sizes.avatar)
                    .background(AppTheme.Colors.blue, in: Circle())

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                    Text("¡Hola, \(servicio.estudianteDemo.nombre)!")
                        .font(AppTheme.Typography.title3)
                        .foregroundStyle(.white)
                    Text("Estudiante UACAM")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(.white.opacity(0.75))
                }
                Spacer(minLength: 0)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            AppTheme.Gradients.header,
            in: RoundedRectangle(cornerRadius: AppTheme.Radius.extraLarge)
        )
    }

    private var seccionClases: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PocketSectionHeader(title: "Tu día", actionTitle: "Ver todo", action: abrirCalendario)
            PocketCard {
                VStack(spacing: AppTheme.Spacing.md) {
                    filaClase("Programación Web", horario: "08:00 - 10:00", aula: "Aula 301", icono: "laptopcomputer")
                    Divider()
                    filaClase("Sistemas Inteligentes", horario: "11:00 - 13:00", aula: "Aula 205", icono: "brain.head.profile")
                }
            }
        }
    }

    private func filaClase(_ nombre: String, horario: String, aula: String, icono: String) -> some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icono)
                .font(.title3)
                .foregroundStyle(AppTheme.Colors.blue)
                .frame(width: 44, height: 44)
                .background(AppTheme.Colors.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: AppTheme.Radius.medium))

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text(nombre)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                Text(horario)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
            Spacer(minLength: 4)
            Text(aula)
                .font(AppTheme.Typography.small)
                .foregroundStyle(AppTheme.Colors.secondaryText)
        }
    }

    // MARK: - Entregas desde el servicio compartido

    private var seccionEntregas: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PocketSectionHeader(
                title: "Próximas entregas",
                subtitle: servicioTareas.pendientes == 0
                    ? "Sin tareas pendientes"
                    : "Actualizadas desde Mis tareas",
                actionTitle: abrirTareas == nil ? nil : "Ver todas",
                action: abrirTareas
            )

            if entregasDestacadas.isEmpty {
                PocketEmptyState(
                    title: "No hay próximas entregas",
                    message: "No tienes tareas pendientes con fecha de hoy o posterior. Puedes agregar una desde Tareas.",
                    systemImage: "checkmark.circle",
                    actionTitle: abrirTareas == nil ? nil : "Abrir tareas",
                    actionSystemImage: "plus.circle",
                    action: abrirTareas
                )
            } else {
                PocketCard {
                    VStack(spacing: AppTheme.Spacing.md) {
                        ForEach(entregasDestacadas) { tarea in
                            filaEntrega(tarea)
                            if tarea.id != entregasDestacadas.last?.id {
                                Divider()
                            }
                        }
                    }
                }
            }

            if !servicioTareas.tareasVencidas.isEmpty {
                Button {
                    if let abrirTareas {
                        abrirTareas()
                    } else {
                        avisar("Tareas")
                    }
                } label: {
                    Label(
                        "Tienes \(servicioTareas.tareasVencidas.count) tarea(s) vencida(s). Revisar pendientes",
                        systemImage: "exclamationmark.circle"
                    )
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.Colors.warning)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func filaEntrega(_ tarea: PocketTask) -> some View {
        HStack(alignment: .center, spacing: AppTheme.Spacing.sm) {
            Image(systemName: "doc.text")
                .foregroundStyle(AppTheme.Colors.blue)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text(tarea.titulo)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .lineLimit(2)

                HStack(spacing: AppTheme.Spacing.xs) {
                    Text(tarea.materia)
                        .lineLimit(1)

                    Circle()
                        .fill(colorPrioridad(tarea.prioridad))
                        .frame(width: 6, height: 6)
                        .accessibilityHidden(true)

                    Text(tarea.prioridad.rawValue)
                }
                .font(AppTheme.Typography.small)
                .foregroundStyle(AppTheme.Colors.secondaryText)
            }

            Spacer(minLength: 4)

            Text(textoFechaEntrega(tarea.fechaEntrega))
                .font(AppTheme.Typography.captionBold)
                .foregroundStyle(AppTheme.Colors.blue)
                .multilineTextAlignment(.trailing)
        }
        .accessibilityElement(children: .combine)
    }

    private func textoFechaEntrega(_ fecha: Date) -> String {
        let calendario = Calendar.current

        if calendario.isDateInToday(fecha) {
            return "Hoy"
        }
        if calendario.isDateInTomorrow(fecha) {
            return "Mañana"
        }

        let formateador = DateFormatter()
        formateador.locale = Locale(identifier: "es_MX")
        formateador.dateFormat = "d MMM"
        return formateador.string(from: fecha)
    }

    private func colorPrioridad(_ prioridad: PocketTaskPriority) -> Color {
        switch prioridad {
        case .alta: return AppTheme.Colors.error
        case .media: return AppTheme.Colors.warning
        case .baja: return AppTheme.Colors.success
        }
    }

    // MARK: - Accesos rápidos
    // Orden de la maqueta del anteproyecto (página 5):
    // Horario | Tareas | Oportunidades
    // Trámites | Biblioteca | Campus
    // Solo cambia la presentación; las acciones existentes se conservan.

    private var seccionAccesos: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PocketSectionHeader(title: "Accesos rápidos")

            LazyVGrid(columns: columnas, spacing: AppTheme.Spacing.sm) {
                // Fila 1: Horario
                PocketQuickAction(
                    title: "Horario",
                    systemImage: "calendar",
                    color: AppTheme.Colors.blue,
                    action: abrirCalendario
                )

                // Fila 1: Tareas
                PocketQuickAction(
                    title: "Tareas",
                    systemImage: "checklist",
                    color: AppTheme.Colors.success
                ) {
                    if let abrirTareas {
                        abrirTareas()
                    } else {
                        avisar("Tareas")
                    }
                }

                // Fila 1: Oportunidades (antes se llamaba "Proyectos")
                PocketQuickAction(
                    title: "Oportunidades",
                    systemImage: "trophy.fill",
                    color: AppTheme.Colors.warning,
                    action: abrirOportunidades
                )

                // Fila 2: Trámites
                PocketQuickAction(
                    title: "Trámites",
                    systemImage: "doc.text.fill",
                    color: AppTheme.Colors.blue
                ) {
                    if let abrirTramites {
                        abrirTramites()
                    } else {
                        avisar("Trámites")
                    }
                }

                // Fila 2: Biblioteca: portal eLibro UACAM
                PocketQuickAction(
                    title: "Biblioteca",
                    systemImage: "books.vertical.fill",
                    color: AppTheme.Colors.research
                ) {
                    if let url = URL(
                        string: "https://elibro.net/es/lc/uacam/inicio"
                    ) {
                        openURL(url)
                    }
                }

                // Fila 2: Campus
                PocketQuickAction(
                    title: "Campus",
                    systemImage: "mappin.and.ellipse",
                    color: AppTheme.Colors.error
                ) {
                    if let abrirCampus {
                        abrirCampus()
                    } else {
                        avisar("Campus")
                    }
                }
            }
        }
    }

    private var seccionOportunidad: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PocketSectionHeader(title: "Oportunidades para ti", actionTitle: "Ver todo", action: abrirOportunidades)
            if let oportunidad = oportunidadDestacada {
                PocketCard {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        HStack {
                            Text(oportunidad.tipo.rawValue.uppercased())
                                .font(AppTheme.Typography.captionBold)
                                .foregroundStyle(AppTheme.Colors.warning)
                            Spacer()
                            PocketStatusBadge(oportunidad: oportunidad)
                        }
                        Text(oportunidad.titulo)
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.Colors.primaryText)

                        Label(oportunidad.facultad, systemImage: "building.2")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.secondaryText)

                        HStack(spacing: AppTheme.Spacing.md) {
                            Label(oportunidad.vacantesTexto, systemImage: "person.2")
                            Label(oportunidad.modalidad.rawValue, systemImage: "location")
                        }
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)

                        PocketPrimaryButton(title: "Explorar oportunidad", systemImage: "arrow.right", action: abrirOportunidades)
                    }
                }
            } else {
                PocketEmptyState(
                    title: "Sin oportunidades disponibles",
                    message: "Por ahora no encontramos convocatorias abiertas con vacantes.",
                    systemImage: "tray",
                    actionTitle: "Ver oportunidades",
                    actionSystemImage: "magnifyingglass",
                    action: abrirOportunidades
                )
            }
        }
    }

    private var avisoPrototipo: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.xs) {
            Image(systemName: "info.circle")
            Text("Prototipo académico. Las clases son de ejemplo; las entregas provienen de tus tareas guardadas en este dispositivo. Biblioteca abre eLibro UACAM y Trámites enlaza a los recursos disponibles.")
        }
        .font(AppTheme.Typography.small)
        .foregroundStyle(AppTheme.Colors.secondaryText)
    }

    private func avisar(_ modulo: String) {
        mensajeAviso = "La sección \(modulo) se implementará en una próxima etapa de UACAM Pocket."
        mostrarAviso = true
    }
}

#Preview("Inicio - UACAM Pocket") {
    InicioView(
        servicio: PocketDataService(),
        servicioTareas: PocketTaskService(),
        abrirCalendario: {},
        abrirOportunidades: {}
    )
}
