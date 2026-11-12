//
//  DocentesView.swift
//  UACAMPocket
//
//  Created by Alfredo on 09/11/26.
//


import SwiftUI

// MARK: - PANEL DOCENTE
// Pantalla de demostración: las decisiones se guardan localmente.
// No implica validación ni autorización institucional.

struct DocentesView: View {
    @ObservedObject var servicio: PocketDataService
    @State private var mostrarCrearOportunidad = false

    private var docente: Usuario { servicio.docenteDemo }

    private var proyectos: [Oportunidad] {
        servicio.proyectosDe(docente)
            .sorted { $0.fechaPublicacion > $1.fechaPublicacion }
    }

    private var solicitudesRecibidas: [Postulacion] {
        let ids = Set(proyectos.map(\.id))
        return servicio.postulaciones.filter {
            ids.contains($0.oportunidadId)
        }
    }

    private var vacantesDisponibles: Int {
        proyectos.reduce(0) { $0 + $1.vacantes }
    }

    private var solicitudesPendientes: Int {
        solicitudesRecibidas.filter(\.estaPendiente).count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.section) {
                    encabezado
                    PocketPrimaryButton(
                        title: "Publicar nuevo proyecto",
                        systemImage: "plus.circle.fill"
                    ) {
                        mostrarCrearOportunidad = true
                    }
                    resumen
                    seccionProyectos
                    avisoDemostracion
                }
                .padding(.horizontal, AppTheme.Spacing.screenHorizontal)
                .padding(.top, AppTheme.Spacing.md)
                .padding(.bottom, AppTheme.Spacing.xxxl)
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())
            .navigationTitle("Panel docente")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $mostrarCrearOportunidad) {
            NavigationStack {
                CrearOportunidadView(servicio: servicio)
            }
        }
    }

    private var encabezado: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Label("ESPACIO DOCENTE", systemImage: "person.crop.rectangle.stack")
                .font(AppTheme.Typography.captionBold)
                .foregroundStyle(.white.opacity(0.8))

            Text("Mis proyectos")
                .font(AppTheme.Typography.title2)
                .foregroundStyle(.white)

            Text("Hola, \(docente.nombre). Consulta tus convocatorias y revisa los intereses registrados.")
                .font(AppTheme.Typography.footnote)
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Spacing.xl)
        .background(
            AppTheme.Gradients.header,
            in: RoundedRectangle(cornerRadius: AppTheme.Radius.extraLarge)
        )
    }

    private var resumen: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PocketSectionHeader(title: "Resumen")

            HStack(spacing: AppTheme.Spacing.sm) {
                tarjetaContador(
                    titulo: "Proyectos",
                    cantidad: proyectos.count,
                    icono: "folder.fill"
                )
                tarjetaContador(
                    titulo: "Vacantes",
                    cantidad: vacantesDisponibles,
                    icono: "person.2.fill"
                )
                tarjetaContador(
                    titulo: "Pendientes",
                    cantidad: solicitudesPendientes,
                    icono: "clock.fill"
                )
            }
        }
    }

    private func tarjetaContador(
        titulo: String,
        cantidad: Int,
        icono: String
    ) -> some View {
        PocketCard(padding: AppTheme.Spacing.sm) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Image(systemName: icono)
                    .foregroundStyle(AppTheme.Colors.blue)
                Text("\(cantidad)")
                    .font(AppTheme.Typography.title2)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                Text(titulo)
                    .font(AppTheme.Typography.small)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
    }

    private var seccionProyectos: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PocketSectionHeader(
                title: "Convocatorias publicadas",
                subtitle: "\(proyectos.count) proyectos de demostración"
            )

            if proyectos.isEmpty {
                PocketEmptyState(
                    title: "Aún no hay proyectos",
                    message: "Cuando publiques una convocatoria, aparecerá aquí.",
                    systemImage: "folder.badge.plus"
                )
            } else {
                LazyVStack(spacing: AppTheme.Spacing.md) {
                    ForEach(proyectos) { proyecto in
                        NavigationLink {
                            DocenteDetalleProyectoView(
                                servicio: servicio,
                                proyectoID: proyecto.id
                            )
                        } label: {
                            tarjetaProyecto(proyecto)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func tarjetaProyecto(_ proyecto: Oportunidad) -> some View {
        PocketCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                HStack(alignment: .top) {
                    Text(proyecto.tipo.rawValue.uppercased())
                        .font(AppTheme.Typography.captionBold)
                        .foregroundStyle(AppTheme.Colors.blue)

                    Spacer(minLength: 8)
                    PocketStatusBadge(oportunidad: proyecto)
                }

                Text(proyecto.titulo)
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .multilineTextAlignment(.leading)

                Text(proyecto.facultad)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)

                Divider()

                HStack(spacing: AppTheme.Spacing.md) {
                    Label(proyecto.vacantesTexto, systemImage: "person.2")
                    Label(
                        "\(servicio.postulacionesDeOportunidad(proyecto.id).count) solicitudes",
                        systemImage: "doc.text"
                    )
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                }
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.secondaryText)
            }
        }
    }

    private var avisoDemostracion: some View {
        Label(
            "Panel de demostración. Los proyectos, usuarios y cambios de estado se guardan solamente en este dispositivo. No son gestiones oficiales de la UACAM.",
            systemImage: "info.circle"
        )
        .font(AppTheme.Typography.small)
        .foregroundStyle(AppTheme.Colors.secondaryText)
    }
}

