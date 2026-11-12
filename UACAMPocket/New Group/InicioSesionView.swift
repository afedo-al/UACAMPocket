//
//  InicioSesionView.swift
//  UACAMPocket
//
//  Created by Alfredo on 10/11/26.
//


import SwiftUI

// MARK: - Inicio de sesión local de demostración
// Los usuarios predefinidos tienen correos ficticios @uacam.mx.
// NO se verifica la identidad real ni se usan servicios institucionales.

struct InicioSesionView: View {
    @ObservedObject var autenticacion: PocketDemoAuthService

    @State private var rolSeleccionado: TipoUsuario = .estudiante
    @State private var correo = ""
    @State private var contrasena = ""
    @State private var mostrarClave = false
    @State private var recordarSesion = true
    @State private var mostrarRegistro = false
    @State private var mostrarError = false
    @State private var mensajeError = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                encabezado
                formulario
                selectorDeCuentas
                advertencia
            }
            .padding(.horizontal, AppTheme.Spacing.screenHorizontal)
            .padding(.top, AppTheme.Spacing.lg)
            .padding(.bottom, AppTheme.Spacing.xxxl)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .sheet(isPresented: $mostrarRegistro) {
            RegistroView(autenticacion: autenticacion, rolInicial: rolSeleccionado)
        }
        .alert("No fue posible iniciar sesión", isPresented: $mostrarError) {
            Button("Entendido", role: .cancel) { }
        } message: {
            Text(mensajeError)
        }
    }

    private var encabezado: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Label("UACAM POCKET · DEMOSTRACIÓN", systemImage: "graduationcap.fill")
                .font(AppTheme.Typography.captionBold)
                .foregroundStyle(.white.opacity(0.85))
            Text("Tu universidad, siempre contigo.")
                .font(AppTheme.Typography.title2)
                .foregroundStyle(.white)
            Text("Entra con una cuenta de prueba o regístrate localmente.")
                .font(AppTheme.Typography.footnote)
                .foregroundStyle(.white.opacity(0.83))
        }
        .padding(AppTheme.Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            AppTheme.Gradients.header,
            in: RoundedRectangle(cornerRadius: AppTheme.Radius.extraLarge)
        )
    }

    private var formulario: some View {
        PocketCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                Text("Iniciar sesión")
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(AppTheme.Colors.primaryText)

                HStack(spacing: AppTheme.Spacing.sm) {
                    botonRol(.estudiante, "Estudiante", "graduationcap.fill")
                    botonRol(.docente, "Docente", "person.crop.rectangle.stack.fill")
                }

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text("Correo @uacam.mx de demostración")
                        .font(AppTheme.Typography.captionBold)
                    TextField("demo.usuario@uacam.mx", text: $correo)
                        .keyboardType(.emailAddress)
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(AppTheme.Spacing.md)
                        .background(
                            AppTheme.Colors.background,
                            in: RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                        )
                }

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text("Contraseña")
                        .font(AppTheme.Typography.captionBold)
                    HStack {
                        Group {
                            if mostrarClave {
                                TextField("Contraseña", text: $contrasena)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            } else {
                                SecureField("Contraseña", text: $contrasena)
                                    .textContentType(.password)
                            }
                        }
                        Button {
                            mostrarClave.toggle()
                        } label: {
                            Image(systemName: mostrarClave ? "eye.slash" : "eye")
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(mostrarClave ? "Ocultar contraseña" : "Mostrar contraseña")
                    }
                    .padding(.leading, AppTheme.Spacing.md)
                    .padding(.trailing, AppTheme.Spacing.xxs)
                    .background(
                        AppTheme.Colors.background,
                        in: RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                    )
                }

                Toggle("Recordar sesión", isOn: $recordarSesion)
                    .font(AppTheme.Typography.footnote)
                    .tint(AppTheme.Colors.blue)

                PocketPrimaryButton(
                    title: "Iniciar sesión",
                    systemImage: "arrow.right.circle.fill",
                    isDisabled: correo.isEmpty || contrasena.isEmpty
                ) {
                    iniciarSesion()
                }

                Button {
                    mostrarRegistro = true
                } label: {
                    Label("Crear cuenta de demostración", systemImage: "person.crop.circle.badge.plus")
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundStyle(AppTheme.Colors.blue)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var selectorDeCuentas: some View {
        PocketCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text("Cuentas de prueba: \(rolSeleccionado.rawValue.lowercased())")
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                Text("Toca una cuenta para rellenar sus credenciales ficticias.")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)

                ForEach(autenticacion.cuentasDePrueba(rol: rolSeleccionado)) { cuenta in
                    Button {
                        correo = cuenta.usuario.correo
                        contrasena = cuenta.contrasena
                    } label: {
                        HStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "person.crop.circle")
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(cuenta.usuario.nombre)
                                    .font(AppTheme.Typography.bodyMedium)
                                    .foregroundStyle(AppTheme.Colors.primaryText)
                                Text(cuenta.usuario.correo)
                                    .font(AppTheme.Typography.small)
                                    .foregroundStyle(AppTheme.Colors.secondaryText)
                            }
                            Spacer(minLength: 2)
                            Image(systemName: "arrow.up.left.circle")
                        }
                        .foregroundStyle(AppTheme.Colors.blue)
                        .contentShape(Rectangle())
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    if cuenta.id != autenticacion.cuentasDePrueba(rol: rolSeleccionado).last?.id {
                        Divider()
                    }
                }

                Text("Contraseña común de prueba: \(rolSeleccionado == .estudiante ? "Alumno123!" : "Docente123!")")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
        }
    }

    private func botonRol(_ rol: TipoUsuario, _ nombre: String, _ simbolo: String) -> some View {
        let seleccionado = rol == rolSeleccionado
        return Button {
            rolSeleccionado = rol
            correo = ""
            contrasena = ""
        } label: {
            VStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: simbolo).font(.title3)
                Text(nombre).font(AppTheme.Typography.captionBold)
            }
            .foregroundStyle(seleccionado ? Color.white : AppTheme.Colors.primaryText)
            .frame(maxWidth: .infinity, minHeight: 70)
            .background(
                seleccionado ? AppTheme.Colors.blue : AppTheme.Colors.background,
                in: RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
            )
        }
        .buttonStyle(.plain)
    }

    private var advertencia: some View {
        Label(
            "Registro local de prueba. Usar @uacam.mx no verifica que seas alumno o docente. No introduzcas credenciales institucionales reales.",
            systemImage: "info.circle"
        )
        .font(AppTheme.Typography.small)
        .foregroundStyle(AppTheme.Colors.secondaryText)
    }

    private func iniciarSesion() {
        do {
            try autenticacion.iniciarSesion(
                correo: correo,
                contrasena: contrasena,
                rol: rolSeleccionado,
                recordarSesion: recordarSesion
            )
            contrasena = ""
        } catch {
            mensajeError = error.localizedDescription
            mostrarError = true
        }
    }
}

#Preview("Inicio de sesión") {
    InicioSesionView(autenticacion: PocketDemoAuthService())
}
