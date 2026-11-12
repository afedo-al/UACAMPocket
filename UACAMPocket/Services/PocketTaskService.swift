//
//  PocketTaskService.swift
//  UACAMPocket
//
//  Created by Alfredo on 10/11/26.
//


import Foundation
import Combine

// MARK: - Prioridad de una tarea
// Nombre diferente de "PrioridadTarea" para que este archivo pueda
// agregarse antes de sustituir el antiguo TareasView.swift.

enum PocketTaskPriority: String, Codable, CaseIterable, Identifiable {
    case alta = "Alta"
    case media = "Media"
    case baja = "Baja"

    var id: String { rawValue }
}

// MARK: - Modelo compartido de tareas
// IMPORTANTE: los nombres y tipos almacenados coinciden con el modelo
// TareaAcademica que usaba la primera version de TareasView.swift.
// Asi se decodifica el JSON anterior sin perder IDs ni fechas.

struct PocketTask: Identifiable, Codable, Equatable {
    let id: UUID
    var titulo: String
    var materia: String
    var notas: String
    var fechaEntrega: Date
    var prioridad: PocketTaskPriority
    var completada: Bool
    let fechaCreacion: Date

    init(
        id: UUID = UUID(),
        titulo: String,
        materia: String,
        notas: String = "",
        fechaEntrega: Date,
        prioridad: PocketTaskPriority = .media,
        completada: Bool = false,
        fechaCreacion: Date = Date()
    ) {
        self.id = id
        self.titulo = titulo
        self.materia = materia
        self.notas = notas
        self.fechaEntrega = fechaEntrega
        self.prioridad = prioridad
        self.completada = completada
        self.fechaCreacion = fechaCreacion
    }
}

// MARK: - Errores descriptivos

enum PocketTaskServiceError: LocalizedError {
    case tituloInvalido
    case materiaInvalida
    case notasDemasiadoLargas
    case tareaNoEncontrada
    case almacenamientoBloqueado
    case noSePudoGuardar

    var errorDescription: String? {
        switch self {
        case .tituloInvalido:
            return "El título debe tener entre 3 y 120 caracteres."
        case .materiaInvalida:
            return "La materia debe tener entre 2 y 100 caracteres."
        case .notasDemasiadoLargas:
            return "Las notas no pueden superar los 500 caracteres."
        case .tareaNoEncontrada:
            return "La tarea ya no existe en este dispositivo."
        case .almacenamientoBloqueado:
            return "Las tareas guardadas no pudieron leerse. No se sobrescribirán para evitar perderlas."
        case .noSePudoGuardar:
            return "No fue posible guardar los cambios de las tareas."
        }
    }
}

// MARK: - Servicio compartido de tareas
// Se creara una sola vez en ContentView y se pasara a
// TareasView, InicioView y CalendarioView en los siguientes pasos.

@MainActor
final class PocketTaskService: ObservableObject {

    @Published private(set) var tareas: [PocketTask] = []
    @Published private(set) var mensajeError: String?

    // ES LA MISMA CLAVE del antiguo AlmacenTareas.
    // No cambiamos el formato ni el identificador del almacenamiento.
    static let claveDatos = "uacampocket.demo.tareas.v1"

    // Copia de seguridad de los datos anteriores al primer cambio
    // realizado por este servicio (no se sobreescribe).
    static let claveRespaldo = "uacampocket.demo.tareas.v1.respaldo"

