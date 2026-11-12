//
//  OportunidadDetalleView.swift
//  UACAMPocket
//
//  Created by Alfredo on 09/11/26.
//


import SwiftUI

// MARK: - ARCHIVO 28: DETALLE DE OPORTUNIDAD
// Features/Oportunidades/OportunidadDetalleView.swift
//
// Diseño inspirado en la página 6 del anteproyecto UACAM Pocket.
// Reutiliza PocketDataService: no crea un almacenamiento nuevo,
// no cambia las reglas de postulación y no modifica las vacantes.

struct OportunidadDetalleView: View {

    let oportunidad: Oportunidad
    @ObservedObject var servicio: PocketDataService

    @State private var mensajeEstudiante = ""
    @State private var mostrarConfirmacion = false
    @State private var mostrarAlerta = false
    @State private var tituloAlerta = ""
    @State private var mensajeAlerta = ""
    @FocusState private var mensajeEnEdicion: Bool

    // Siempre leemos el registro vigente del servicio. Así, cuando el
    // docente acepta una postulación, se actualizan las vacantes y
    // el estado mostrado sin usar una copia antigua del proyecto.
    private var proyecto: Oportunidad {
        servicio.oportunidad(conID: oportunidad.id) ?? oportunidad
    }

    private var miPostulacion: Postulacion? {
        servicio.postulacion(
            estudianteID: servicio.estudianteDemo.id,
            oportunidadID: oportunidad.id
        )
    }

    private var guardada: Bool {
        servicio.esFavorita(oportunidad.id)
    }

    private var operacionBloqueada: Bool {
        servicio.errorAlCargar != nil
    }

    // MARK: - VISTA PRINCIPAL

