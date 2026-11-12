//
//  TramitesView.swift
//  UACAMPocket
//
//  Created by Alfredo on 09/11/26.
//


import SwiftUI

// MARK: - Datos orientativos exclusivos de esta pantalla
// No representan requisitos ni estados oficiales de la UACAM.

private enum TipoTramiteDemo: String, CaseIterable, Identifiable {
    case servicioSocial = "Servicio social"
    case practicas = "Prácticas profesionales"

    var id: String { rawValue }

    var icono: String {
        switch self {
        case .servicioSocial: return "graduationcap.fill"
        case .practicas: return "briefcase.fill"
        }
    }

    var explicacion: String {
        switch self {
        case .servicioSocial:
            return "Consulta cómo iniciar un posible proceso de servicio social y qué información necesitas verificar."
        case .practicas:
            return "Explora una ruta orientativa para organizar el inicio de tus prácticas profesionales."
        }
    }

    var puntosPorConfirmar: [String] {
        switch self {
        case .servicioSocial:
            return [
                "Verificar los requisitos y periodos vigentes con el área responsable.",
                "Confirmar si la oportunidad elegida puede acreditarse como servicio social.",
                "Solicitar la lista oficial de documentos antes de prepararlos.",
                "Identificar dónde presentar la solicitud y cómo recibir seguimiento."
            ]
        case .practicas:
            return [
                "Consultar los criterios y periodos de prácticas de tu facultad.",
                "Confirmar la elegibilidad del proyecto o institución receptora.",
                "Solicitar la lista de documentos y autorizaciones vigentes.",
                "Verificar el procedimiento de registro, supervisión y seguimiento."
            ]
        }
    }

    var pasos: [PasoTramiteDemo] {
        let contexto = self == .servicioSocial
            ? "servicio social"
            : "prácticas profesionales"

        return [
            PasoTramiteDemo(
                numero: 0,
                titulo: "Consultar requisitos",
                icono: "doc.text",
                detalle: "Consulta los criterios, fechas y documentos oficiales de \(contexto) con el departamento responsable. Esta aplicación no confirma esos requisitos."
            ),
            PasoTramiteDemo(
                numero: 1,
                titulo: "Encontrar una oportunidad",
                icono: "magnifyingglass",
                detalle: "Explora convocatorias relacionadas y pregunta al área responsable si la oportunidad seleccionada es válida para \(contexto)."
            ),
            PasoTramiteDemo(
                numero: 2,
                titulo: "Preparar documentación",
                icono: "folder",
                detalle: "Reúne únicamente los documentos indicados en las instrucciones oficiales vigentes. No envíes documentos personales a este prototipo."
            ),
            PasoTramiteDemo(
                numero: 3,
                titulo: "Realizar la solicitud",
                icono: "paperplane",
                detalle: "Presenta tu solicitud exclusivamente por el medio que indique la universidad. Esta pantalla no envía formularios reales."
            ),
            PasoTramiteDemo(
                numero: 4,
                titulo: "Dar seguimiento",
                icono: "clock",
                detalle: "Consulta los canales oficiales para conocer avances. La línea de tiempo que se muestra aquí es solamente una demostración interactiva."
            )
        ]
    }
}

// MARK: - Objetivos de orientación del anteproyecto
// No son solicitudes y no representan requisitos oficiales.

private enum ObjetivoOrientacion: String, CaseIterable, Identifiable {
    case servicioSocial = "Servicio social"
    case practicas = "Prácticas"
    case documentos = "Documentos académicos"
    case justificante = "Justificante de asistencia"

    var id: String { rawValue }

    var icono: String {
        switch self {
        case .servicioSocial: return "graduationcap.fill"
        case .practicas: return "briefcase.fill"
        case .documentos: return "doc.text.fill"
        case .justificante: return "cross.case.fill"
        }
    }

    var descripcion: String {
        switch self {
        case .servicioSocial:
            return "Quiero iniciar mi servicio social y conocer la ruta que debo verificar."
        case .practicas:
            return "Quiero comenzar mis prácticas profesionales y revisar los siguientes pasos."
        case .documentos:
            return "Necesito consultar trámites como constancias, boletas o historial académico."
        case .justificante:
            return "Quiero consultar el trámite de justificante de asistencia mencionado en el cartel de ISC e ITS."
        }
    }

