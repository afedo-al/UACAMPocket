//
//  PocketDemoAuthService.swift
//  UACAMPocket
//
//  Created by Alfredo on 10/11/26.
//


import Foundation
import Combine
import Security

// MARK: - Cuentas académicas locales (SOLO DEMOSTRACIÓN)
// Los correos @uacam.mx de prueba son ejemplos inventados; NO están
// verificados, no reciben correo y no son cuentas institucionales reales.
// No introduzcas contraseñas verdaderas de la universidad.

@MainActor
final class PocketDemoAuthService: ObservableObject {

    enum ErrorCuenta: LocalizedError {
        case credencialesIncorrectas
        case nombreInvalido
        case correoInvalido
        case correoDuplicado
        case contrasenaInvalida
        case almacenamientoBloqueado
        case registroNoGuardado
        case llaveroNoDisponible

        var errorDescription: String? {
            switch self {
            case .credencialesIncorrectas:
                return "El correo, la contraseña o el tipo de usuario no corresponden a una cuenta local."
            case .nombreInvalido:
                return "Escribe un nombre de entre 3 y 100 caracteres."
            case .correoInvalido:
                return "Para esta demostración se requiere un correo con formato nombre@uacam.mx."
            case .correoDuplicado:
                return "Ese correo de demostración ya está registrado en este dispositivo."
            case .contrasenaInvalida:
                return "La contraseña de demostración debe tener al menos 8 caracteres."
            case .almacenamientoBloqueado:
                return "No se pueden leer las cuentas guardadas. No se sobrescribirán."
            case .registroNoGuardado:
                return "No fue posible guardar la cuenta local."
            case .llaveroNoDisponible:
                return "No fue posible acceder al llavero del dispositivo para guardar o comprobar la contraseña."
            }
        }
    }

    struct CuentaDemo: Identifiable {
        let usuario: Usuario
        let contrasena: String
        var id: UUID { usuario.id }
    }

    // Los UUID de Alfredo y José REUTILIZAN los identificadores de la
    // versión anterior: se conservan postulaciones y proyectos previos.
    static let cuentasDemo: [CuentaDemo] = [
        CuentaDemo(
            usuario: Usuario(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
                nombre: "Alfredo J Cruz Miss",
                correo: "demo.alfredo.cruz@uacam.mx",
                rol: .estudiante,
                carrera: "Ingeniería en Tecnología de Software",
                facultad: "Facultad de Ingeniería"
            ),
            contrasena: "Alumno123!"
        ),
        CuentaDemo(
            usuario: Usuario(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000002")!,
                nombre: "Rafael E Inurreta del Valle",
                correo: "demo.rafael.inurreta@uacam.mx",
                rol: .estudiante,
                facultad: "Facultad de Ingeniería"
            ),
            contrasena: "Alumno123!"
        ),
        CuentaDemo(
            usuario: Usuario(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000003")!,
                nombre: "Kevin J Ruiz Tillit",
                correo: "demo.kevin.ruiz@uacam.mx",
                rol: .estudiante,
                facultad: "Facultad de Ingeniería"
            ),
            contrasena: "Alumno123!"
        ),
        CuentaDemo(
            usuario: Usuario(
                id: UUID(uuidString: "20000000-0000-0000-0000-000000000001")!,
                nombre: "Jose C Aguilar Canepa",
                correo: "demo.jose.aguilar@uacam.mx",
                rol: .docente,
                facultad: "Facultad de Ingeniería"
            ),
            contrasena: "Docente123!"
        ),
        CuentaDemo(
            usuario: Usuario(
                id: UUID(uuidString: "20000000-0000-0000-0000-000000000002")!,
                nombre: "Joel C Flores Escalante",
                correo: "demo.joel.flores@uacam.mx",
                rol: .docente,
                facultad: "Facultad de Ingeniería"
            ),
            contrasena: "Docente123!"
        )
    ]

    static let claveSesion = "uacampocket.demo.sesion.v1" // Clave antigua preservada
    static let claveRegistros = "uacampocket.demo.usuariosRegistrados.v1"
    private static let servicioLlavero = "mx.uacam.pocket.demo.registros.locales"

