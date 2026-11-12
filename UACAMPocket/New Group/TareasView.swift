//
//  TareasView.swift
//  UACAMPocket
//
//  Created by Alfredo on 10/11/26.
//


import SwiftUI

// MARK: - TAREAS DEL ESTUDIANTE
// Utiliza el servicio compartido PocketTaskService.
// No crea otro almacen ni modifica las claves de UserDefaults.

struct TareasView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var servicioTareas: PocketTaskService

    @State private var filtro: FiltroTareas = .pendientes
    @State private var editor: EditorTarea?
    @State private var idPorEliminar: UUID?
    @State private var mostrarConfirmacionEliminar = false
    @State private var mostrarError = false
    @State private var mensajeError = ""

    private enum FiltroTareas: String, CaseIterable, Identifiable {
        case pendientes = "Pendientes"
        case todas = "Todas"
        case completadas = "Hechas"
        var id: String { rawValue }
    }

    private enum EditorTarea: Identifiable {
        case nueva
        case editar(PocketTask)

        var id: String {
            switch self {
            case .nueva:
                return "nueva"
            case .editar(let tarea):
                return tarea.id.uuidString
            }
        }
    }

    private var tareasVisibles: [PocketTask] {
        let seleccionadas = servicioTareas.tareas.filter { tarea in
            switch filtro {
            case .pendientes: return !tarea.completada
            case .todas: return true
            case .completadas: return tarea.completada
            }
        }

        return seleccionadas.sorted { izquierda, derecha in
            if izquierda.fechaEntrega != derecha.fechaEntrega {
                return izquierda.fechaEntrega < derecha.fechaEntrega
            }
            return izquierda.titulo.localizedStandardCompare(
                derecha.titulo
            ) == .orderedAscending
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: AppTheme.Spacing.section
                ) {
                    encabezado
                    resumen
                    seccionLista
                    avisoPrototipo
                }
                .padding(.horizontal, AppTheme.Spacing.screenHorizontal)
                .padding(.top, AppTheme.Spacing.md)
                .padding(.bottom, AppTheme.Spacing.xxxl)
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())
            .navigationTitle("Mis tareas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cerrar") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editor = .nueva
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(!servicioTareas.puedeModificar)
                    .accessibilityLabel("Crear tarea")
                }
            }
            .sheet(item: $editor) { destino in
                switch destino {
                case .nueva:
                    FormularioTareaView(servicioTareas: servicioTareas)
                case .editar(let tarea):
                    FormularioTareaView(
                        servicioTareas: servicioTareas,
                        tarea: tarea
                    )
                }
            }
            .confirmationDialog(
                "¿Eliminar esta tarea?",
                isPresented: $mostrarConfirmacionEliminar,
                titleVisibility: .visible
            ) {
                Button("Eliminar tarea", role: .destructive) {
                    eliminarSeleccionada()
                }
                Button("Cancelar", role: .cancel) {
                    idPorEliminar = nil
                }
            } message: {
                Text("La tarea se quitará del almacenamiento local.")
            }
            .alert("No se pudo actualizar la tarea", isPresented: $mostrarError) {
                Button("Entendido", role: .cancel) {}
            } message: {
                Text(mensajeError)
            }
        }
    }

    // MARK: - Encabezado

    private var encabezado: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Label("ORGANIZACIÓN ACADÉMICA", systemImage: "checklist")
                .font(AppTheme.Typography.captionBold)
                .foregroundStyle(.white.opacity(0.85))

            Text("Organiza tus pendientes")
                .font(AppTheme.Typography.title2)
                .foregroundStyle(.white)

            Text("Agrega entregas, marca avances y consulta tus fechas importantes.")
                .font(AppTheme.Typography.footnote)
                .foregroundStyle(.white.opacity(0.85))

            PocketPrimaryButton(
                title: "Agregar tarea",
                systemImage: "plus.circle.fill",
                isDisabled: !servicioTareas.puedeModificar
            ) {
                editor = .nueva
            }
        }
        .padding(AppTheme.Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            AppTheme.Gradients.header,
            in: RoundedRectangle(cornerRadius: AppTheme.Radius.extraLarge)
        )
    }

    // MARK: - Contadores

    private var resumen: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            tarjetaResumen(
                titulo: "Pendientes",
                cantidad: servicioTareas.pendientes,
                icono: "clock.fill",
                color: AppTheme.Colors.warning
            )
            tarjetaResumen(
                titulo: "Terminadas",
                cantidad: servicioTareas.completadas,
                icono: "checkmark.circle.fill",
                color: AppTheme.Colors.success
            )
        }
    }

    private func tarjetaResumen(
        titulo: String,
        cantidad: Int,
        icono: String,
        color: Color
    ) -> some View {
        PocketCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Image(systemName: icono)
                    .font(.title3)
                    .foregroundStyle(color)
                Text("\(cantidad)")
                    .font(AppTheme.Typography.title2)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                Text(titulo)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Lista y filtros

    private var seccionLista: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            PocketSectionHeader(
                title: "Mis actividades",
                subtitle: "\(tareasVisibles.count) en esta vista"
            )

            Picker("Filtrar tareas", selection: $filtro) {
                ForEach(FiltroTareas.allCases) { opcion in
                    Text(opcion.rawValue).tag(opcion)
                }
            }
            .pickerStyle(.segmented)

            if let error = servicioTareas.mensajeError {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.error)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if tareasVisibles.isEmpty {
                PocketEmptyState(
                    title: filtro == .completadas
                        ? "Todavía no hay tareas terminadas"
                        : "No tienes tareas en esta sección",
                    message: filtro == .completadas
                        ? "Cuando completes una actividad aparecerá aquí."
                        : "Agrega una tarea o cambia el filtro para consultar otras actividades.",
                    systemImage: "checkmark.circle",
                    actionTitle: servicioTareas.puedeModificar ? "Agregar tarea" : nil,
                    actionSystemImage: "plus",
                    action: {
                        if servicioTareas.puedeModificar {
                            editor = .nueva
                        }
                    }
                )
            } else {
                LazyVStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(tareasVisibles) { tarea in
                        tarjetaTarea(tarea)
                    }
                }
            }
        }
    }

    // MARK: - Tarjeta individual

    private func tarjetaTarea(_ tarea: PocketTask) -> some View {
        let vencida = !tarea.completada &&
            Calendar.current.startOfDay(for: tarea.fechaEntrega) <
            Calendar.current.startOfDay(for: Date())

        return PocketCard {
            HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                Button {
                    do {
                        _ = try servicioTareas.alternarCompletada(id: tarea.id)
                    } catch {
                        presentarError(error)
                    }
                } label: {
                    Image(systemName: tarea.completada ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 25))
                        .foregroundStyle(
                            tarea.completada
                                ? AppTheme.Colors.success
                                : AppTheme.Colors.blue
                        )
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(!servicioTareas.puedeModificar)
                .accessibilityLabel(
                    tarea.completada ? "Marcar como pendiente" : "Marcar como completada"
                )

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(tarea.titulo)
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.Colors.primaryText)
                        .strikethrough(tarea.completada)

                    Text(tarea.materia)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)

                    Label {
                        Text(
                            tarea.fechaEntrega,
                            format: .dateTime.day().month(.abbreviated).year()
                        )
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(
                        vencida ? AppTheme.Colors.error : AppTheme.Colors.secondaryText
                    )

                    if !tarea.notas.isEmpty {
                        Text(tarea.notas)
                            .font(AppTheme.Typography.footnote)
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    HStack(spacing: AppTheme.Spacing.xs) {
                        Circle()
                            .fill(tarea.prioridad.color)
                            .frame(width: 7, height: 7)
                        Text("Prioridad \(tarea.prioridad.rawValue.lowercased())")
                            .font(AppTheme.Typography.small)
                            .foregroundStyle(AppTheme.Colors.secondaryText)

                        if vencida {
                            Text("· Vencida")
                                .font(AppTheme.Typography.small)
                                .foregroundStyle(AppTheme.Colors.error)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 0) {
                    Button {
                        editor = .editar(tarea)
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 16))
                            .foregroundStyle(AppTheme.Colors.blue)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .disabled(!servicioTareas.puedeModificar)
                    .accessibilityLabel("Editar \(tarea.titulo)")

                    Button(role: .destructive) {
                        idPorEliminar = tarea.id
                        mostrarConfirmacionEliminar = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .disabled(!servicioTareas.puedeModificar)
                    .accessibilityLabel("Eliminar \(tarea.titulo)")
                }
            }
        }
    }

    // MARK: - Acciones con errores visibles

    private func eliminarSeleccionada() {
        defer { idPorEliminar = nil }
        guard let id = idPorEliminar else { return }

        do {
            try servicioTareas.eliminar(id: id)
        } catch {
            presentarError(error)
        }
    }

    private func presentarError(_ error: Error) {
        mensajeError = error.localizedDescription
        mostrarError = true
    }

    private var avisoPrototipo: some View {
        Label(
            "Tareas personales guardadas en este dispositivo. No se envían a profesores ni a sistemas oficiales de la UACAM.",
            systemImage: "info.circle"
        )
        .font(AppTheme.Typography.small)
        .foregroundStyle(AppTheme.Colors.secondaryText)
    }
}