// MARK: - GESTIÓN DE UN PROYECTO

private struct DocenteDetalleProyectoView: View {
    @ObservedObject var servicio: PocketDataService
    let proyectoID: UUID

    @State private var mostrarCambioEstado = false
    @State private var mostrarError = false
    @State private var mensajeError = ""

    private var proyecto: Oportunidad? {
        servicio.oportunidad(conID: proyectoID)
    }

    private var solicitudes: [Postulacion] {
        servicio.postulacionesDeOportunidad(proyectoID)
            .sorted { $0.fechaPostulacion > $1.fechaPostulacion }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.section) {
                if let proyecto {
                    resumenProyecto(proyecto)
                    seccionControl(proyecto)
                    seccionSolicitudes
                } else {
                    PocketEmptyState(
                        title: "Proyecto no encontrado",
                        message: "La convocatoria ya no está disponible en los datos locales.",
                        systemImage: "exclamationmark.triangle"
                    )
                }
            }
            .padding(.horizontal, AppTheme.Spacing.screenHorizontal)
            .padding(.top, AppTheme.Spacing.md)
            .padding(.bottom, AppTheme.Spacing.xxxl)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationTitle("Gestionar proyecto")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Cambiar estado de convocatoria",
            isPresented: $mostrarCambioEstado,
            titleVisibility: .visible
        ) {
            ForEach(EstadoOportunidad.allCases) { estado in
                Button(estado.rawValue) {
                    cambiarEstadoProyecto(a: estado)
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("El nuevo estado de la convocatoria se guardará en este dispositivo.")
        }
        .alert("No se pudo guardar el cambio", isPresented: $mostrarError) {
            Button("Entendido", role: .cancel) {}
        } message: {
            Text(mensajeError)
        }
    }

    private func resumenProyecto(_ proyecto: Oportunidad) -> some View {
        PocketCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                Text(proyecto.tipo.rawValue.uppercased())
                    .font(AppTheme.Typography.captionBold)
                    .foregroundStyle(AppTheme.Colors.blue)

                Text(proyecto.titulo)
                    .font(AppTheme.Typography.title2)
                    .foregroundStyle(AppTheme.Colors.primaryText)

                PocketStatusBadge(oportunidad: proyecto)

                Divider()

                Label(proyecto.facultad, systemImage: "building.2")
                Label(proyecto.modalidad.rawValue, systemImage: "location")
                Label(proyecto.vacantesTexto, systemImage: "person.2")
                Label("\(solicitudes.count) postulaciones", systemImage: "doc.text")

                Text(proyecto.descripcion)
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
            .font(AppTheme.Typography.subheadline)
            .foregroundStyle(AppTheme.Colors.primaryText)
        }
    }

    private func seccionControl(_ proyecto: Oportunidad) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PocketSectionHeader(title: "Administrar convocatoria")

            PocketCard {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    HStack {
                        Text("Estado actual")
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                        Spacer()
                        Text(proyecto.estado.rawValue)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.Colors.primaryText)
                    }
                    .font(AppTheme.Typography.footnote)

                    PocketPrimaryButton(
                        title: "Cambiar estado",
                        systemImage: "arrow.triangle.2.circlepath"
                    ) {
                        mostrarCambioEstado = true
                    }
                }
            }
        }
    }

    private var seccionSolicitudes: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PocketSectionHeader(
                title: "Postulaciones recibidas",
                subtitle: "\(solicitudes.count) solicitudes registradas"
            )

            if solicitudes.isEmpty {
                PocketEmptyState(
                    title: "Sin estudiantes interesados",
                    message: "Cuando un estudiante se postule a este proyecto, podrás revisar su solicitud aquí.",
                    systemImage: "person.crop.circle.badge.questionmark"
                )
            } else {
                ForEach(solicitudes) { postulacion in
                    PostulacionDocenteCard(
                        postulacion: postulacion,
                        nombreEstudiante: nombreDeEstudiante(postulacion)
                    ) { nuevoEstado, observaciones in
                        cambiarEstadoPostulacion(
                            id: postulacion.id,
                            a: nuevoEstado,
                            observaciones: observaciones
                        )
                    }
                }
            }
        }
    }

    private func nombreDeEstudiante(_ postulacion: Postulacion) -> String {
        servicio.nombreDeEstudiante(conID: postulacion.estudianteId)
    }

    private func cambiarEstadoProyecto(a estado: EstadoOportunidad) {
        do {
            try servicio.cambiarEstadoDeOportunidad(
                id: proyectoID,
                a: estado,
                docente: servicio.docenteDemo
            )
        } catch {
            mensajeError = error.localizedDescription
            mostrarError = true
        }
    }

    private func cambiarEstadoPostulacion(
        id: UUID,
        a estado: EstadoPostulacion,
        observaciones: String?
    ) {
        do {
            try servicio.cambiarEstadoDePostulacion(
                id: id,
                a: estado,
                docente: servicio.docenteDemo,
                observaciones: observaciones
            )
        } catch {
            mensajeError = error.localizedDescription
            mostrarError = true
        }
    }
}

