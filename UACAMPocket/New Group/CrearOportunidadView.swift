//
//  CrearOportunidadView.swift
//  UACAMPocket
//
//  Created by Alfredo on 09/11/26.
//


import SwiftUI

// MARK: - CREAR OPORTUNIDAD
// Formulario docente de demostración.
// Las publicaciones se almacenan localmente mediante PocketDataService.

struct CrearOportunidadView: View {

    @ObservedObject var servicio: PocketDataService
    @Environment(\.dismiss) private var dismiss

    // MARK: - Datos del formulario

    @State private var titulo = ""
    @State private var descripcion = ""
    @State private var tipo: TipoOportunidad = .proyecto
    @State private var facultad = "Facultad de Ingeniería"
    @State private var carrera = ""
    @State private var perfilRequerido = ""
    @State private var modalidad: ModalidadOportunidad = .hibrida
    @State private var vacantes = 2
    @State private var fechaLimite = Calendar.current.date(
        byAdding: .day, value: 30, to: Date()
    ) ?? Date()

    // MARK: - Estado de la interfaz

    @State private var publicando = false
    @State private var mostrarConfirmacion = false
    @State private var mostrarExito = false
    @State private var mostrarResultado = false
    @State private var mensajeError = ""

    // MARK: - Validaciones

    private var tituloLimpio: String {
        titulo.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var descripcionLimpia: String {
        descripcion.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var facultadLimpia: String {
        facultad.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var carreraLimpia: String {
        carrera.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var perfilLimpio: String {
        perfilRequerido.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var fechaEsValida: Bool {
        Calendar.current.startOfDay(for: fechaLimite) >=
        Calendar.current.startOfDay(for: Date())
    }

    private var formularioValido: Bool {
        (6...100).contains(tituloLimpio.count) &&
        (30...2000).contains(descripcionLimpia.count) &&
        (3...100).contains(facultadLimpia.count) &&
        carreraLimpia.count <= 120 &&
        (10...500).contains(perfilLimpio.count) &&
        (1...50).contains(vacantes) &&
        fechaEsValida
    }

    // MARK: - Vista

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.section) {
                encabezado
                informacionBasica
                informacionAcademica
                condiciones
                fechaYAviso
                publicarBoton
            }
            .padding(.horizontal, AppTheme.Spacing.screenHorizontal)
            .padding(.top, AppTheme.Spacing.md)
            .padding(.bottom, AppTheme.Spacing.xxxl)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationTitle("Nueva convocatoria")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") { dismiss() }
            }
        }
        .confirmationDialog(
            "¿Publicar esta convocatoria?",
            isPresented: $mostrarConfirmacion,
            titleVisibility: .visible
        ) {
            Button("Publicar convocatoria") {
                guardarProyecto()
            }
            Button("Seguir editando", role: .cancel) {}
        } message: {
            Text("El proyecto aparecerá para los estudiantes de esta instalación. La publicación no es oficial ni acredita servicio social o prácticas.")
        }
        .alert(
            mostrarExito ? "Convocatoria publicada" : "No se pudo publicar",
            isPresented: $mostrarResultado
        ) {
            Button(mostrarExito ? "Volver al panel" : "Entendido") {
                if mostrarExito { dismiss() }
            }
        } message: {
            Text(
                mostrarExito
                ? "El proyecto se guardó correctamente y ya puede consultarse en Oportunidades."
                : mensajeError
            )
        }
    }

    // MARK: - Encabezado

    private var encabezado: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Label("PANEL DOCENTE · DEMOSTRACIÓN", systemImage: "plus.circle.fill")
                .font(AppTheme.Typography.captionBold)
                .foregroundStyle(.white.opacity(0.85))

            Text("Publicar una oportunidad")
                .font(AppTheme.Typography.title2)
                .foregroundStyle(.white)

            Text("Describe el proyecto y el perfil que necesitas. Los campos marcados como obligatorios deben completarse.")
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

    // MARK: - Información básica

    private var informacionBasica: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PocketSectionHeader(title: "Información del proyecto")

            PocketCard {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    campo(
                        "Título del proyecto *",
                        ayuda: "De 6 a 100 caracteres",
                        placeholder: "Ej. Desarrollo de aplicación móvil",
                        texto: $titulo
                    )

                    Divider()

                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text("Descripción *")
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.Colors.primaryText)

                        TextField(
                            "Explica el propósito, actividades y resultados esperados...",
                            text: $descripcion,
                            axis: .vertical
                        )
                        .lineLimit(5...10)
                        .textFieldStyle(.roundedBorder)

                        Text("De 30 a 2000 caracteres · \(descripcionLimpia.count)/2000")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text("Tipo de oportunidad *")
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.Colors.primaryText)

