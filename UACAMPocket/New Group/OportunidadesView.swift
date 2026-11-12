//
//  OportunidadesView.swift
//  UACAMPocket
//
//  Created by Alfredo on 09/11/26.
//


import SwiftUI

// MARK: - ARCHIVO 27: OPORTUNIDADES UACAM
// Features/Oportunidades/OportunidadesView.swift
//
// Diseño basado en la página 6 del anteproyecto UACAM Pocket.
// Mantiene una sola fuente de datos: PocketDataService.
// Los favoritos, convocatorias y postulaciones permanecen en su
// almacenamiento actual; esta vista NO crea ni borra registros.

struct OportunidadesView: View {

    @ObservedObject var servicio: PocketDataService

    @State private var textoBusqueda = ""
    @State private var tipoSeleccionado: TipoOportunidad? = nil
    @State private var soloDisponibles = false
    @State private var soloFavoritos = false
    @State private var mostrarError = false
    @State private var mensajeError = ""

    // MARK: - Resultados compartidos

    private var oportunidadesFiltradas: [Oportunidad] {
        let resultados = servicio.buscarOportunidades(
            texto: textoBusqueda,
            tipo: tipoSeleccionado,
            soloDisponibles: soloDisponibles
        )

        if soloFavoritos {
            return resultados.filter { servicio.esFavorita($0.id) }
        }

        return resultados
    }

    private var hayFiltrosActivos: Bool {
        !textoBusqueda.isEmpty || tipoSeleccionado != nil ||
        soloDisponibles || soloFavoritos
    }