    private let defaults: UserDefaults
    private var almacenamientoBloqueado = false

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        cargar()
    }

    // MARK: - Resumen

    var pendientes: Int {
        tareas.filter { !$0.completada }.count
    }

    var completadas: Int {
        tareas.filter(\.completada).count
    }

    var puedeModificar: Bool {
        !almacenamientoBloqueado
    }

    var tareasPendientes: [PocketTask] {
        ordenar(tareas.filter { !$0.completada })
    }

    // Entregas a partir de hoy, sin incluir tareas completadas.
    var proximasEntregas: [PocketTask] {
        let hoy = Calendar.current.startOfDay(for: Date())
        return ordenar(tareas.filter {
            !$0.completada && $0.fechaEntrega >= hoy
        })
    }

    // Entregas anteriores a hoy que aun no se completan.
    var tareasVencidas: [PocketTask] {
        let hoy = Calendar.current.startOfDay(for: Date())
        return ordenar(tareas.filter {
            !$0.completada && $0.fechaEntrega < hoy
        })
    }

    // MARK: - Consultas para Calendario

    func tareas(
        para fecha: Date,
        incluirCompletadas: Bool = true
    ) -> [PocketTask] {
        ordenar(tareas.filter { tarea in
            Calendar.current.isDate(tarea.fechaEntrega, inSameDayAs: fecha) &&
            (incluirCompletadas || !tarea.completada)
        })
    }

    func tareas(
        desde inicio: Date,
        hasta fin: Date,
        incluirCompletadas: Bool = true
    ) -> [PocketTask] {
        let calendario = Calendar.current
        let diaInicial = calendario.startOfDay(for: inicio)
        let diaFinal = calendario.startOfDay(for: fin)
        guard diaInicial <= diaFinal else { return [] }

        return ordenar(tareas.filter { tarea in
            let diaEntrega = calendario.startOfDay(for: tarea.fechaEntrega)
            return diaEntrega >= diaInicial &&
                   diaEntrega <= diaFinal &&
                   (incluirCompletadas || !tarea.completada)
        })
    }

    func tarea(conID id: UUID) -> PocketTask? {
        tareas.first { $0.id == id }
    }

    // MARK: - Crear

    @discardableResult
    func agregar(
        titulo: String,
        materia: String,
        notas: String = "",
        fechaEntrega: Date,
        prioridad: PocketTaskPriority = .media
    ) throws -> PocketTask {
        try comprobarAlmacenamiento()
        let datos = try validar(titulo: titulo, materia: materia, notas: notas)

        let nueva = PocketTask(
            titulo: datos.titulo,
            materia: datos.materia,
            notas: datos.notas,
            fechaEntrega: fechaEntrega,
            prioridad: prioridad
        )

        var actualizadas = tareas
        actualizadas.append(nueva)
        try guardarYPublicar(actualizadas)
        return nueva
    }

    // MARK: - Editar

    func actualizar(
        id: UUID,
        titulo: String,
        materia: String,
        notas: String,
        fechaEntrega: Date,
        prioridad: PocketTaskPriority
    ) throws {
        try comprobarAlmacenamiento()
        let datos = try validar(titulo: titulo, materia: materia, notas: notas)
        guard let indice = tareas.firstIndex(where: { $0.id == id }) else {
            throw PocketTaskServiceError.tareaNoEncontrada
        }

        var actualizadas = tareas
        actualizadas[indice].titulo = datos.titulo
        actualizadas[indice].materia = datos.materia
        actualizadas[indice].notas = datos.notas
        actualizadas[indice].fechaEntrega = fechaEntrega
        actualizadas[indice].prioridad = prioridad
        // Se conservan id, fechaCreacion y completada.
        try guardarYPublicar(actualizadas)
    }

    // MARK: - Completar o volver a pendiente

    @discardableResult
    func alternarCompletada(id: UUID) throws -> Bool {
        try comprobarAlmacenamiento()
        guard let indice = tareas.firstIndex(where: { $0.id == id }) else {
            throw PocketTaskServiceError.tareaNoEncontrada
        }

        var actualizadas = tareas
        actualizadas[indice].completada.toggle()
        let nuevoEstado = actualizadas[indice].completada
        try guardarYPublicar(actualizadas)
        return nuevoEstado
    }

    func marcarCompletada(id: UUID, completada: Bool) throws {
        try comprobarAlmacenamiento()
        guard let indice = tareas.firstIndex(where: { $0.id == id }) else {
            throw PocketTaskServiceError.tareaNoEncontrada
        }
        guard tareas[indice].completada != completada else { return }

        var actualizadas = tareas
        actualizadas[indice].completada = completada
        try guardarYPublicar(actualizadas)
    }

    // MARK: - Eliminar

    func eliminar(id: UUID) throws {
        try comprobarAlmacenamiento()
        guard tareas.contains(where: { $0.id == id }) else {
            throw PocketTaskServiceError.tareaNoEncontrada
        }
        let actualizadas = tareas.filter { $0.id != id }
        try guardarYPublicar(actualizadas)
    }

    // MARK: - Cargar datos anteriores

    private func cargar() {
        // Si la clave existe pero el contenido es invalido, NO se
        // reemplaza por ejemplos: se protege el dato original.
        if defaults.object(forKey: Self.claveDatos) != nil {
            guard let datos = defaults.data(forKey: Self.claveDatos) else {
                almacenamientoBloqueado = true
                mensajeError = "El almacenamiento contiene un valor que no es JSON. No fue modificado."
                return
            }

            do {
                // Compatible con [TareaAcademica] del modulo anterior:
                // claves, UUID, Date y los valores Alta/Media/Baja iguales.
                tareas = try JSONDecoder().decode([PocketTask].self, from: datos)
                mensajeError = nil
            } catch {
                almacenamientoBloqueado = true
                mensajeError = "No se pudieron recuperar las tareas previas: \(error.localizedDescription). No se sobrescribieron."
            }
            return
        }

        // Instalar por primera vez: dos ejemplos del anteproyecto.
        // Este bloque NO se ejecuta si ya existe cualquier registro,
        // incluso cuando el usuario elimino todas sus tareas.
        let hoy = Calendar.current.startOfDay(for: Date())
        let manana = Calendar.current.date(byAdding: .day, value: 1, to: hoy) ?? hoy
        let dosDias = Calendar.current.date(byAdding: .day, value: 2, to: hoy) ?? hoy

        let iniciales: [PocketTask] = [
            PocketTask(
                titulo: "Proyecto SwiftUI",
                materia: "Programación Web",
                notas: "Preparar la demostracion de la aplicacion.",
                fechaEntrega: manana,
                prioridad: .alta
            ),
            PocketTask(
                titulo: "Investigación IA",
                materia: "Sistemas Inteligentes",
                notas: "Revisar las fuentes de la investigacion.",
                fechaEntrega: dosDias,
                prioridad: .media
            )
        ]

        do {
            try guardarYPublicar(iniciales)
        } catch {
            // Aunque falle el primer guardado, los ejemplos pueden verse,
            // pero la pantalla podra avisar que no son persistentes.
            tareas = iniciales
        }
    }

    // MARK: - Validaciones

    private func validar(
        titulo: String,
        materia: String,
        notas: String
    ) throws -> (titulo: String, materia: String, notas: String) {
        let t = titulo.trimmingCharacters(in: .whitespacesAndNewlines)
        let m = materia.trimmingCharacters(in: .whitespacesAndNewlines)
        let n = notas.trimmingCharacters(in: .whitespacesAndNewlines)

        guard (3...120).contains(t.count) else {
            throw PocketTaskServiceError.tituloInvalido
        }
        guard (2...100).contains(m.count) else {
            throw PocketTaskServiceError.materiaInvalida
        }
        guard n.count <= 500 else {
            throw PocketTaskServiceError.notasDemasiadoLargas
        }
        return (t, m, n)
    }

    private func comprobarAlmacenamiento() throws {
        guard !almacenamientoBloqueado else {
            throw PocketTaskServiceError.almacenamientoBloqueado
        }
    }

    private func ordenar(_ elementos: [PocketTask]) -> [PocketTask] {
        elementos.sorted { a, b in
            if a.fechaEntrega != b.fechaEntrega {
                return a.fechaEntrega < b.fechaEntrega
            }
            return a.titulo.localizedStandardCompare(b.titulo) == .orderedAscending
        }
    }

    // MARK: - Persistencia protegida

    private func guardarYPublicar(_ nuevas: [PocketTask]) throws {
        try comprobarAlmacenamiento()
        do {
            let datos = try JSONEncoder().encode(nuevas)

            // Respalda una sola vez los bytes existentes, antes de
            // la primera modificacion hecha por este nuevo servicio.
            if defaults.object(forKey: Self.claveRespaldo) == nil,
               let anteriores = defaults.data(forKey: Self.claveDatos) {
                defaults.set(anteriores, forKey: Self.claveRespaldo)
            }

            defaults.set(datos, forKey: Self.claveDatos)
            guard defaults.data(forKey: Self.claveDatos) == datos else {
                throw PocketTaskServiceError.noSePudoGuardar
            }

            tareas = nuevas
            mensajeError = nil
        } catch {
            // En memoria se conserva el conjunto anterior y la app
            // puede mostrar el error al usuario.
            mensajeError = "No se guardaron los cambios: \(error.localizedDescription)"
            throw error
        }
    }
}