                        Picker("Tipo de oportunidad", selection: $tipo) {
                            ForEach(TipoOportunidad.allCases) { elemento in
                                Text(elemento.rawValue).tag(elemento)
                            }
                        }
                        .tint(AppTheme.Colors.blue)
                    }
                }
            }
        }
    }

    // MARK: - Información académica

    private var informacionAcademica: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PocketSectionHeader(title: "Perfil académico")

            PocketCard {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    campo(
                        "Facultad *",
                        ayuda: "De 3 a 100 caracteres",
                        placeholder: "Facultad responsable",
                        texto: $facultad
                    )

                    Divider()

                    campo(
                        "Carrera (opcional)",
                        ayuda: "Hasta 120 caracteres. Vacío = abierta a varias carreras.",
                        placeholder: "Ej. Ingeniería en Tecnología de Software",
                        texto: $carrera
                    )

                    Divider()

                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text("Perfil requerido *")
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.Colors.primaryText)

                        TextField(
                            "Describe conocimientos, habilidades y experiencia deseados...",
                            text: $perfilRequerido,
                            axis: .vertical
                        )
                        .lineLimit(3...8)
                        .textFieldStyle(.roundedBorder)

                        Text("De 10 a 500 caracteres · \(perfilLimpio.count)/500")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                    }
                }
            }
        }
    }

    // MARK: - Condiciones

    private var condiciones: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PocketSectionHeader(title: "Condiciones de la convocatoria")

            PocketCard {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Picker("Modalidad", selection: $modalidad) {
                        ForEach(ModalidadOportunidad.allCases) { elemento in
                            Text(elemento.rawValue).tag(elemento)
                        }
                    }
                    .tint(AppTheme.Colors.blue)

                    Divider()

                    Stepper(value: $vacantes, in: 1...50) {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                            Text("Vacantes disponibles")
                                .font(AppTheme.Typography.headline)
                                .foregroundStyle(AppTheme.Colors.primaryText)

                            Text("\(vacantes) \(vacantes == 1 ? "vacante" : "vacantes")")
                                .font(AppTheme.Typography.footnote)
                                .foregroundStyle(AppTheme.Colors.secondaryText)
                        }
                    }
                    .tint(AppTheme.Colors.blue)
                }
            }
        }
    }

    // MARK: - Fecha y advertencia

    private var fechaYAviso: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PocketSectionHeader(title: "Fecha límite y validación")

            PocketCard {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    DatePicker(
                        "Fecha límite de postulación *",
                        selection: $fechaLimite,
                        in: Calendar.current.startOfDay(for: Date())...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .tint(AppTheme.Colors.blue)
                    .environment(\.locale, Locale(identifier: "es_MX"))

                    Text("La convocatoria permanecerá abierta hasta el final del día seleccionado, salvo que el docente la cierre antes.")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)

                    Divider()

                    Label(
                        "La posible acreditación como servicio social o prácticas requiere validación institucional. Esta app no realiza ese trámite.",
                        systemImage: "info.circle"
                    )
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                }
            }
        }
    }

    // MARK: - Botón principal

    private var publicarBoton: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            if !formularioValido {
                Label(
                    "Completa el título, la descripción, la facultad y el perfil requerido dentro de las longitudes indicadas.",
                    systemImage: "info.circle"
                )
                .font(AppTheme.Typography.footnote)
                .foregroundStyle(AppTheme.Colors.secondaryText)
            }

            PocketPrimaryButton(
                title: "Publicar convocatoria",
                systemImage: "plus.circle.fill",
                isLoading: publicando,
                isDisabled: !formularioValido
            ) {
                mostrarConfirmacion = true
            }
        }
    }

    // MARK: - Campo de texto simple

    private func campo(
        _ tituloCampo: String,
        ayuda: String,
        placeholder: String,
        texto: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(tituloCampo)
                .font(AppTheme.Typography.headline)
                .foregroundStyle(AppTheme.Colors.primaryText)

            TextField(placeholder, text: texto)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled(false)

            Text(ayuda)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.secondaryText)
        }
    }

    // MARK: - Publicación y persistencia

    private func guardarProyecto() {
        guard formularioValido, !publicando else { return }
        publicando = true
        defer { publicando = false }

        let calendario = Calendar.current
        let finDelDia = calendario.date(
            bySettingHour: 23,
            minute: 59,
            second: 59,
            of: fechaLimite
        ) ?? fechaLimite

        let nuevaOportunidad = Oportunidad(
            titulo: tituloLimpio,
            descripcion: descripcionLimpia,
            tipo: tipo,
            facultad: facultadLimpia,
            carrera: carreraLimpia.isEmpty ? nil : carreraLimpia,
            perfilRequerido: perfilLimpio,
            modalidad: modalidad,
            vacantes: vacantes,
            estado: .abierta,
            docenteResponsable: servicio.docenteDemo.nombre,
            docenteId: servicio.docenteDemo.id,
            fechaPublicacion: Date(),
            fechaLimite: finDelDia,
            acreditacionValidada: false
        )

        do {
            try servicio.publicarOportunidad(
                nuevaOportunidad,
                docente: servicio.docenteDemo
            )
            mostrarExito = true
            mostrarResultado = true
        } catch {
            mostrarExito = false
            mensajeError = error.localizedDescription
            mostrarResultado = true
        }
    }
}

// MARK: - Vista previa

#Preview("Crear convocatoria - UACAM Pocket") {
    NavigationStack {
        CrearOportunidadView(servicio: PocketDataService())
    }
}
