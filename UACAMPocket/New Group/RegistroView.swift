//
//  RegistroView.swift
//  UACAMPocket
//
//  Created by Alfredo on 11/11/26.
//

import SwiftUI

// MARK: - Registro local de demostración
// NO existe validación con correo oficial, matrícula ni nómina docente.

struct RegistroView: View {
    @ObservedObject var autenticacion: PocketDemoAuthService
    @Environment(\.dismiss) private var dismiss

    let rolInicial: TipoUsuario
    @State private var rol: TipoUsuario = .estudiante
    @State private var nombre = ""
    @State private var usuarioCorreo = ""
    @State private var carrera = ""
    @State private var contrasena = ""
    @State private var confirmacion = ""
    @State private var mostrarContrasena = false
    @State private var mostrarError = false
    @State private var mensajeError = ""

    init(autenticacion: PocketDemoAuthService, rolInicial: TipoUsuario = .estudiante) {
        self.autenticacion = autenticacion
        self.rolInicial = rolInicial
        self._rol = State(initialValue: rolInicial)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Tipo de cuenta") {
                    Picker("Perfil", selection: $rol) {
                        ForEach(TipoUsuario.allCases) { tipo in
                            Text(tipo.rawValue).tag(tipo)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Datos del usuario") {
                    TextField("Nombre completo", text: $nombre)
                        .textContentType(.name)
                    HStack {
                        TextField("usuario", text: $usuarioCorreo)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                        Text("@uacam.mx")
                            .foregroundStyle(.secondary)
                    }
                    if rol == .estudiante {
                        TextField("Carrera (opcional)", text: $carrera)
                    }
                }

                Section("Contraseña de prueba") {
                    Group {
                        if mostrarContrasena {
                            TextField("Contraseña (mínimo 8 caracteres)", text: $contrasena)
                        } else {
                            SecureField("Contraseña (mínimo 8 caracteres)", text: $contrasena)
                        }
                    }
                    SecureField("Confirmar contraseña", text: $confirmacion)
                    Toggle("Mostrar contraseña", isOn: $mostrarContrasena)
                }

                Section {
                    Button {
                        registrar()
                    } label: {
                        Label("Crear cuenta y entrar", systemImage: "person.crop.circle.badge.checkmark")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                              usuarioCorreo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                              contrasena.isEmpty || confirmacion.isEmpty)
                } footer: {
                    Text("Solo registra una cuenta local de demostración. El dominio @uacam.mx no comprueba la titularidad del correo. No utilices una contraseña real.")
                }
            }
            .navigationTitle("Crear cuenta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
            .alert("No se pudo registrar", isPresented: $mostrarError) {
                Button("Entendido", role: .cancel) { }
            } message: {
                Text(mensajeError)
            }
        }
    }

    private func registrar() {
        guard contrasena == confirmacion else {
            mensajeError = "La confirmación no coincide con la contraseña."
            mostrarError = true
            return
        }
        let usuario = usuarioCorreo
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        let email = usuario.contains("@") ? usuario : usuario + "@uacam.mx"
        do {
            _ = try autenticacion.registrar(
                nombre: nombre,
                correo: email,
                contrasena: contrasena,
                rol: rol,
                carrera: rol == .estudiante ? carrera : nil
            )
            contrasena = ""
            confirmacion = ""
            dismiss()
        } catch {
            mensajeError = error.localizedDescription
            mostrarError = true
        }
    }
}

#Preview("Registro UACAM Pocket") {
    RegistroView(autenticacion: PocketDemoAuthService())
}
