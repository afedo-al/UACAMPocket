//
//  CalendarioView.swift
//  UACAMPocket
//
//  Created by Alfredo on 09/11/26.
//


import SwiftUI

// MARK: - CLASES DE DEMOSTRACIÓN
// Se mantienen dentro de CalendarioView porque todavía no existe
// una conexión oficial a los horarios de la UACAM.

private struct ClaseCalendarioDemo: Identifiable {
    let id: String
    let diaSemana: Int       // Calendar: domingo = 1, lunes = 2...
    let materia: String
    let horaInicio: String
    let horaFin: String
    let aula: String
    let icono: String
}

// MARK: - CALENDARIO DEL ESTUDIANTE
// Las clases son ejemplos que se repiten semanalmente.
// Las entregas se consultan en el mismo PocketTaskService
// que utiliza Features/Tareas/TareasView.swift.

struct CalendarioView: View {

    @ObservedObject var servicioTareas: PocketTaskService

    @State private var fechaSeleccionada = Date()
    @State private var mostrarSelectorFecha = false
    @State private var mostrarError = false
    @State private var mensajeError = ""

    // ISO 8601: semana de lunes a domingo.
    private var calendario: Calendar {
        var resultado = Calendar(identifier: .iso8601)
        resultado.locale = Locale(identifier: "es_MX")
        resultado.timeZone = .current
        resultado.firstWeekday = 2
        return resultado
    }

    private let nombresDias = [
        "Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"
    ]

    private let clases: [ClaseCalendarioDemo] = [
        ClaseCalendarioDemo(
            id: "lunes-programacion", diaSemana: 2,
            materia: "Programación Web", horaInicio: "08:00",
            horaFin: "10:00", aula: "Aula 301",
            icono: "laptopcomputer"
        ),
        ClaseCalendarioDemo(
            id: "lunes-inteligentes", diaSemana: 2,
            materia: "Sistemas Inteligentes", horaInicio: "11:00",
            horaFin: "13:00", aula: "Aula 205",
            icono: "brain.head.profile"
        ),
        ClaseCalendarioDemo(
            id: "martes-programacion", diaSemana: 3,
            materia: "Programación Web", horaInicio: "08:00",
            horaFin: "10:00", aula: "Aula 301",
            icono: "laptopcomputer"
        ),
        ClaseCalendarioDemo(
            id: "martes-inteligentes", diaSemana: 3,
            materia: "Sistemas Inteligentes", horaInicio: "11:00",
            horaFin: "13:00", aula: "Aula 205",
            icono: "brain.head.profile"
        ),
        ClaseCalendarioDemo(
            id: "miercoles-bases", diaSemana: 4,
            materia: "Bases de Datos", horaInicio: "09:00",
            horaFin: "11:00", aula: "Aula 204",
            icono: "externaldrive"
        ),
        ClaseCalendarioDemo(
            id: "jueves-programacion", diaSemana: 5,
            materia: "Programación Web", horaInicio: "08:00",
            horaFin: "10:00", aula: "Aula 301",
            icono: "laptopcomputer"
        ),
        ClaseCalendarioDemo(
            id: "viernes-ingenieria", diaSemana: 6,
            materia: "Ingeniería de Software", horaInicio: "09:00",
            horaFin: "11:00", aula: "Aula 208",
            icono: "desktopcomputer"
        )
    ]

    // MARK: - FECHAS

    private var inicioSemana: Date {
        calendario.dateInterval(
            of: .weekOfYear, for: fechaSeleccionada
        )?.start ?? calendario.startOfDay(for: fechaSeleccionada)
    }

    private var diasSemana: [Date] {
        (0..<7).compactMap { indice in
            calendario.date(
                byAdding: .day, value: indice, to: inicioSemana
            )
        }
    }

    private var finSemana: Date {
        calendario.date(
            byAdding: .day, value: 6, to: inicioSemana
        ) ?? inicioSemana
    }

    private var clasesSeleccionadas: [ClaseCalendarioDemo] {
        let dia = calendario.component(.weekday, from: fechaSeleccionada)
        return clases
            .filter { $0.diaSemana == dia }
            .sorted { $0.horaInicio < $1.horaInicio }
    }

    // Al observar PocketTaskService, estas consultas se actualizan
    // cuando el estudiante crea, edita, completa o elimina tareas.
    private var tareasSeleccionadas: [PocketTask] {
        servicioTareas.tareas(
            para: fechaSeleccionada,
            incluirCompletadas: true
        )
    }

    private var proximasEntregas: [PocketTask] {
        Array(servicioTareas.proximasEntregas.prefix(5))
    }