    var requisitosOrientativos: String {
        switch self {
        case .servicioSocial:
            return "Pregunta por los requisitos, periodos, documentos y criterios de acreditación vigentes. No hay una lista oficial validada en esta app."
        case .practicas:
            return "Pregunta por los requisitos, periodos, documentos y autorizaciones vigentes. No hay una lista oficial validada en esta app."
        case .documentos:
            return "Consulta el formulario de la coordinación para conocer qué datos solicita actualmente. Los requisitos de cada documento no están verificados aquí."
        case .justificante:
            return "El cartel menciona justificante médico de IMSS, ISSSTE o institución pública de salud. Confirma qué comprobantes acepta la coordinación y los plazos aplicables antes de enviarlos."
        }
    }

    var responsableOrientativo: String {
        switch self {
        case .servicioSocial:
            return "Área o departamento de servicio social correspondiente a tu programa; confirma el responsable con tu facultad."
        case .practicas:
            return "Área o coordinación responsable de prácticas de tu programa; confirma el contacto con tu facultad."
        case .documentos, .justificante:
            return "Coordinación de ISC e ITS, de acuerdo con el cartel QR compartido. Confirma que el formulario siga vigente."
        }
    }

    var ubicacionOrientativa: String {
        switch self {
        case .servicioSocial, .practicas:
            return "La oficina y ubicación de atención no están confirmadas. Pregunta a tu facultad o consulta el portal institucional."
        case .documentos, .justificante:
            return "El cartel QR no proporciona una ubicación física verificable. Consulta a la coordinación ISC e ITS."
        }
    }

    var usaGuiaSimulada: Bool {
        self == .servicioSocial || self == .practicas
    }

    var pasosConsulta: [String] {
        switch self {
        case .documentos:
            return [
                "Identifica el documento que necesitas dentro de la lista del cartel QR.",
                "Abre el formulario compartido por la Coordinación ISC e ITS.",
                "Verifica requisitos, datos solicitados y vigencia antes de responder.",
                "Consulta directamente a la coordinación cómo se recibe y entrega el documento."
            ]
        case .justificante:
            return [
                "Consulta las indicaciones vigentes para justificantes de asistencia.",
                "Verifica qué comprobantes médicos y fechas acepta la coordinación.",
                "Abre el formulario del QR solamente si confirmaste que está vigente.",
                "Da seguimiento por los medios que te indique la coordinación."
            ]
        case .servicioSocial, .practicas:
            return []
        }
    }
}

private struct PasoTramiteDemo: Identifiable {
    let numero: Int
    let titulo: String
    let icono: String
    let detalle: String

    var id: Int { numero }
}

private enum EstadoTramiteDemo: Int, CaseIterable, Identifiable {
    case solicitudEnviada = 0
    case enRevision
    case validada
    case asignacion
    case inicio

    var id: Int { rawValue }

    var titulo: String {
        switch self {
        case .solicitudEnviada: return "Solicitud enviada"
        case .enRevision: return "En revisión"
        case .validada: return "Validada"
        case .asignacion: return "Asignación"
        case .inicio: return "Inicio"
        }
    }

    var descripcion: String {
        switch self {
        case .solicitudEnviada:
            return "Ejemplo: se registró una solicitud."
        case .enRevision:
            return "Ejemplo: el área responsable está revisando la solicitud."
        case .validada:
            return "Ejemplo: se completó una revisión administrativa."
        case .asignacion:
            return "Ejemplo: se comunicó una asignación."
        case .inicio:
            return "Ejemplo: el proceso llegó a la etapa de inicio."
        }
    }
}

// MARK: - Pantalla de trámites

struct TramitesView: View {
    @State private var objetivoSeleccionado: ObjetivoOrientacion = .servicioSocial
    @State private var pasoSeleccionado = 0
    @State private var estadoSimulado: EstadoTramiteDemo = .enRevision
    @Environment(\.openURL) private var openURL