// MARK: - FORMULARIO PARA CREAR O EDITAR

private struct FormularioTareaView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var servicioTareas: PocketTaskService

    let tareaOriginal: PocketTask?

    @State private var titulo: String
    @State private var materia: String
    @State private var notas: String
    @State private var fechaEntrega: Date
    @State private var prioridad: PocketTaskPriority
    @State private var mostrarError = false
    @State private var mensajeError = ""

    init(servicioTareas: PocketTaskService, tarea: PocketTask? = nil) {
        self.servicioTareas = servicioTareas
        self.tareaOriginal = tarea

        _titulo = State(initialValue: tarea?.titulo ?? "")
        _materia = State(initialValue: tarea?.materia ?? "")
        _notas = State(initialValue: tarea?.notas ?? "")
        _fechaEntrega = State(initialValue: tarea?.fechaEntrega ??
            Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date())
        _prioridad = State(initialValue: tarea?.prioridad ?? .media)
    }

    private var tituloLimpio: String {
        titulo.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var materiaLimpia: String {
        materia.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var notasLimpias: String {
        notas.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var formularioValido: Bool {
        (3...120).contains(tituloLimpio.count) &&
        (2...100).contains(materiaLimpia.count) &&
        notasLimpias.count <= 500 &&
        servicioTareas.puedeModificar
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Información de la tarea") {
                    TextField("Título (3 a 120 caracteres)", text: $titulo)
                        .textInputAutocapitalization(.sentences)

                    TextField("Materia o asignatura", text: $materia)
                        .textInputAutocapitalization(.words)

                    TextField("Notas opcionales", text: $notas, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Entrega y prioridad") {
                    DatePicker(
                        "Fecha de entrega",
                        selection: $fechaEntrega,
                        displayedComponents: .date
                    )

                    Picker("Prioridad", selection: $prioridad) {
                        ForEach(PocketTaskPriority.allCases) { opcion in
                            Text(opcion.rawValue).tag(opcion)
                        }
                    }
                }

                Section {
                    Text("Se guarda solo en este dispositivo. La fecha puede modificarse más adelante.")
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }
            }
            .navigationTitle(tareaOriginal == nil ? "Nueva tarea" : "Editar tarea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        guardar()
                    }
                    .disabled(!formularioValido)
                }
            }
            .alert("No se pudo guardar la tarea", isPresented: $mostrarError) {
                Button("Entendido", role: .cancel) {}
            } message: {
                Text(mensajeError)
            }
        }
        .tint(AppTheme.Colors.blue)
        .environment(\.locale, Locale(identifier: "es_MX"))
    }

    private func guardar() {
        guard formularioValido else { return }

        do {
            if let tarea = tareaOriginal {
                try servicioTareas.actualizar(
                    id: tarea.id,
                    titulo: tituloLimpio,
                    materia: materiaLimpia,
                    notas: notasLimpias,
                    fechaEntrega: fechaEntrega,
                    prioridad: prioridad
                )
            } else {
                _ = try servicioTareas.agregar(
                    titulo: tituloLimpio,
                    materia: materiaLimpia,
                    notas: notasLimpias,
                    fechaEntrega: fechaEntrega,
                    prioridad: prioridad
                )
            }
            dismiss()
        } catch {
            mensajeError = error.localizedDescription
            mostrarError = true
        }
    }
}

// MARK: - COLORES DE PRIORIDAD

private extension PocketTaskPriority {
    var color: Color {
        switch self {
        case .alta: return AppTheme.Colors.error
        case .media: return AppTheme.Colors.warning
        case .baja: return AppTheme.Colors.success
        }
    }
}

// MARK: - VISTA PREVIA

#Preview("Tareas - UACAM Pocket") {
    TareasView(servicioTareas: PocketTaskService())
}
