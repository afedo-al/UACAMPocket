//
//  PocketDataService.swift
//  UACAMPocket
//
//  Created by Alfredo on 09/11/26.
//


import Foundation
import Combine

// MARK: - Errores del servicio

enum PocketDataServiceError: LocalizedError {
    case rolNoAutorizado
    case oportunidadNoEncontrada
    case oportunidadDuplicada
    case convocatoriaNoDisponible
    case postulacionDuplicada
    case postulacionNoEncontrada
    case accesoDenegado
    case estadoNoPermitido
    case sinVacantes
    case datosInvalidos
    case almacenamientoBloqueado

    var errorDescription: String? {
        switch self {
        case .rolNoAutorizado:
            return "El perfil no tiene permiso para realizar esta acción."
        case .oportunidadNoEncontrada:
            return "La oportunidad seleccionada ya no existe."
        case .oportunidadDuplicada:
            return "Ya existe una oportunidad con ese identificador."
        case .convocatoriaNoDisponible:
            return "Esta convocatoria no está disponible para nuevas postulaciones."
        case .postulacionDuplicada:
            return "Ya te postulaste a esta oportunidad. No puedes enviar otra solicitud."
        case .postulacionNoEncontrada:
            return "No se encontró la postulación."
        case .accesoDenegado:
            return "No tienes permiso para modificar este registro."
        case .estadoNoPermitido:
            return "No es posible realizar ese cambio de estado."
        case .sinVacantes:
            return "La oportunidad ya no tiene vacantes disponibles."
        case .datosInvalidos:
            return "Revisa el título, la descripción y las vacantes del proyecto."
        case .almacenamientoBloqueado:
            return "No se puede guardar porque el archivo de datos existente no se pudo leer."
        }
    }
}

// MARK: - Servicio de almacenamiento local

@MainActor
final class PocketDataService: ObservableObject {

    @Published private(set) var oportunidades: [Oportunidad] = []
    @Published private(set) var postulaciones: [Postulacion] = []
    @Published private(set) var favoritos: Set<UUID> = []
    @Published private(set) var errorAlCargar: String?

    // El servicio usa el usuario autenticado sin cambiar las firmas
    // existentes en Inicio, Perfil, Oportunidades o el panel docente.
    // Los UUID originales se conservan: Alfredo y José heredan
    // los datos de demostración que ya existían en el simulador.
    private let alumnoOriginal = Usuario(
        id: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
        nombre: "Alfredo J Cruz Miss",
        correo: "demo.alfredo.cruz@uacam.mx",
        rol: .estudiante,
        carrera: "Ingeniería en Tecnología de Software",
        facultad: "Facultad de Ingeniería"
    )

    private let docenteOriginal = Usuario(
        id: UUID(uuidString: "20000000-0000-0000-0000-000000000001")!,
        nombre: "Jose C Aguilar Canepa",
        correo: "demo.jose.aguilar@uacam.mx",
        rol: .docente,
        facultad: "Facultad de Ingeniería"
    )

    @Published private(set) var usuarioActivo: Usuario?
    @Published private(set) var directorioUsuarios: [UUID: Usuario] = [:]

    var estudianteDemo: Usuario {
        guard let actual = usuarioActivo, actual.rol == .estudiante else {
            return alumnoOriginal
        }
        return actual
    }

    var docenteDemo: Usuario {
        guard let actual = usuarioActivo, actual.rol == .docente else {
            return docenteOriginal
        }
        return actual
    }

    // "favoritos" se conserva para las vistas existentes. Se actualiza
    // desde el mapa individual de favoritos del alumno autenticado.
    private var favoritosPorEstudiante: [UUID: Set<UUID>] = [:]

    private struct DatosGuardados: Codable {
        var oportunidades: [Oportunidad]
        var postulaciones: [Postulacion]
        var favoritos: Set<UUID> // Campo LEGADO; siempre corresponde a Alfredo.
        var favoritosPorEstudiante: [UUID: Set<UUID>]? // Nuevo, compatible hacia atrás.
    }

