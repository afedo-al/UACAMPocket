//
//  Oportunidad.swift
//  UACAMPocket
//
//  Created by Alfredo on 09/11/26.
//


import Foundation

// Los rawValues son también los textos usados por la interfaz y el JSON local.
enum TipoOportunidad: String, Codable, CaseIterable, Identifiable {
    case servicioSocial = "Servicio social"
    case practicas = "Prácticas profesionales"
    case proyecto = "Proyecto"
    case investigacion = "Investigación"
    case desarrolloTecnologico = "Desarrollo tecnológico"
    case colaboracion = "Colaboración universitaria"

    var id: String { rawValue }
}

enum ModalidadOportunidad: String, Codable, CaseIterable, Identifiable {
    case presencial = "Presencial"
    case virtual = "Virtual"
    case hibrida = "Híbrida"
    var id: String { rawValue }
}

enum EstadoOportunidad: String, Codable, CaseIterable, Identifiable {
    case abierta = "Abierta"
    case pausada = "Pausada"
    case cerrada = "Cerrada"
    var id: String { rawValue }
}

struct Oportunidad: Identifiable, Codable, Equatable {
    var id: UUID
    var titulo: String
    var descripcion: String
    var tipo: TipoOportunidad
    var facultad: String
    var carrera: String?
    var perfilRequerido: String
    var modalidad: ModalidadOportunidad
    var vacantes: Int
    var estado: EstadoOportunidad
    var docenteResponsable: String
    var docenteId: UUID
    var fechaPublicacion: Date
    var fechaLimite: Date?
    var acreditacionValidada: Bool

    init(
        id: UUID = UUID(),
        titulo: String,
        descripcion: String,
        tipo: TipoOportunidad,
        facultad: String,
        carrera: String? = nil,
        perfilRequerido: String,
        modalidad: ModalidadOportunidad,
        vacantes: Int,
        estado: EstadoOportunidad = .abierta,
        docenteResponsable: String,
        docenteId: UUID = UUID(),
        fechaPublicacion: Date = Date(),
        fechaLimite: Date? = nil,
        acreditacionValidada: Bool = false
    ) {
        self.id = id
        self.titulo = titulo
        self.descripcion = descripcion
        self.tipo = tipo
        self.facultad = facultad
        self.carrera = carrera
        self.perfilRequerido = perfilRequerido
        self.modalidad = modalidad
        self.vacantes = vacantes
        self.estado = estado
        self.docenteResponsable = docenteResponsable
        self.docenteId = docenteId
        self.fechaPublicacion = fechaPublicacion
        self.fechaLimite = fechaLimite
        self.acreditacionValidada = acreditacionValidada
    }

    var estaDisponible: Bool {
        estado == .abierta && vacantes > 0 &&
        (fechaLimite.map { $0 >= Date() } ?? true)
    }

    var vacantesTexto: String {
        "\(vacantes) \(vacantes == 1 ? "vacante" : "vacantes")"
    }

    // Ejemplos académicos: no representan convocatorias reales.
    static var ejemplos: [Oportunidad] {
        let limite = Calendar.current.date(byAdding: .day, value: 60, to: Date())
        let facultad = "Facultad de Ingeniería"
        return [
            Oportunidad(
                id: UUID(uuidString: "30000000-0000-0000-0000-000000000001")!,
                titulo: "Desarrollo de aplicación móvil",
                descripcion: "Diseñar una aplicación para organizar actividades universitarias y apoyar la comunicación con estudiantes.",
                tipo: .servicioSocial, facultad: facultad,
                carrera: "Ingeniería en Tecnología de Software",
                perfilRequerido: "Conocimientos básicos de programación, diseño de interfaces y trabajo en equipo.",
                modalidad: .hibrida, vacantes: 2,
                docenteResponsable: "Docente de demostración", fechaLimite: limite
            ),
            Oportunidad(
                id: UUID(uuidString: "30000000-0000-0000-0000-000000000002")!,
                titulo: "Plataforma de tutorías",
                descripcion: "Crear una plataforma de tutorías académicas para apoyar a estudiantes en distintas materias.",
                tipo: .practicas, facultad: facultad,
                perfilRequerido: "Programación web, bases de datos y capacidad de colaborar con docentes.",
                modalidad: .presencial, vacantes: 3,
                docenteResponsable: "Docente de demostración", fechaLimite: limite
            ),
            Oportunidad(
                id: UUID(uuidString: "30000000-0000-0000-0000-000000000003")!,
                titulo: "Análisis de datos del campus",
                descripcion: "Analizar información de demostración para explorar patrones útiles en la vida universitaria.",
                tipo: .investigacion, facultad: facultad,
                perfilRequerido: "Interés por estadísticas, análisis de datos y visualización.",
                modalidad: .hibrida, vacantes: 2,
                docenteResponsable: "Docente de demostración", fechaLimite: limite
            )
        ]
    }
}