    var body: some View {
        ScrollViewReader { lector in
            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: AppTheme.Spacing.section
                ) {
                    encabezado

                    if let error = servicio.errorAlCargar {
                        avisoErrorDeCarga(error)
                    }

                    seccionInformacion
                    seccionPerfil
                    seccionDescripcion
                    seccionFechas
                    seccionAcreditacion

                    if let postulacion = miPostulacion {
                        seccionSeguimiento(postulacion)
                            .id("seguimiento")
                    } else if proyecto.estaDisponible {
                        seccionMensaje
                    }

                    avisoPrototipo
                }
                .padding(
                    .horizontal,
                    AppTheme.Spacing.screenHorizontal
                )
                .padding(.top, AppTheme.Spacing.md)
                .padding(.bottom, AppTheme.Spacing.lg)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(AppTheme.Colors.background.ignoresSafeArea())
            .safeAreaInset(edge: .bottom, spacing: 0) {
                // Al escribir el mensaje se libera espacio para el teclado.
                if !mensajeEnEdicion {
                    barraAcciones {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            lector.scrollTo("seguimiento", anchor: .top)
                        }
                    }
                }
            }
            .navigationTitle("Detalle de oportunidad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Listo") {
                        mensajeEnEdicion = false
                    }
                }
            }
            .confirmationDialog(
                "Confirmar postulación",
                isPresented: $mostrarConfirmacion,
                titleVisibility: .visible
            ) {
                Button("Enviar postulación") {
                    enviarPostulacion()
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text(
                    "Se registrará tu interés en esta convocatoria de " +
                    "demostración. No equivale a una solicitud oficial de la UACAM."
                )
            }
            .alert(tituloAlerta, isPresented: $mostrarAlerta) {
                Button("Aceptar", role: .cancel) {}
            } message: {
                Text(mensajeAlerta)
            }
        }
    }

    // MARK: - ENCABEZADO, CATEGORÍA Y FAVORITO

    private var encabezado: some View {
        PocketCard {
            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.md
            ) {
                HStack(alignment: .center, spacing: AppTheme.Spacing.sm) {
                    Label(
                        proyecto.tipo.rawValue,
                        systemImage: iconoDeCategoria
                    )
                    .font(AppTheme.Typography.captionBold)
                    .foregroundStyle(colorDeCategoria)
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, AppTheme.Spacing.xs)
                    .background(
                        colorDeCategoria.opacity(0.10),
                        in: Capsule()
                    )

                    Spacer(minLength: 4)

                    Button {
                        alternarFavorito()
                    } label: {
                        Image(
                            systemName: guardada
                                ? "bookmark.fill"
                                : "bookmark"
                        )
                        .font(.system(size: 21, weight: .medium))
                        .foregroundStyle(AppTheme.Colors.blue)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(operacionBloqueada)
                    .accessibilityLabel(
                        guardada
                            ? "Quitar de oportunidades guardadas"
                            : "Guardar oportunidad"
                    )
                }

                Text(proyecto.titulo)
                    .font(AppTheme.Typography.title2)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Conoce el proyecto, sus requisitos y cómo participar.")
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.Colors.secondaryText)

                HStack(spacing: AppTheme.Spacing.sm) {
                    PocketStatusBadge(oportunidad: proyecto)

                    if let postulacion = miPostulacion {
                        PocketStatusBadge(
                            estadoPostulacion: postulacion.estado
                        )
                    }
                }
            }
        }
    }

    // MARK: - INFORMACIÓN GENERAL

    private var seccionInformacion: some View {
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {
            PocketSectionHeader(title: "Información del proyecto")

            PocketCard {
                VStack(spacing: AppTheme.Spacing.md) {
                    filaInformacion(
                        "Profesor responsable",
                        valor: proyecto.docenteResponsable,
                        icono: "person.fill"
                    )

                    Divider()

                    filaInformacion(
                        "Facultad",
                        valor: proyecto.facultad,
                        icono: "building.2.fill"
                    )

                    Divider()

                    HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                        celdaInformacion(
                            "Vacantes",
                            valor: proyecto.vacantesTexto,
                            icono: "person.2.fill"
                        )

                        celdaInformacion(
                            "Modalidad",
                            valor: proyecto.modalidad.rawValue,
                            icono: "mappin.and.ellipse"
                        )
                    }

                    if let carrera = proyecto.carrera,
                       !carrera.isEmpty {
                        Divider()

                        filaInformacion(
                            "Carrera",
                            valor: carrera,
                            icono: "graduationcap.fill"
                        )
                    }
                }
            }
        }
    }

    private func filaInformacion(
        _ titulo: String,
        valor: String,
        icono: String
    ) -> some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
            iconoInformacion(icono)

            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.xxs
            ) {
                Text(titulo)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)

                Text(valor)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func celdaInformacion(
        _ titulo: String,
        valor: String,
        icono: String
    ) -> some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.xs) {
            Image(systemName: icono)
                .font(.footnote)
                .foregroundStyle(AppTheme.Colors.blue)
                .frame(width: 19)
                .accessibilityHidden(true)

            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.xxs
            ) {
                Text(titulo)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)

                Text(valor)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func iconoInformacion(_ nombre: String) -> some View {
        Image(systemName: nombre)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(AppTheme.Colors.blue)
            .frame(width: 38, height: 38)
            .background(
                AppTheme.Colors.blue.opacity(0.08),
                in: RoundedRectangle(
                    cornerRadius: AppTheme.Radius.medium
                )
            )
            .accessibilityHidden(true)
    }

    // MARK: - PERFIL REQUERIDO

    private var seccionPerfil: some View {
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {
            PocketSectionHeader(title: "Perfil requerido")

            PocketCard {
                HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                    iconoInformacion("graduationcap.fill")

                    VStack(
                        alignment: .leading,
                        spacing: AppTheme.Spacing.xs
                    ) {
                        Text("Conocimientos y habilidades")
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.Colors.primaryText)

                        Text(proyecto.perfilRequerido)
                            .font(AppTheme.Typography.body)
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    // MARK: - SOBRE EL PROYECTO

    private var seccionDescripcion: some View {
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {
            PocketSectionHeader(title: "Sobre el proyecto")

            PocketCard {
                Text(proyecto.descripcion)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - FECHAS

    private var seccionFechas: some View {
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {
            PocketSectionHeader(title: "Fechas de la convocatoria")

            PocketCard {
                VStack(spacing: AppTheme.Spacing.md) {
                    filaInformacion(
                        "Publicada el",
                        valor: fechaLarga(proyecto.fechaPublicacion),
                        icono: "calendar"
                    )

                    Divider()

                    filaInformacion(
                        "Fecha límite",
                        valor: proyecto.fechaLimite.map(fechaLarga)
                            ?? "No especificada",
                        icono: "calendar.badge.clock"
                    )
                }
            }
        }
    }

    private func fechaLarga(_ fecha: Date) -> String {
        fecha.formatted(
            .dateTime
                .day()
                .month(.wide)
                .year()
                .locale(Locale(identifier: "es_MX"))
        )
    }

    // MARK: - POSIBLE ACREDITACIÓN

    private var seccionAcreditacion: some View {
        PocketCard(showBorder: true, showShadow: false) {
            HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                Image(systemName: "checkmark.seal")
                    .font(.title2)
                    .foregroundStyle(AppTheme.Colors.blue)
                    .accessibilityHidden(true)

                VStack(
                    alignment: .leading,
                    spacing: AppTheme.Spacing.xs
                ) {
                    Text("Posible acreditación")
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.Colors.primaryText)

                    Text(
                        proyecto.acreditacionValidada
                            ? "Este proyecto aparece como validado en los datos " +
                              "locales de demostración. Confirma su reconocimiento " +
                              "y vigencia con la UACAM."
                            : "La acreditación como servicio social o prácticas " +
                              "profesionales está sujeta a validación institucional. " +
                              "Confirma los requisitos con la UACAM."
                    )
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                }
            }
        }
    }

    // MARK: - MENSAJE OPCIONAL

    private var seccionMensaje: some View {
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {
            PocketSectionHeader(title: "Antes de postularte")

            PocketCard {
                VStack(
                    alignment: .leading,
                    spacing: AppTheme.Spacing.sm
                ) {
                    Text("Mensaje al docente (opcional)")
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.Colors.primaryText)

                    TextField(
                        "Cuéntale por qué te interesa el proyecto...",
                        text: $mensajeEstudiante,
                        axis: .vertical
                    )
                    .lineLimit(3...5)
                    .textInputAutocapitalization(.sentences)
                    .focused($mensajeEnEdicion)
                    .padding(AppTheme.Spacing.sm)
                    .background(
                        AppTheme.Colors.background,
                        in: RoundedRectangle(
                            cornerRadius: AppTheme.Radius.medium
                        )
                    )

                    Text(
                        "El mensaje se guarda junto con tu postulación " +
                        "en este dispositivo."
                    )
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                }
            }
        }
    }

    // MARK: - SEGUIMIENTO DE POSTULACIÓN REAL

    private func seccionSeguimiento(
        _ postulacion: Postulacion
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {
            PocketSectionHeader(title: "Seguimiento de mi postulación")

            PocketCard {
                VStack(
                    alignment: .leading,
                    spacing: AppTheme.Spacing.md
                ) {
                    HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                        iconoInformacion(postulacion.estado.icono)

                        VStack(
                            alignment: .leading,
                            spacing: AppTheme.Spacing.xs
                        ) {
                            Text("Estado actual")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.secondaryText)

                            PocketStatusBadge(
                                estadoPostulacion: postulacion.estado
                            )
                        }
                    }

                    Text(postulacion.estado.descripcion)
                        .font(AppTheme.Typography.body)
                        .foregroundStyle(AppTheme.Colors.primaryText)

                    Divider()

                    filaFecha(
                        "Enviada",
                        fecha: postulacion.fechaPostulacion
                    )

                    filaFecha(
                        "Última actualización",
                        fecha: postulacion.fechaActualizacion
                    )

                    if let observaciones = postulacion.observaciones,
                       !observaciones.isEmpty {
                        Divider()

                        Text("Observaciones del docente")
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.Colors.primaryText)

                        Text(observaciones)
                            .font(AppTheme.Typography.body)
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                    }

                    if let mensaje = postulacion.mensajeEstudiante,
                       !mensaje.isEmpty {
                        Divider()

                        Text("Tu mensaje")
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.Colors.primaryText)

                        Text(mensaje)
                            .font(AppTheme.Typography.footnote)
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                    }

                    Label(
                        "Ya tienes una postulación registrada para este " +
                        "proyecto. No se permiten duplicados.",
                        systemImage: "checkmark.shield"
                    )
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                }
            }
        }
    }

    private func filaFecha(
        _ titulo: String,
        fecha: Date
    ) -> some View {
        HStack(
            alignment: .firstTextBaseline,
            spacing: AppTheme.Spacing.xs
        ) {
            Text(titulo)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.secondaryText)

            Spacer(minLength: 4)

            Text(fecha, format: .dateTime.day().month(.abbreviated).year())
                .font(AppTheme.Typography.captionBold)
                .foregroundStyle(AppTheme.Colors.primaryText)
        }
    }

    // MARK: - BOTONES INFERIORES

    private func barraAcciones(
        abrirSeguimiento: @escaping () -> Void
    ) -> some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            if miPostulacion != nil {
                PocketPrimaryButton(
                    title: "Ver seguimiento",
                    systemImage: "arrow.down"
                ) {
                    abrirSeguimiento()
                }
            } else {
                PocketPrimaryButton(
                    title: proyecto.estaDisponible
                        ? "Postularme"
                        : "Convocatoria no disponible",
                    systemImage: "paperplane.fill",
                    isDisabled: !proyecto.estaDisponible || operacionBloqueada
                ) {
                    mensajeEnEdicion = false
                    mostrarConfirmacion = true
                }
            }

            Button {
                alternarFavorito()
            } label: {
                Label(
                    guardada ? "Quitar de guardadas" : "Guardar oportunidad",
                    systemImage: guardada ? "bookmark.fill" : "bookmark"
                )
                .font(AppTheme.Typography.bodyMedium)
                .foregroundStyle(AppTheme.Colors.blue)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 48)
                .background(
                    AppTheme.Colors.surface,
                    in: RoundedRectangle(
                        cornerRadius: AppTheme.Radius.medium
                    )
                )
                .overlay {
                    RoundedRectangle(
                        cornerRadius: AppTheme.Radius.medium
                    )
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
            .disabled(operacionBloqueada)
            .accessibilityLabel(
                guardada
                    ? "Quitar oportunidad de guardadas"
                    : "Guardar oportunidad"
            )
        }
        .padding(.horizontal, AppTheme.Spacing.screenHorizontal)
        .padding(.top, AppTheme.Spacing.sm)
        .padding(.bottom, AppTheme.Spacing.xs)
        .background(AppTheme.Colors.surface)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppTheme.Colors.border)
                .frame(height: 1)
        }
    }

    // MARK: - MENSAJES DE SEGURIDAD DEL PROTOTIPO

    private func avisoErrorDeCarga(_ mensaje: String) -> some View {
        PocketCard(showBorder: true, showShadow: false) {
            Label(
                "No se pudieron cargar los datos: \(mensaje). " +
                "No se harán cambios para proteger la información guardada.",
                systemImage: "exclamationmark.triangle"
            )
            .font(AppTheme.Typography.footnote)
            .foregroundStyle(AppTheme.Colors.error)
        }
    }

    private var avisoPrototipo: some View {
        Label(
            "Prototipo académico: las convocatorias y las postulaciones " +
            "son datos locales de demostración. " +
            "La UACAM debe validar cualquier acreditación oficial.",
            systemImage: "info.circle"
        )
        .font(AppTheme.Typography.small)
        .foregroundStyle(AppTheme.Colors.secondaryText)
    }

    // MARK: - ICONOGRAFÍA SEGÚN CATEGORÍA

    private var iconoDeCategoria: String {
        let tipo = proyecto.tipo.rawValue.lowercased()

        if tipo.contains("servicio") { return "graduationcap.fill" }
        if tipo.contains("práctic") || tipo.contains("practic") {
            return "person.2.fill"
        }
        if tipo.contains("investig") { return "chart.bar.xaxis" }
        if tipo.contains("tecnolog") { return "cpu" }
        return "briefcase.fill"
    }

    private var colorDeCategoria: Color {
        let tipo = proyecto.tipo.rawValue.lowercased()

        if tipo.contains("servicio") { return AppTheme.Colors.warning }
        if tipo.contains("práctic") || tipo.contains("practic") {
            return AppTheme.Colors.blue
        }
        if tipo.contains("investig") { return .purple }
        if tipo.contains("tecnolog") { return AppTheme.Colors.success }
        return AppTheme.Colors.blue
    }

    // MARK: - OPERACIONES PERSISTENTES

    private func alternarFavorito() {
        do {
            _ = try servicio.alternarFavorito(
                oportunidadID: oportunidad.id,
                estudiante: servicio.estudianteDemo
            )
        } catch {
            presentarAlerta(
                "No se pudo guardar la oportunidad",
                mensaje: error.localizedDescription
            )
        }
    }

    private func enviarPostulacion() {
        let mensaje = mensajeEstudiante.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        do {
            // PocketDataService verifica rol, disponibilidad y que no
            // exista ya una postulación, incluso en otro estado.
            _ = try servicio.postular(
                estudiante: servicio.estudianteDemo,
                a: oportunidad.id,
                mensaje: mensaje.isEmpty ? nil : mensaje
            )

            presentarAlerta(
                "Postulación registrada",
                mensaje: "Tu solicitud de demostración quedó guardada " +
                         "en este dispositivo. Consulta su estado aquí o en Perfil."
            )
        } catch {
            presentarAlerta(
                "No se pudo enviar la postulación",
                mensaje: error.localizedDescription
            )
        }
    }

    private func presentarAlerta(
        _ titulo: String,
        mensaje: String
    ) {
        tituloAlerta = titulo
        mensajeAlerta = mensaje
        mostrarAlerta = true
    }
}

// MARK: - VISTA PREVIA

#Preview("Detalle de oportunidad - UACAM Pocket") {
    NavigationStack {
        OportunidadDetalleView(
            oportunidad: Oportunidad.ejemplos[0],
            servicio: PocketDataService()
        )
    }
    .environment(\.locale, Locale(identifier: "es_MX"))
}