    func establecerUsuarioActivo(_ usuario: Usuario?, usuarios: [Usuario]) {
        directorioUsuarios = Dictionary(
            usuarios.map { ($0.id, $0) },
            uniquingKeysWith: { primero, _ in primero }
        )
        usuarioActivo = usuario
        let idAlumno = usuario?.rol == .estudiante ? usuario?.id : nil
        favoritos = idAlumno.flatMap { favoritosPorEstudiante[$0] } ?? []
    }

    func nombreDeEstudiante(conID id: UUID) -> String {
        if let usuario = directorioUsuarios[id], usuario.rol == .estudiante {
            return usuario.nombre
        }
        if id == alumnoOriginal.id { return alumnoOriginal.nombre }
        return "Estudiante \(id.uuidString.prefix(8))"
    }

    private let archivoURL: URL
    private var almacenamientoBloqueado = false

    init() {
        let directorio = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]

        archivoURL = directorio
            .appendingPathComponent("UACAMPocket", isDirectory: true)
            .appendingPathComponent("datos.json")

        if FileManager.default.fileExists(atPath: archivoURL.path) {
            do {
                let contenido = try Data(contentsOf: archivoURL)
                let datos = try JSONDecoder().decode(
                    DatosGuardados.self,
                    from: contenido
                )
                oportunidades = datos.oportunidades
                postulaciones = datos.postulaciones
                // Migración en memoria: los favoritos anteriores pertenecen
                // a Alfredo, nunca se asignan a otros estudiantes.
                favoritosPorEstudiante = datos.favoritosPorEstudiante ?? [
                    alumnoOriginal.id: datos.favoritos
                ]
                favoritos = favoritosPorEstudiante[alumnoOriginal.id] ?? []
            } catch {
                // Nunca sobrescribimos automáticamente un archivo ilegible.
                almacenamientoBloqueado = true
                errorAlCargar = "No se pudieron cargar los datos: \(error.localizedDescription)"
            }
        } else {
            var ejemplos = Oportunidad.ejemplos
            for indice in ejemplos.indices {
                ejemplos[indice].docenteId = docenteDemo.id
                ejemplos[indice].docenteResponsable = docenteDemo.nombre
            }

            let inicial = DatosGuardados(
                oportunidades: ejemplos,
                postulaciones: [],
                favoritos: [],
                favoritosPorEstudiante: [:]
            )
            do {
                try guardar(inicial)
            } catch {
                oportunidades = ejemplos
                errorAlCargar = "No fue posible guardar los datos iniciales: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Consultas

    func buscarOportunidades(
        texto: String = "",
        tipo: TipoOportunidad? = nil,
        soloDisponibles: Bool = false
    ) -> [Oportunidad] {
        let consulta = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        return oportunidades.filter { oportunidad in
            let coincideTipo = tipo == nil || oportunidad.tipo == tipo
            let coincideDisponibilidad = !soloDisponibles || oportunidad.estaDisponible
            let coincideTexto = consulta.isEmpty ||
                oportunidad.titulo.localizedStandardContains(consulta) ||
                oportunidad.descripcion.localizedStandardContains(consulta) ||
                oportunidad.facultad.localizedStandardContains(consulta)
            return coincideTipo && coincideDisponibilidad && coincideTexto
        }
    }

    func oportunidad(conID id: UUID) -> Oportunidad? {
        oportunidades.first { $0.id == id }
    }

    func postulacionesDe(_ estudiante: Usuario) -> [Postulacion] {
        postulaciones.filter { $0.estudianteId == estudiante.id }
    }

    func postulacionesDeOportunidad(_ oportunidadID: UUID) -> [Postulacion] {
        postulaciones.filter { $0.oportunidadId == oportunidadID }
    }

    func postulacion(
        estudianteID: UUID,
        oportunidadID: UUID
    ) -> Postulacion? {
        postulaciones.first {
            $0.estudianteId == estudianteID &&
            $0.oportunidadId == oportunidadID
        }
    }

    func esFavorita(_ oportunidadID: UUID) -> Bool {
        favoritos.contains(oportunidadID)
    }

    func proyectosDe(_ docente: Usuario) -> [Oportunidad] {
        oportunidades.filter { $0.docenteId == docente.id }
    }

    // MARK: - Favoritos

    @discardableResult
    func alternarFavorito(
        oportunidadID: UUID,
        estudiante: Usuario
    ) throws -> Bool {
        guard estudiante.rol == .estudiante else {
            throw PocketDataServiceError.rolNoAutorizado
        }
        guard oportunidad(conID: oportunidadID) != nil else {
            throw PocketDataServiceError.oportunidadNoEncontrada
        }

        var datos = estadoActual()
        var mapa = datos.favoritosPorEstudiante ?? [:]
        var favoritosAlumno = mapa[estudiante.id] ?? []
        if favoritosAlumno.contains(oportunidadID) {
            favoritosAlumno.remove(oportunidadID)
        } else {
            favoritosAlumno.insert(oportunidadID)
        }
        mapa[estudiante.id] = favoritosAlumno
        datos.favoritosPorEstudiante = mapa
        // Campo anterior se mantiene sincronizado únicamente con Alfredo.
        datos.favoritos = mapa[alumnoOriginal.id] ?? []
        try guardar(datos)
        return favoritosAlumno.contains(oportunidadID)
    }

    // MARK: - Postularse (sin duplicados)

    @discardableResult
    func postular(
        estudiante: Usuario,
        a oportunidadID: UUID,
        mensaje: String? = nil
    ) throws -> Postulacion {
        guard estudiante.rol == .estudiante else {
            throw PocketDataServiceError.rolNoAutorizado
        }
        guard let oportunidad = oportunidad(conID: oportunidadID) else {
            throw PocketDataServiceError.oportunidadNoEncontrada
        }
        guard oportunidad.estaDisponible else {
            throw PocketDataServiceError.convocatoriaNoDisponible
        }
        // Se revisan TODOS los estados, incluso cancelada/rechazada:
        // una pareja estudiante-oportunidad solo puede tener un registro.
        guard postulacion(
            estudianteID: estudiante.id,
            oportunidadID: oportunidadID
        ) == nil else {
            throw PocketDataServiceError.postulacionDuplicada
        }

        let nueva = Postulacion(
            estudianteId: estudiante.id,
            oportunidadId: oportunidadID,
            mensajeEstudiante: mensaje
        )

        var datos = estadoActual()
        datos.postulaciones.append(nueva)
        try guardar(datos)
        return nueva
    }

    // MARK: - Cancelar mi postulación

    func cancelarPostulacion(
        id: UUID,
        estudiante: Usuario
    ) throws {
        guard estudiante.rol == .estudiante else {
            throw PocketDataServiceError.rolNoAutorizado
        }
        var datos = estadoActual()
        guard let indice = datos.postulaciones.firstIndex(where: { $0.id == id }) else {
            throw PocketDataServiceError.postulacionNoEncontrada
        }
        guard datos.postulaciones[indice].estudianteId == estudiante.id else {
            throw PocketDataServiceError.accesoDenegado
        }
        guard datos.postulaciones[indice].puedeCancelarse else {
            throw PocketDataServiceError.estadoNoPermitido
        }
        datos.postulaciones[indice].cancelar()
        try guardar(datos)
    }

    // MARK: - Publicación docente

    func publicarOportunidad(
        _ oportunidad: Oportunidad,
        docente: Usuario
    ) throws {
        guard docente.rol == .docente else {
            throw PocketDataServiceError.rolNoAutorizado
        }
        guard !oportunidad.titulo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !oportunidad.descripcion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              oportunidad.vacantes > 0 else {
            throw PocketDataServiceError.datosInvalidos
        }
        guard self.oportunidad(conID: oportunidad.id) == nil else {
            throw PocketDataServiceError.oportunidadDuplicada
        }

        var nueva = oportunidad
        nueva.docenteId = docente.id
        nueva.docenteResponsable = docente.nombre
        // Una publicación de demostración NO acredita servicio social.
        nueva.acreditacionValidada = false

        var datos = estadoActual()
        datos.oportunidades.append(nueva)
        try guardar(datos)
    }

    func cambiarEstadoDeOportunidad(
        id: UUID,
        a nuevoEstado: EstadoOportunidad,
        docente: Usuario
    ) throws {
        guard docente.rol == .docente else {
            throw PocketDataServiceError.rolNoAutorizado
        }
        var datos = estadoActual()
        guard let indice = datos.oportunidades.firstIndex(where: { $0.id == id }) else {
            throw PocketDataServiceError.oportunidadNoEncontrada
        }
        guard datos.oportunidades[indice].docenteId == docente.id else {
            throw PocketDataServiceError.accesoDenegado
        }
        datos.oportunidades[indice].estado = nuevoEstado
        try guardar(datos)
    }

    // MARK: - Revisión docente de postulaciones

    func cambiarEstadoDePostulacion(
        id: UUID,
        a nuevoEstado: EstadoPostulacion,
        docente: Usuario,
        observaciones: String? = nil
    ) throws {
        guard docente.rol == .docente else {
            throw PocketDataServiceError.rolNoAutorizado
        }

        var datos = estadoActual()
        guard let indice = datos.postulaciones.firstIndex(where: { $0.id == id }) else {
            throw PocketDataServiceError.postulacionNoEncontrada
        }
        let postulacion = datos.postulaciones[indice]
        guard let indiceProyecto = datos.oportunidades.firstIndex(where: {
            $0.id == postulacion.oportunidadId
        }) else {
            throw PocketDataServiceError.oportunidadNoEncontrada
        }
        guard datos.oportunidades[indiceProyecto].docenteId == docente.id else {
            throw PocketDataServiceError.accesoDenegado
        }

        guard postulacion.estaPendiente,
              nuevoEstado == .enRevision ||
              nuevoEstado == .aceptada ||
              nuevoEstado == .rechazada else {
            throw PocketDataServiceError.estadoNoPermitido
        }
        if nuevoEstado == .aceptada {
            guard datos.oportunidades[indiceProyecto].vacantes > 0 else {
                throw PocketDataServiceError.sinVacantes
            }
            datos.oportunidades[indiceProyecto].vacantes -= 1
        }
        datos.postulaciones[indice].actualizarEstado(
            nuevoEstado,
            observaciones: observaciones
        )
        try guardar(datos)
    }

    // MARK: - Almacenamiento

    private func estadoActual() -> DatosGuardados {
        DatosGuardados(
            oportunidades: oportunidades,
            postulaciones: postulaciones,
            favoritos: favoritosPorEstudiante[alumnoOriginal.id] ?? [],
            favoritosPorEstudiante: favoritosPorEstudiante
        )
    }

    private func guardar(_ datos: DatosGuardados) throws {
        guard !almacenamientoBloqueado else {
            throw PocketDataServiceError.almacenamientoBloqueado
        }

        let directorio = archivoURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: directorio,
            withIntermediateDirectories: true,
            attributes: nil
        )

        let codificador = JSONEncoder()
        codificador.outputFormatting = [.prettyPrinted, .sortedKeys]
        let contenido = try codificador.encode(datos)
        try contenido.write(to: archivoURL, options: .atomic)

        // Solo actualizamos la interfaz si la escritura tuvo éxito.
        oportunidades = datos.oportunidades
        postulaciones = datos.postulaciones
        favoritosPorEstudiante = datos.favoritosPorEstudiante ?? [
            alumnoOriginal.id: datos.favoritos
        ]
        let idAlumno = usuarioActivo?.rol == .estudiante ? usuarioActivo?.id : nil
        favoritos = idAlumno.flatMap { favoritosPorEstudiante[$0] } ?? []
    }
}
