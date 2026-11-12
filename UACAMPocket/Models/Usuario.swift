//
//  Usuario.swift
//  UACAMPocket
//
//  Created by Alfredo on 09/11/26.
//


import Foundation

enum TipoUsuario: String, Codable, CaseIterable, Identifiable {
    case estudiante = "Estudiante"
    case docente = "Docente"
    var id: String { rawValue }
}

struct Usuario: Identifiable, Codable, Equatable {
    let id: UUID
    var nombre: String
    var correo: String
    var rol: TipoUsuario
    var carrera: String?
    var facultad: String?

    init(
        id: UUID = UUID(),
        nombre: String,
        correo: String,
        rol: TipoUsuario,
        carrera: String? = nil,
        facultad: String? = nil
    ) {
        self.id = id
        self.nombre = nombre
        self.correo = correo
        self.rol = rol
        self.carrera = carrera
        self.facultad = facultad
    }
}
