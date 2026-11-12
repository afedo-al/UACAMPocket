//
//  Postulacion.swift
//  UACAMPocket
//
//  Created by Alfredo on 09/11/26.
//


import Foundation

enum EstadoPostulacion: String, Codable, CaseIterable, Identifiable {
    case enviada = "Enviada"
    case enRevision = "En revisión"
    case aceptada = "Aceptada"
    case rechazada = "Rechazada"
    case cancelada = "Cancelada"

    var id: String { rawValue }

    var icono: String {
        switch self {
        case .enviada: return "paperplane.fill"
        case .enRevision: return "clock.fill"
        case .aceptada: return "checkmark.circle.fill"
        case .rechazada: return "xmark.circle.fill"
        case .cancelada: return "minus.circle.fill"
        }
    }

    var descripcion: String {
        switch self {
        case .enviada: return "Tu postulación fue registrada en este dispositivo."
        case .enRevision: return "El docente está revisando tu solicitud."
        case .aceptada: return "El docente aceptó tu postulación en el prototipo."
        case .rechazada: return "El docente no seleccionó esta postulación."
        case .cancelada: return "Cancelaste esta postulación."
        }
    }
}

struct Postulacion: Identifiable, Codable, Equatable {
    var id: UUID
    var estudianteId: UUID
    var oportunidadId: UUID
    var estado: EstadoPostulacion
    var fechaPostulacion: Date
    var fechaActualizacion: Date
    var mensajeEstudiante: String?
    var observaciones: String?

    init(
        id: UUID = UUID(),
        estudianteId: UUID,
        oportunidadId: UUID,
        estado: EstadoPostulacion = .enviada,
        fechaPostulacion: Date = Date(),
        fechaActualizacion: Date = Date(),
        mensajeEstudiante: String? = nil,
        observaciones: String? = nil
    ) {
        self.id = id
        self.estudianteId = estudianteId
        self.oportunidadId = oportunidadId
        self.estado = estado
        self.fechaPostulacion = fechaPostulacion
        self.fechaActualizacion = fechaActualizacion
        self.mensajeEstudiante = mensajeEstudiante
        self.observaciones = observaciones
    }

    var estaPendiente: Bool { estado == .enviada || estado == .enRevision }
    var puedeCancelarse: Bool { estaPendiente }

    mutating func actualizarEstado(_ nuevoEstado: EstadoPostulacion, observaciones: String? = nil) {
        estado = nuevoEstado
        self.observaciones = observaciones
        fechaActualizacion = Date()
    }

    mutating func cancelar() {
        estado = .cancelada
        fechaActualizacion = Date()
    }
}