// MARK: - TARJETA DE POSTULACIÓN DOCENTE

private struct PostulacionDocenteCard: View {
    let postulacion: Postulacion
    let nombreEstudiante: String
    let cambiarEstado: (EstadoPostulacion, String?) -> Void

    @State private var observaciones: String
    @State private var estadoPendiente: EstadoPostulacion?
    @State private var confirmarCambio = false

    init(
        postulacion: Postulacion,
        nombreEstudiante: String,
        cambiarEstado: @escaping (EstadoPostulacion, String?) -> Void
    ) {
        self.postulacion = postulacion
        self.nombreEstudiante = nombreEstudiante
        self.cambiarEstado = cambiarEstado
        _observaciones = State(initialValue: postulacion.observaciones ?? "")
    }

    var body: some View {
        PocketCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                        Text(nombreEstudiante)
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.Colors.primaryText)
                        Text(
                            postulacion.fechaPostulacion,
                            format: .dateTime.day().month(.abbreviated).year()
                        )
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                    }
                    Spacer(minLength: 4)
                    PocketStatusBadge(estadoPostulacion: postulacion.estado)
                }

                if let mensaje = postulacion.mensajeEstudiante,
                   !mensaje.isEmpty {
                    Text("Mensaje: \(mensaje)")
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }

                if postulacion.estaPendiente {
                    TextField(
                        "Observaciones para el estudiante (opcional)",
                        text: $observaciones,
                        axis: .vertical
                    )
                    .lineLimit(2...4)
                    .textFieldStyle(.roundedBorder)

                    if postulacion.estado == .enviada {
                        Button("Marcar en revisión") {
                            solicitarCambio(.enRevision)
                        }
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(AppTheme.Colors.blue)
                        .frame(maxWidth: .infinity, minHeight: 44)
                    }

                    HStack(spacing: AppTheme.Spacing.sm) {
                        Button {
                            solicitarCambio(.aceptada)
                        } label: {
                            Label("Aceptar", systemImage: "checkmark")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.bordered)
                        .tint(AppTheme.Colors.success)

                        Button {
                            solicitarCambio(.rechazada)
                        } label: {
                            Label("Rechazar", systemImage: "xmark")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.bordered)
                        .tint(AppTheme.Colors.error)
                    }
                } else if let observacion = postulacion.observaciones,
                          !observacion.isEmpty {
                    Text("Observaciones: \(observacion)")
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }
            }
        }
        .confirmationDialog(
            "Confirmar decisión",
            isPresented: $confirmarCambio,
            titleVisibility: .visible
        ) {
            if let estadoPendiente {
                Button(
                    "Confirmar: \(estadoPendiente.rawValue)",
                    role: estadoPendiente == .rechazada ? .destructive : nil
                ) {
                    let texto = observaciones.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    cambiarEstado(
                        estadoPendiente,
                        texto.isEmpty ? nil : texto
                    )
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("La decisión se guardará localmente. Aceptar una postulación descuenta una vacante del proyecto.")
        }
    }

    private func solicitarCambio(_ estado: EstadoPostulacion) {
        estadoPendiente = estado
        confirmarCambio = true
    }
}

// MARK: - PREVIEW

#Preview("Panel docente - UACAM Pocket") {
    DocentesView(servicio: PocketDataService())
}