    // Lista tomada del cartel QR de la Coordinación de ISC e ITS.
    // Todos los servicios comparten el mismo formulario externo.
    private let tramitesCoordinacion = [
        "Boleta de calificación",
        "Constancia de estudios",
        "Examen de competencia",
        "Historial académico",
        "Solicitud de baja de Unidad de Aprendizaje",
        "Carta de buena conducta",
        "Oficio de solicitud de becas",
        "Justificante de asistencia (médico, IMSS, ISSSTE o institución pública de salud)"
    ]

    private let urlFormularioCoordinacion =
        "https://docs.google.com/forms/d/e/1FAIpQLSdmbYLYwoEhrOopkBg2kkiDrjTFPDmYMdZ0hWw1O2MVzhLVVA/viewform"

    // Portal oficial de trámites para alumnos de la UACAM.
    // Puede mostrar categorías y contenido sujeto a cambios del sitio.
    private let urlTramitesUACAM =
        "https://www.uacam.mx/main_page/tramites/1"

    // Opcional: la pantalla principal podrá llevar al usuario
    // a la pestaña Oportunidades cuando conectemos la navegación.
    let abrirOportunidades: (() -> Void)?

    init(abrirOportunidades: (() -> Void)? = nil) {
        self.abrirOportunidades = abrirOportunidades
    }

    private var tipoSeleccionado: TipoTramiteDemo {
        objetivoSeleccionado == .practicas ? .practicas : .servicioSocial
    }