    private struct SesionLocal: Codable {
        let version: Int
        let correo: String
        let rol: TipoUsuario
        let usuarioID: UUID?
    }

    @Published private(set) var usuarioAutenticado: Usuario?
    @Published private(set) var usuariosRegistrados: [Usuario] = []
    @Published private(set) var errorDeCarga: String?

    private let defaults: UserDefaults
    private var almacenamientoBloqueado = false

    var rolAutenticado: TipoUsuario? { usuarioAutenticado?.rol }
    var correoAutenticado: String? { usuarioAutenticado?.correo }
    var haIniciadoSesion: Bool { usuarioAutenticado != nil }
    var todosLosUsuarios: [Usuario] {
        Self.cuentasDemo.map(\.usuario) + usuariosRegistrados
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        cargarRegistrados()
        restaurarSesion()
    }

    // MARK: - Cuentas disponibles en la pantalla de inicio

    func cuentasDePrueba(rol: TipoUsuario) -> [CuentaDemo] {
        Self.cuentasDemo.filter { $0.usuario.rol == rol }
    }

    // MARK: - Inicio de sesión

    func iniciarSesion(
        correo: String,
        contrasena: String,
        rol: TipoUsuario,
        recordarSesion: Bool = true
    ) throws {
        let email = Self.normalizar(correo)

        if let cuenta = Self.cuentasDemo.first(where: {
            $0.usuario.correo == email && $0.usuario.rol == rol
        }) {
            guard cuenta.contrasena == contrasena else {
                throw ErrorCuenta.credencialesIncorrectas
            }
            try establecerSesion(cuenta.usuario, recordar: recordarSesion)
            return
        }

        guard let usuario = usuariosRegistrados.first(where: {
            $0.correo == email && $0.rol == rol
        }) else {
            throw ErrorCuenta.credencialesIncorrectas
        }

        let guardada = try leerContrasenaDelLlavero(correo: email)
        guard guardada == contrasena else {
            throw ErrorCuenta.credencialesIncorrectas
        }
        try establecerSesion(usuario, recordar: recordarSesion)
    }

    // MARK: - Registro local; NO acredita pertenencia a la UACAM

    @discardableResult
    func registrar(
        nombre: String,
        correo: String,
        contrasena: String,
        rol: TipoUsuario,
        carrera: String? = nil,
        recordarSesion: Bool = true
    ) throws -> Usuario {
        guard !almacenamientoBloqueado else {
            throw ErrorCuenta.almacenamientoBloqueado
        }
        let nombreLimpio = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = Self.normalizar(correo)
        guard (3...100).contains(nombreLimpio.count) else {
            throw ErrorCuenta.nombreInvalido
        }
        guard Self.correoValido(email) else {
            throw ErrorCuenta.correoInvalido
        }
        guard !todosLosUsuarios.contains(where: { $0.correo == email }) else {
            throw ErrorCuenta.correoDuplicado
        }
        guard contrasena.count >= 8 && contrasena.count <= 128 else {
            throw ErrorCuenta.contrasenaInvalida
        }

        let nuevo = Usuario(
            nombre: nombreLimpio,
            correo: email,
            rol: rol,
            carrera: rol == .estudiante
                ? carrera?.trimmingCharacters(in: .whitespacesAndNewlines)
                : nil,
            facultad: "Facultad de Ingeniería"
        )
        let nuevos = usuariosRegistrados + [nuevo]
        let datos = try JSONEncoder().encode(nuevos)

        // Las contraseñas de usuarios registrados van al Keychain, NUNCA
        // a UserDefaults ni al JSON que almacena el perfil.
        try guardarContrasenaEnLlavero(contrasena, correo: email)
        defaults.set(datos, forKey: Self.claveRegistros)
        guard defaults.data(forKey: Self.claveRegistros) == datos else {
            borrarContrasenaDelLlavero(correo: email)
            throw ErrorCuenta.registroNoGuardado
        }
        usuariosRegistrados = nuevos
        try establecerSesion(nuevo, recordar: recordarSesion)
        return nuevo
    }

    // MARK: - Cerrar sesión sin borrar proyectos, tareas ni favoritos

    func cerrarSesion() {
        defaults.removeObject(forKey: Self.claveSesion)
        usuarioAutenticado = nil
    }