    // MARK: - PANTALLA

    var body: some View {
        NavigationStack {
            ScrollViewReader { lector in
                ScrollView {
                    VStack(
                        alignment: .leading,
                        spacing: AppTheme.Spacing.section
                    ) {
                        encabezado

                        calendarioSemanal
                            .id("semana")

                        seccionClases
                        seccionTareasDelDia
                        seccionProximasEntregas { fecha in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                fechaSeleccionada = fecha
                                lector.scrollTo("semana", anchor: .top)
                            }
                        }
                        avisoDemostracion
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
            }
            .navigationTitle("Calendario")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $mostrarSelectorFecha) {
                NavigationStack {
                    VStack {
                        DatePicker(
                            "Seleccionar fecha",
                            selection: $fechaSeleccionada,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .environment(
                            \.locale, Locale(identifier: "es_MX")
                        )
                        .padding()

                        Spacer(minLength: 0)
                    }
                    .navigationTitle("Seleccionar día")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Listo") {
                                mostrarSelectorFecha = false
                            }
                        }
                    }
                }
                .presentationDetents([.large])
            }
            .alert(
                "No se pudo actualizar la tarea",
                isPresented: $mostrarError
            ) {
                Button("Entendido", role: .cancel) {}
            } message: {
                Text(mensajeError)
            }
        }
    }

    // MARK: - ENCABEZADO

    private var encabezado: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.xxs
            ) {
                Text("Mi calendario")
                    .font(AppTheme.Typography.title2)
                    .foregroundStyle(AppTheme.Colors.primaryText)

                Text("Clases de ejemplo y tus entregas guardadas.")
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }

            Spacer(minLength: 8)

            Button {
                mostrarSelectorFecha = true
            } label: {
                Image(systemName: "calendar")
                    .font(.title3)
                    .foregroundStyle(AppTheme.Colors.blue)
                    .frame(width: 48, height: 48)
                    .background(
                        AppTheme.Colors.secondarySurface,
                        in: RoundedRectangle(
                            cornerRadius: AppTheme.Radius.medium
                        )
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Seleccionar otra fecha")
        }
    }

    // MARK: - SEMANA INTERACTIVA

    private var calendarioSemanal: some View {
        PocketCard {
            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.lg
            ) {
                HStack(spacing: AppTheme.Spacing.xs) {
                    VStack(
                        alignment: .leading,
                        spacing: AppTheme.Spacing.xxs
                    ) {
                        Text("Semana académica")
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.Colors.primaryText)

                        Text(
                            "\(formatear(inicioSemana, formato: "d MMM")) – \(formatear(finSemana, formato: "d MMM yyyy"))"
                        )
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                    }

                    Spacer(minLength: 2)

                    botonSemana(
                        "chevron.left", descripcion: "Semana anterior"
                    ) {
                        moverSemana(-1)
                    }

                    botonSemana(
                        "chevron.right", descripcion: "Semana siguiente"
                    ) {
                        moverSemana(1)
                    }
                }

                HStack(spacing: AppTheme.Spacing.xxs) {
                    ForEach(diasSemana, id: \.self) { fecha in
                        botonDia(fecha)
                    }
                }

                HStack(spacing: AppTheme.Spacing.md) {
                    Label("Clases", systemImage: "circle.fill")
                        .foregroundStyle(AppTheme.Colors.blue)
                    Label("Entregas", systemImage: "circle.fill")
                        .foregroundStyle(AppTheme.Colors.warning)
                }
                .font(AppTheme.Typography.small)
                .accessibilityElement(children: .combine)

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        fechaSeleccionada = Date()
                    }
                } label: {
                    Label("Volver a hoy", systemImage: "arrow.uturn.backward")
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(AppTheme.Colors.blue)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func botonSemana(
        _ icono: String,
        descripcion: String,
        accion: @escaping () -> Void
    ) -> some View {
        Button(action: accion) {
            Image(systemName: icono)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.blue)
                .frame(width: 40, height: 44)
                .background(
                    AppTheme.Colors.secondarySurface,
                    in: RoundedRectangle(
                        cornerRadius: AppTheme.Radius.small
                    )
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(descripcion)
    }

    private func botonDia(_ fecha: Date) -> some View {
        let seleccionado = calendario.isDate(
            fecha, inSameDayAs: fechaSeleccionada
        )
        let esHoy = calendario.isDateInToday(fecha)
        let dia = calendario.component(.weekday, from: fecha)
        let numero = calendario.component(.day, from: fecha)
        let hayClases = clases.contains { $0.diaSemana == dia }
        let hayTareas = !servicioTareas.tareas(para: fecha).isEmpty

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                fechaSeleccionada = fecha
            }
        } label: {
            VStack(spacing: AppTheme.Spacing.xs) {
                Text(nombresDias[dia - 1])
                    .font(AppTheme.Typography.small)

                Text("\(numero)")
                    .font(AppTheme.Typography.headline)

                HStack(spacing: 3) {
                    Circle()
                        .fill(
                            seleccionado
                                ? Color.white
                                : AppTheme.Colors.blue
                        )
                        .frame(width: 5, height: 5)
                        .opacity(hayClases ? 1 : 0)

                    Circle()
                        .fill(
                            seleccionado
                                ? Color.white
                                : AppTheme.Colors.warning
                        )
                        .frame(width: 5, height: 5)
                        .opacity(hayTareas ? 1 : 0)
                }
            }
            .foregroundStyle(
                seleccionado ? Color.white : AppTheme.Colors.primaryText
            )
            .frame(maxWidth: .infinity, minHeight: 76)
            .background(
                seleccionado
                    ? AppTheme.Colors.blue
                    : AppTheme.Colors.background,
                in: RoundedRectangle(
                    cornerRadius: AppTheme.Radius.medium
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: AppTheme.Radius.medium
                )
                .stroke(
                    esHoy && !seleccionado
                        ? AppTheme.Colors.lightBlue
                        : Color.clear,
                    lineWidth: 1.5
                )
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            formatear(fecha, formato: "EEEE d 'de' MMMM")
        )
        .accessibilityHint(
            hayTareas
                ? "Mostrar clases y tareas de este día"
                : "Mostrar clases de este día"
        )
    }

    // MARK: - CLASES (EJEMPLOS)

    private var seccionClases: some View {
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {
            PocketSectionHeader(
                title: "Clases del día",
                subtitle: formatear(
                    fechaSeleccionada, formato: "EEEE d 'de' MMMM"
                )
            )

            if clasesSeleccionadas.isEmpty {
                PocketEmptyState(
                    title: "Sin clases programadas",
                    message: "No hay clases de ejemplo para este día.",
                    systemImage: "calendar"
                )
            } else {
                ForEach(clasesSeleccionadas) { clase in
                    PocketCard {
                        HStack(
                            alignment: .top,
                            spacing: AppTheme.Spacing.md
                        ) {
                            Image(systemName: clase.icono)
                                .font(.title3)
                                .foregroundStyle(AppTheme.Colors.blue)
                                .frame(width: 48, height: 48)
                                .background(
                                    AppTheme.Colors.blue.opacity(0.08),
                                    in: RoundedRectangle(
                                        cornerRadius: AppTheme.Radius.medium
                                    )
                                )

                            VStack(
                                alignment: .leading,
                                spacing: AppTheme.Spacing.xs
                            ) {
                                Text(clase.materia)
                                    .font(AppTheme.Typography.headline)
                                    .foregroundStyle(
                                        AppTheme.Colors.primaryText
                                    )

                                Label(
                                    "\(clase.horaInicio) – \(clase.horaFin)",
                                    systemImage: "clock"
                                )
                                Label(clase.aula, systemImage: "mappin")
                            }
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(
                                AppTheme.Colors.secondaryText
                            )

                            Spacer(minLength: 0)
                        }
                    }
                }
            }
        }
    }

    // MARK: - ENTREGAS REALES DEL DÍA

    private var seccionTareasDelDia: some View {
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {
            PocketSectionHeader(
                title: "Entregas del día",
                subtitle: "\(tareasSeleccionadas.count) actividades guardadas"
            )

            if tareasSeleccionadas.isEmpty {
                PocketCard(showShadow: false) {
                    Label(
                        "No tienes tareas registradas para este día.",
                        systemImage: "checkmark.circle"
                    )
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                }
            } else {
                ForEach(tareasSeleccionadas) { tarea in
                    tarjetaTarea(tarea)
                }
            }
        }
    }

    private func tarjetaTarea(_ tarea: PocketTask) -> some View {
        PocketCard {
            HStack(
                alignment: .top,
                spacing: AppTheme.Spacing.sm
            ) {
                Button {
                    cambiarEstado(tarea)
                } label: {
                    Image(
                        systemName: tarea.completada
                            ? "checkmark.circle.fill"
                            : "circle"
                    )
                    .font(.title2)
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
                    tarea.completada
                        ? "Marcar \(tarea.titulo) como pendiente"
                        : "Completar \(tarea.titulo)"
                )

                VStack(
                    alignment: .leading,
                    spacing: AppTheme.Spacing.xs
                ) {
                    Text(tarea.titulo)
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.Colors.primaryText)
                        .strikethrough(tarea.completada)

                    Text(tarea.materia)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)

                    if !tarea.notas.isEmpty {
                        Text(tarea.notas)
                            .font(AppTheme.Typography.footnote)
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    HStack(spacing: AppTheme.Spacing.xs) {
                        Circle()
                            .fill(colorPrioridad(tarea.prioridad))
                            .frame(width: 7, height: 7)

                        Text("Prioridad \(tarea.prioridad.rawValue.lowercased())")
                            .font(AppTheme.Typography.small)
                            .foregroundStyle(AppTheme.Colors.secondaryText)

                        if tarea.completada {
                            Text("· Completada")
                                .font(AppTheme.Typography.small)
                                .foregroundStyle(AppTheme.Colors.success)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: - PRÓXIMAS ENTREGAS DESDE EL SERVICIO

    private func seccionProximasEntregas(
        seleccionar: @escaping (Date) -> Void
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {
            PocketSectionHeader(
                title: "Próximas entregas",
                subtitle: "Tareas pendientes desde hoy"
            )

            if proximasEntregas.isEmpty {
                PocketEmptyState(
                    title: "Sin entregas próximas",
                    message: "Agrega tareas desde Inicio → Tareas para verlas aquí.",
                    systemImage: "checkmark.seal"
                )
            } else {
                PocketCard {
                    VStack(spacing: AppTheme.Spacing.md) {
                        ForEach(proximasEntregas) { tarea in
                            Button {
                                seleccionar(tarea.fechaEntrega)
                            } label: {
                                HStack(spacing: AppTheme.Spacing.sm) {
                                    Image(systemName: "doc.text")
                                        .foregroundStyle(AppTheme.Colors.blue)

                                    VStack(
                                        alignment: .leading,
                                        spacing: AppTheme.Spacing.xxs
                                    ) {
                                        Text(tarea.titulo)
                                            .font(AppTheme.Typography.bodyMedium)
                                            .foregroundStyle(AppTheme.Colors.primaryText)
                                        Text(tarea.materia)
                                            .font(AppTheme.Typography.caption)
                                            .foregroundStyle(AppTheme.Colors.secondaryText)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                    Text(
                                        formatear(
                                            tarea.fechaEntrega,
                                            formato: "d MMM"
                                        )
                                    )
                                    .font(AppTheme.Typography.captionBold)
                                    .foregroundStyle(AppTheme.Colors.warning)

                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.Colors.blue)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint("Ir al día de entrega")

                            if tarea.id != proximasEntregas.last?.id {
                                Divider()
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - INFORMACIÓN DE LA DEMOSTRACIÓN

    private var avisoDemostracion: some View {
        Label(
            "Las clases son ejemplos semanales. Las tareas y entregas provienen de Mis tareas y se guardan únicamente en este dispositivo; no son datos oficiales de la UACAM.",
            systemImage: "info.circle"
        )
        .font(AppTheme.Typography.small)
        .foregroundStyle(AppTheme.Colors.secondaryText)
    }

    // MARK: - ACCIONES Y AYUDAS

    private func moverSemana(_ cantidad: Int) {
        guard let nuevaFecha = calendario.date(
            byAdding: .weekOfYear,
            value: cantidad,
            to: fechaSeleccionada
        ) else { return }

        withAnimation(.easeInOut(duration: 0.2)) {
            fechaSeleccionada = nuevaFecha
        }
    }

    private func cambiarEstado(_ tarea: PocketTask) {
        do {
            _ = try servicioTareas.alternarCompletada(id: tarea.id)
        } catch {
            mensajeError = error.localizedDescription
            mostrarError = true
        }
    }

    private func colorPrioridad(_ prioridad: PocketTaskPriority) -> Color {
        switch prioridad {
        case .alta: return AppTheme.Colors.error
        case .media: return AppTheme.Colors.warning
        case .baja: return AppTheme.Colors.success
        }
    }

    private func formatear(_ fecha: Date, formato: String) -> String {
        let formateador = DateFormatter()
        formateador.locale = Locale(identifier: "es_MX")
        formateador.timeZone = calendario.timeZone
        formateador.dateFormat = formato
        return formateador.string(from: fecha)
    }
}

// MARK: - VISTA PREVIA

#Preview("Calendario - UACAM Pocket") {
    CalendarioView(servicioTareas: PocketTaskService())
}