    private var pasos: [PasoTramiteDemo] {
        tipoSeleccionado.pasos
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.section) {
                    encabezado
                    selectorObjetivo
                    seccionRutaPersonalizada

                    if objetivoSeleccionado.usaGuiaSimulada {
                        seccionRequisitos
                        seccionRuta
                        seccionSeguimiento
                    } else {
                        seccionConsultaCoordinacion
                    }

                    seccionTramitesCoordinacion
                    seccionTramitesInstitucionales
                    avisoDemostracion
                }
                .padding(.horizontal, AppTheme.Spacing.screenHorizontal)
                .padding(.top, AppTheme.Spacing.md)
                .padding(.bottom, AppTheme.Spacing.xxxl)
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())
            .navigationTitle("Trámites")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Encabezado

    private var encabezado: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Label("SERVICIOS Y GUÍAS", systemImage: "doc.text.magnifyingglass")
                .font(AppTheme.Typography.captionBold)
                .foregroundStyle(.white.opacity(0.85))

            Text("Trámites universitarios")
                .font(AppTheme.Typography.title2)
                .foregroundStyle(.white)

            Text("Dinos qué necesitas hacer y consulta una ruta de orientación con requisitos por confirmar, contactos y enlaces disponibles.")
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

    // MARK: - Trámites de la Coordinación ISC e ITS
    // Este formulario fue identificado en el QR compartido por el usuario.
    // No se ha verificado externamente su disponibilidad o vigencia.

    private var seccionTramitesCoordinacion: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PocketSectionHeader(
                title: "Trámites de coordinación",
                subtitle: "Ingeniería en Sistemas Computacionales e Ingeniería en Tecnología de Software"
            )

            PocketCard {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Label("Coordinación ISC e ITS", systemImage: "building.2")
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.Colors.primaryText)

                    Text("Estos trámites aparecen en el cartel QR de la coordinación:")
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(AppTheme.Colors.secondaryText)

                    ForEach(tramitesCoordinacion, id: \.self) { tramite in
                        HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "doc.text")
                                .foregroundStyle(AppTheme.Colors.blue)
                                .padding(.top, 2)

                            Text(tramite)
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundStyle(AppTheme.Colors.primaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    Divider()

                    PocketPrimaryButton(
                        title: "Abrir formulario de la coordinación",
                        systemImage: "arrow.up.right.square"
                    ) {
                        if let url = URL(string: urlFormularioCoordinacion) {
                            openURL(url)
                        }
                    }

                    Label(
                        "El QR apunta a un formulario externo de Google. Verifica con la coordinación que sigue vigente antes de enviar información o justificantes médicos. UACAM Pocket no recibe estos documentos.",
                        systemImage: "info.circle"
                    )
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                }
            }
        }
    }

    // MARK: - Portal de trámites UACAM
    // Es un sitio oficial de consulta, independiente de la coordinación.
    // La lista de opciones y su disponibilidad dependen del portal.

    private var seccionTramitesInstitucionales: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PocketSectionHeader(
                title: "Trámites institucionales",
                subtitle: "Portal oficial de alumnos de la UACAM"
            )

            PocketCard {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Label("Trámites para alumnos", systemImage: "building.columns")
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.Colors.primaryText)

                    Text(
                        "Consulta la página institucional de trámites para alumnos. " +
                        "Los procedimientos y documentos disponibles dependen de la información vigente que publique la UACAM."
                    )
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                    PocketPrimaryButton(
                        title: "Abrir portal oficial UACAM",
                        systemImage: "arrow.up.right.square"
                    ) {
                        if let url = URL(string: urlTramitesUACAM) {
                            openURL(url)
                        }
                    }

                    Label(
                        "Este enlace es un directorio institucional. No garantiza que todos los trámites " +
                        "se puedan iniciar en línea ni sustituye al formulario de coordinación.",
                        systemImage: "info.circle"
                    )
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                }
            }
        }
    }

    // MARK: - Diferenciador del anteproyecto (página 9)
    // Una intención abre una ruta de orientación.

    private var selectorObjetivo: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PocketSectionHeader(
                title: "¿Qué necesitas hacer?",
                subtitle: "Elige un objetivo para ver su ruta. No es una solicitud oficial."
            )

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: AppTheme.Spacing.sm),
                    GridItem(.flexible(), spacing: AppTheme.Spacing.sm)
                ],
                spacing: AppTheme.Spacing.sm
            ) {
                ForEach(ObjetivoOrientacion.allCases) { objetivo in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            objetivoSeleccionado = objetivo
                            pasoSeleccionado = 0
                            estadoSimulado = .enRevision
                        }
                    } label: {
                        VStack(spacing: AppTheme.Spacing.xs) {
                            Image(systemName: objetivo.icono)
                                .font(.title3)
                                .accessibilityHidden(true)

                            Text(objetivo.rawValue)
                                .font(AppTheme.Typography.captionBold)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .foregroundStyle(
                            objetivoSeleccionado == objetivo
                            ? Color.white
                            : AppTheme.Colors.primaryText
                        )
                        .frame(maxWidth: .infinity, minHeight: 96)
                        .padding(.horizontal, AppTheme.Spacing.xs)
                        .background(
                            objetivoSeleccionado == objetivo
                            ? AppTheme.Colors.blue
                            : AppTheme.Colors.surface,
                            in: RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(
                        objetivoSeleccionado == objetivo ? [.isSelected] : []
                    )
                }
            }
        }
    }

    // MARK: - Ficha completa de orientación
    // Cubre: requisitos, departamento, ubicación, enlaces y oportunidades.

    private var seccionRutaPersonalizada: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PocketSectionHeader(
                title: "Tu ruta de orientación",
                subtitle: "Información inicial para saber dónde preguntar y cómo continuar."
            )

            PocketCard(showBorder: true) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Label(objetivoSeleccionado.rawValue, systemImage: objetivoSeleccionado.icono)
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.Colors.primaryText)

                    Text(objetivoSeleccionado.descripcion)
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(AppTheme.Colors.secondaryText)

                    Divider()

                    datoOrientativo(
                        titulo: "Requisitos y documentos",
                        icono: "doc.text.magnifyingglass",
                        contenido: objetivoSeleccionado.requisitosOrientativos
                    )

                    datoOrientativo(
                        titulo: "Departamento responsable",
                        icono: "person.crop.rectangle.stack",
                        contenido: objetivoSeleccionado.responsableOrientativo
                    )

                    datoOrientativo(
                        titulo: "Ubicación de atención",
                        icono: "mappin.and.ellipse",
                        contenido: objetivoSeleccionado.ubicacionOrientativa
                    )

                    Divider()

                    if objetivoSeleccionado.usaGuiaSimulada {
                        PocketPrimaryButton(
                            title: "Consultar portal de la UACAM",
                            systemImage: "arrow.up.right.square"
                        ) {
                            abrirEnlace(urlTramitesUACAM)
                        }

                        if let abrirOportunidades {
                            PocketPrimaryButton(
                                title: "Explorar oportunidades relacionadas",
                                systemImage: "magnifyingglass",
                                action: abrirOportunidades
                            )
                        } else {
                            Text("Las oportunidades relacionadas se consultan en la pestaña Oportunidades de UACAM Pocket.")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.secondaryText)
                        }
                    } else {
                        PocketPrimaryButton(
                            title: "Abrir formulario ISC e ITS",
                            systemImage: "arrow.up.right.square"
                        ) {
                            abrirEnlace(urlFormularioCoordinacion)
                        }
                    }

                    Label(
                        "Los datos de esta ficha son orientación general. Los documentos, plazos, responsables y puntos de atención deben confirmarse con la universidad.",
                        systemImage: "info.circle"
                    )
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                }
            }
        }
    }

    private func datoOrientativo(
        titulo: String,
        icono: String,
        contenido: String
    ) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Label(titulo, systemImage: icono)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundStyle(AppTheme.Colors.primaryText)

            Text(contenido)
                .font(AppTheme.Typography.footnote)
                .foregroundStyle(AppTheme.Colors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Ruta de consulta para trámites del cartel QR
    // No inventa pasos de presentación ni estados de aprobación.

    private var seccionConsultaCoordinacion: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PocketSectionHeader(
                title: "Pasos para orientarte",
                subtitle: "Recomendaciones previas, no un proceso oficial validado."
            )

            PocketCard {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    ForEach(
                        Array(objetivoSeleccionado.pasosConsulta.enumerated()),
                        id: \.offset
                    ) { indice, texto in
                        HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                            Text(String(format: "%02d", indice + 1))
                                .font(AppTheme.Typography.captionBold)
                                .foregroundStyle(AppTheme.Colors.blue)
                                .frame(width: 32, height: 32)
                                .background(
                                    AppTheme.Colors.secondarySurface,
                                    in: Circle()
                                )

                            Text(texto)
                                .font(AppTheme.Typography.footnote)
                                .foregroundStyle(AppTheme.Colors.primaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
    }

    private func abrirEnlace(_ direccion: String) {
        guard let url = URL(string: direccion) else { return }
        openURL(url)
    }

    // MARK: - Información por confirmar

    private var seccionRequisitos: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PocketSectionHeader(
                title: "Requisitos por confirmar",
                subtitle: "Lista orientativa, no requisitos oficiales"
            )

            PocketCard {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    ForEach(tipoSeleccionado.puntosPorConfirmar, id: \.self) { punto in
                        HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "checkmark.circle")
                                .foregroundStyle(AppTheme.Colors.blue)
                                .padding(.top, 2)

                            Text(punto)
                                .font(AppTheme.Typography.footnote)
                                .foregroundStyle(AppTheme.Colors.primaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Cinco pasos del anteproyecto

    private var seccionRuta: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PocketSectionHeader(
                title: "Tu ruta",
                subtitle: "Selecciona un paso para ver su explicación."
            )

            PocketCard {
                VStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(pasos) { paso in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                pasoSeleccionado = paso.numero
                            }
                        } label: {
                            HStack(spacing: AppTheme.Spacing.sm) {
                                Text(String(format: "%02d", paso.numero + 1))
                                    .font(AppTheme.Typography.captionBold)
                                    .foregroundStyle(
                                        pasoSeleccionado == paso.numero
                                        ? Color.white
                                        : AppTheme.Colors.blue
                                    )
                                    .frame(width: 34, height: 34)
                                    .background(
                                        pasoSeleccionado == paso.numero
                                        ? AppTheme.Colors.blue
                                        : AppTheme.Colors.secondarySurface,
                                        in: Circle()
                                    )

                                Text(paso.titulo)
                                    .font(AppTheme.Typography.bodyMedium)
                                    .foregroundStyle(AppTheme.Colors.primaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Image(systemName: pasoSeleccionado == paso.numero
                                      ? "checkmark.circle.fill" : "chevron.right")
                                    .foregroundStyle(AppTheme.Colors.blue)
                            }
                            .frame(minHeight: 46)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(
                            pasoSeleccionado == paso.numero ? [.isSelected] : []
                        )

                        if paso.numero != pasos.last?.numero {
                            Divider()
                        }
                    }
                }
            }

            if pasos.indices.contains(pasoSeleccionado) {
                PocketCard(showBorder: true, showShadow: false) {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Label(
                            "Paso \(pasoSeleccionado + 1): \(pasos[pasoSeleccionado].titulo)",
                            systemImage: pasos[pasoSeleccionado].icono
                        )
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.Colors.primaryText)

                        Text(pasos[pasoSeleccionado].detalle)
                            .font(AppTheme.Typography.footnote)
                            .foregroundStyle(AppTheme.Colors.secondaryText)

                        if pasoSeleccionado == 1, let abrirOportunidades {
                            PocketPrimaryButton(
                                title: "Explorar oportunidades",
                                systemImage: "magnifyingglass",
                                action: abrirOportunidades
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Línea de tiempo de demostración

    private var seccionSeguimiento: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PocketSectionHeader(
                title: "Seguimiento de ejemplo",
                subtitle: "Toca un estado o avanza la simulación."
            )

            PocketCard {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                            Text("ESTADO SIMULADO")
                                .font(AppTheme.Typography.small)
                                .foregroundStyle(AppTheme.Colors.secondaryText)

                            Text(estadoSimulado.titulo)
                                .font(AppTheme.Typography.title3)
                                .foregroundStyle(AppTheme.Colors.blue)
                        }
                        Spacer()
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title2)
                            .foregroundStyle(AppTheme.Colors.blue)
                    }

                    Text(estadoSimulado.descripcion)
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(AppTheme.Colors.secondaryText)

                    Divider()

                    ForEach(EstadoTramiteDemo.allCases) { etapa in
                        filaSeguimiento(etapa)
                    }

                    PocketPrimaryButton(
                        title: "Simular siguiente estado",
                        systemImage: "arrow.right",
                        isDisabled: estadoSimulado == .inicio
                    ) {
                        if let siguiente = EstadoTramiteDemo(
                            rawValue: estadoSimulado.rawValue + 1
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                estadoSimulado = siguiente
                            }
                        }
                    }

                    Button("Reiniciar simulación") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            estadoSimulado = .solicitudEnviada
                        }
                    }
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.Colors.blue)
                    .frame(maxWidth: .infinity, minHeight: 44)
                }
            }
        }
    }

    private func filaSeguimiento(_ etapa: EstadoTramiteDemo) -> some View {
        let completada = etapa.rawValue < estadoSimulado.rawValue
        let actual = etapa == estadoSimulado
        let color: Color = completada
            ? AppTheme.Colors.success
            : (actual ? AppTheme.Colors.blue : AppTheme.Colors.tertiaryText)

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                estadoSimulado = etapa
            }
        } label: {
            HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                VStack(spacing: AppTheme.Spacing.xxs) {
                    Image(systemName: completada
                          ? "checkmark.circle.fill"
                          : (actual ? "largecircle.fill.circle" : "circle"))
                        .font(.title3)
                        .foregroundStyle(color)
                        .frame(width: 28, height: 28)

                    if etapa != .inicio {
                        Rectangle()
                            .fill(completada
                                  ? AppTheme.Colors.success.opacity(0.35)
                                  : AppTheme.Colors.border)
                            .frame(width: 2, height: 24)
                    }
                }

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                    Text(etapa.titulo)
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundStyle(
                            actual ? AppTheme.Colors.blue : AppTheme.Colors.primaryText
                        )

                    Text(etapa.descripcion)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if actual {
                    Text("ACTUAL")
                        .font(AppTheme.Typography.small)
                        .foregroundStyle(AppTheme.Colors.blue)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Estado de ejemplo: \(etapa.titulo)")
        .accessibilityHint("Seleccionar este estado en la simulación")
    }

    // MARK: - Aclaración institucional

    private var avisoDemostracion: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.xs) {
            Image(systemName: "exclamationmark.circle")
                .foregroundStyle(AppTheme.Colors.warning)

            Text(
                "Prototipo académico: la orientación de trámites no es una lista oficial de requisitos. " +
                "La guía de servicio social y prácticas incluye estados simulados. " +
                "Los enlaces de la coordinación y del portal UACAM son externos: esta aplicación no registra solicitudes ni consulta respuestas. " +
                "El seguimiento de ejemplo se reinicia al cerrar esta pantalla."
            )
            .font(AppTheme.Typography.small)
            .foregroundStyle(AppTheme.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Vista previa

#Preview("Trámites - UACAM Pocket") {
    TramitesView()
}