    // MARK: - Persistencia de cuentas locales

    private func cargarRegistrados() {
        guard defaults.object(forKey: Self.claveRegistros) != nil else { return }
        guard let datos = defaults.data(forKey: Self.claveRegistros),
              let usuarios = try? JSONDecoder().decode([Usuario].self, from: datos) else {
            almacenamientoBloqueado = true
            errorDeCarga = "No se pudieron leer las cuentas locales; su almacenamiento se mantuvo intacto."
            return
        }
        usuariosRegistrados = usuarios
    }

    private func restaurarSesion() {
        guard let datos = defaults.data(forKey: Self.claveSesion),
              let sesion = try? JSONDecoder().decode(SesionLocal.self, from: datos),
              sesion.version == 1 || sesion.version == 2 else { return }

        // Migración de la sesión anterior (2 cuentas @ejemplo.com).
        // Conserva el mismo UUID y sustituye el alias por el nuevo correo.
        let correo = Self.normalizar(sesion.correo)
        let migrado: Usuario?
        if sesion.version == 1 && correo == "estudiante@ejemplo.com" && sesion.rol == .estudiante {
            migrado = Self.cuentasDemo[0].usuario
        } else if sesion.version == 1 && correo == "docente@ejemplo.com" && sesion.rol == .docente {
            migrado = Self.cuentasDemo[3].usuario
        } else {
            migrado = todosLosUsuarios.first {
                $0.correo == correo && $0.rol == sesion.rol &&
                (sesion.usuarioID == nil || $0.id == sesion.usuarioID)
            }
        }
        guard let usuario = migrado else { return }
        usuarioAutenticado = usuario
        if sesion.version == 1 {
            try? establecerSesion(usuario, recordar: true)
        }
    }

    private func establecerSesion(_ usuario: Usuario, recordar: Bool) throws {
        if recordar {
            let sesion = SesionLocal(
                version: 2,
                correo: usuario.correo,
                rol: usuario.rol,
                usuarioID: usuario.id
            )
            let datos = try JSONEncoder().encode(sesion)
            defaults.set(datos, forKey: Self.claveSesion)
            guard defaults.data(forKey: Self.claveSesion) == datos else {
                throw ErrorCuenta.registroNoGuardado
            }
        } else {
            defaults.removeObject(forKey: Self.claveSesion)
        }
        usuarioAutenticado = usuario
    }

    private static func normalizar(_ correo: String) -> String {
        correo.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static func correoValido(_ correo: String) -> Bool {
        let partes = correo.split(separator: "@", omittingEmptySubsequences: false)
        guard partes.count == 2, partes[1] == "uacam.mx" else { return false }
        let usuario = String(partes[0])
        guard !usuario.isEmpty, usuario.count <= 64,
              !usuario.hasPrefix("."), !usuario.hasSuffix("."),
              !usuario.contains("..") else { return false }
        let caracteres = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789._-")
        return usuario.unicodeScalars.allSatisfy { caracteres.contains($0) }
    }

    // MARK: - Keychain local para contraseñas registradas

    private func guardarContrasenaEnLlavero(_ clave: String, correo: String) throws {
        let consulta: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Self.servicioLlavero,
            kSecAttrAccount as String: correo,
            kSecValueData as String: Data(clave.utf8),
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        let estado = SecItemAdd(consulta as CFDictionary, nil)
        guard estado == errSecSuccess else { throw ErrorCuenta.llaveroNoDisponible }
    }

    private func leerContrasenaDelLlavero(correo: String) throws -> String? {
        let consulta: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Self.servicioLlavero,
            kSecAttrAccount as String: correo,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var resultado: CFTypeRef?
        let estado = SecItemCopyMatching(consulta as CFDictionary, &resultado)
        if estado == errSecItemNotFound { return nil }
        guard estado == errSecSuccess, let datos = resultado as? Data else {
            throw ErrorCuenta.llaveroNoDisponible
        }
        return String(data: datos, encoding: .utf8)
    }

    private func borrarContrasenaDelLlavero(correo: String) {
        let consulta: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Self.servicioLlavero,
            kSecAttrAccount as String: correo
        ]
        _ = SecItemDelete(consulta as CFDictionary)
    }
}