    // MARK: - Pantalla

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: AppTheme.Spacing.section
                ) {
                    encabezado
                    campoBusqueda
                    categorias
                    filtrosRapidos

                    if let error = servicio.errorAlCargar {
                        avisoDeCarga(error)
                    }

                    resultados
                    avisoAcademico
                }
                .padding(
                    .horizontal,
                    AppTheme.Spacing.screenHorizontal
                )
                .padding(.top, AppTheme.Spacing.md)
                .padding(.bottom, AppTheme.Spacing.xxxl)
            }
            .background(
                AppTheme.Colors.background.ignoresSafeArea()
            )
            .navigationTitle("Oportunidades UACAM")
            .navigationBarTitleDisplayMode(.inline)
            .alert(
                "No se pudo guardar el cambio",
                isPresented: $mostrarError
            ) {
                Button("Entendido", role: .cancel) {}
            } message: {
                Text(mensajeError)
            }
        }
    }

    // MARK: - Encabezado de la maqueta

    private var encabezado: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.xxs
            ) {
                Text("Encuentra dónde comenzar")
                    .font(AppTheme.Typography.title2)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Servicio social, prácticas, proyectos e investigación.")
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }

            Spacer(minLength: 4)

            Image(systemName: "briefcase.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.blue)
                .frame(width: 54, height: 54)
                .background(
                    AppTheme.Colors.secondarySurface,
                    in: RoundedRectangle(
                        cornerRadius: AppTheme.Radius.large
                    )
                )
                .accessibilityHidden(true)
        }
    }

    // MARK: - Buscador

    private var campoBusqueda: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppTheme.Colors.secondaryText)
                .accessibilityHidden(true)

            TextField(
                "Buscar oportunidades...",
                text: $textoBusqueda
            )
            .font(AppTheme.Typography.body)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.search)
            .accessibilityLabel("Buscar oportunidades")

            if !textoBusqueda.isEmpty {
                Button {
                    textoBusqueda = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Limpiar búsqueda")
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .frame(minHeight: 52)
        .background(
            AppTheme.Colors.surface,
            in: RoundedRectangle(cornerRadius: AppTheme.Radius.large)
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        }
    }

    // MARK: - Categorías

    private var categorias: some View {
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {
            PocketSectionHeader(title: "Explorar por categoría")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.xs) {
                    chip(
                        "Todas",
                        icono: "square.grid.2x2",
                        seleccionado: tipoSeleccionado == nil
                    ) {
                        tipoSeleccionado = nil
                    }

                    ForEach(TipoOportunidad.allCases) { tipo in
                        chip(
                            tipo.rawValue,
                            icono: iconoParaTipo(tipo),
                            seleccionado: tipoSeleccionado == tipo
                        ) {
                            tipoSeleccionado = tipo
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: - Filtros adicionales

    private var filtrosRapidos: some View {
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {
            PocketSectionHeader(title: "Mostrar")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.xs) {
                    chip(
                        "Disponibles",
                        icono: "checkmark.circle",
                        seleccionado: soloDisponibles
                    ) {
                        soloDisponibles.toggle()
                    }

                    chip(
                        "Guardadas",
                        icono: "bookmark.fill",
                        seleccionado: soloFavoritos
                    ) {
                        soloFavoritos.toggle()
                    }

                    if hayFiltrosActivos {
                        Button {
                            limpiarFiltros()
                        } label: {
                            Label(
                                "Limpiar",
                                systemImage: "arrow.counterclockwise"
                            )
                            .font(AppTheme.Typography.captionBold)
                            .foregroundStyle(AppTheme.Colors.blue)
                            .padding(.horizontal, AppTheme.Spacing.sm)
                            .frame(minHeight: 42)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func chip(
        _ titulo: String,
        icono: String,
        seleccionado: Bool,
        accion: @escaping () -> Void
    ) -> some View {
        Button(action: accion) {
            HStack(spacing: AppTheme.Spacing.xxs) {
                Image(systemName: icono)
                    .font(.system(size: 12, weight: .semibold))

                Text(titulo)
                    .font(AppTheme.Typography.captionBold)
                    .lineLimit(1)
            }
            .foregroundStyle(
                seleccionado ? Color.white : AppTheme.Colors.primaryText
            )
            .padding(.horizontal, AppTheme.Spacing.md)
            .frame(minHeight: 42)
            .background(
                seleccionado ? AppTheme.Colors.blue : AppTheme.Colors.surface,
                in: Capsule()
            )
            .overlay {
                Capsule()
                    .stroke(
                        seleccionado ? AppTheme.Colors.blue : AppTheme.Colors.border,
                        lineWidth: 1
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(
            seleccionado ? [.isSelected] : []
        )
    }

    // MARK: - Convocatorias

    private var resultados: some View {
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {
            PocketSectionHeader(
                title: "Convocatorias",
                subtitle: oportunidadesFiltradas.count == 1
                    ? "1 oportunidad encontrada"
                    : "\(oportunidadesFiltradas.count) oportunidades encontradas"
            )

            if oportunidadesFiltradas.isEmpty {
                PocketEmptyState(
                    title: "No encontramos oportunidades",
                    message: hayFiltrosActivos
                        ? "Prueba con otra búsqueda o restablece los filtros."
                        : "Todavía no hay convocatorias para mostrar.",
                    systemImage: "tray",
                    actionTitle: hayFiltrosActivos ? "Limpiar filtros" : nil,
                    actionSystemImage: "arrow.counterclockwise",
                    action: hayFiltrosActivos ? limpiarFiltros : nil
                )
            } else {
                LazyVStack(spacing: AppTheme.Spacing.md) {
                    ForEach(oportunidadesFiltradas) { oportunidad in
                        tarjetaOportunidad(oportunidad)
                    }
                }
            }
        }
    }

    // MARK: - Tarjeta (guardar + ver detalle)

    private func tarjetaOportunidad(
        _ oportunidad: Oportunidad
    ) -> some View {
        PocketCard {
            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.sm
            ) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: iconoParaTipo(oportunidad.tipo))
                        .font(.title3)
                        .foregroundStyle(colorParaTipo(oportunidad.tipo))
                        .frame(width: 44, height: 44)
                        .background(
                            colorParaTipo(oportunidad.tipo).opacity(0.11),
                            in: RoundedRectangle(
                                cornerRadius: AppTheme.Radius.medium
                            )
                        )
                        .accessibilityHidden(true)

                    Text(oportunidad.tipo.rawValue)
                        .font(AppTheme.Typography.captionBold)
                        .foregroundStyle(colorParaTipo(oportunidad.tipo))
                        .lineLimit(2)

                    Spacer(minLength: 4)

                    // Botón independiente: no está anidado dentro de
                    // NavigationLink y por eso funciona correctamente.
                    Button {
                        alternarFavorito(oportunidad)
                    } label: {
                        Image(
                            systemName: servicio.esFavorita(oportunidad.id)
                                ? "bookmark.fill" : "bookmark"
                        )
                        .font(.system(size: 20))
                        .foregroundStyle(AppTheme.Colors.blue)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        servicio.esFavorita(oportunidad.id)
                            ? "Quitar de oportunidades guardadas"
                            : "Guardar oportunidad"
                    )
                }

                NavigationLink {
                    // La postulación y su seguimiento continúan
                    // en la vista que ya fue probada.
                    OportunidadDetalleView(
                        oportunidad: oportunidad,
                        servicio: servicio
                    )
                } label: {
                    VStack(
                        alignment: .leading,
                        spacing: AppTheme.Spacing.sm
                    ) {
                        Text(oportunidad.titulo)
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.Colors.primaryText)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(oportunidad.descripcion)
                            .font(AppTheme.Typography.footnote)
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        Label(
                            oportunidad.facultad,
                            systemImage: "building.2"
                        )
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                        .lineLimit(2)

                        HStack(spacing: AppTheme.Spacing.md) {
                            Label(
                                oportunidad.vacantesTexto,
                                systemImage: "person.2"
                            )

                            Label(
                                oportunidad.modalidad.rawValue,
                                systemImage: "location"
                            )
                        }
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)

                        Divider()

                        HStack(spacing: AppTheme.Spacing.xs) {
                            if let miPostulacion = servicio.postulacion(
                                estudianteID: servicio.estudianteDemo.id,
                                oportunidadID: oportunidad.id
                            ) {
                                PocketStatusBadge(
                                    estadoPostulacion: miPostulacion.estado
                                )
                            } else {
                                PocketStatusBadge(
                                    oportunidad: oportunidad
                                )
                            }

                            Spacer(minLength: 4)

                            Text(
                                servicio.postulacion(
                                    estudianteID: servicio.estudianteDemo.id,
                                    oportunidadID: oportunidad.id
                                ) == nil
                                    ? "Ver oportunidad"
                                    : "Ver seguimiento"
                            )
                            .font(AppTheme.Typography.captionBold)
                            .foregroundStyle(AppTheme.Colors.blue)

                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppTheme.Colors.blue)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Iconografía por categoría
    // Usamos rawValue para respetar las categorías existentes
    // sin añadir casos nuevos al enum TipoOportunidad.

    private func iconoParaTipo(
        _ tipo: TipoOportunidad
    ) -> String {
        let nombre = tipo.rawValue.lowercased()

        if nombre.contains("servicio") {
            return "graduationcap.fill"
        }
        if nombre.contains("práctic") || nombre.contains("practic") {
            return "person.2.fill"
        }
        if nombre.contains("investig") {
            return "chart.bar.xaxis"
        }
        if nombre.contains("tecnolog") {
            return "cpu"
        }
        return "briefcase.fill"
    }

    private func colorParaTipo(
        _ tipo: TipoOportunidad
    ) -> Color {
        let nombre = tipo.rawValue.lowercased()

        if nombre.contains("servicio") {
            return AppTheme.Colors.warning
        }
        if nombre.contains("práctic") || nombre.contains("practic") {
            return AppTheme.Colors.blue
        }
        if nombre.contains("investig") {
            return .purple
        }
        if nombre.contains("tecnolog") {
            return AppTheme.Colors.success
        }
        return AppTheme.Colors.blue
    }

    // MARK: - Acciones persistentes

    private func alternarFavorito(
        _ oportunidad: Oportunidad
    ) {
        do {
            _ = try servicio.alternarFavorito(
                oportunidadID: oportunidad.id,
                estudiante: servicio.estudianteDemo
            )
        } catch {
            mensajeError = error.localizedDescription
            mostrarError = true
        }
    }

    private func limpiarFiltros() {
        textoBusqueda = ""
        tipoSeleccionado = nil
        soloDisponibles = false
        soloFavoritos = false
    }

    private func avisoDeCarga(_ mensaje: String) -> some View {
        Label(
            mensaje,
            systemImage: "exclamationmark.triangle"
        )
        .font(AppTheme.Typography.footnote)
        .foregroundStyle(AppTheme.Colors.error)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var avisoAcademico: some View {
        Label(
            "Prototipo académico. Las convocatorias y postulaciones son datos locales de demostración; su acreditación requiere validación de la UACAM.",
            systemImage: "info.circle"
        )
        .font(AppTheme.Typography.small)
        .foregroundStyle(AppTheme.Colors.secondaryText)
    }
}

// MARK: - Vista previa

#Preview("Oportunidades - UACAM Pocket") {
    OportunidadesView(servicio: PocketDataService())
}
