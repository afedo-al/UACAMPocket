//
//  CampusView.swift
//  UACAMPocket
//
//  Created by Alfredo on 10/11/26.
//


import SwiftUI
import MapKit

// MARK: - SEDES UACAM
// Ubicaciones institucionales verificadas con la pagina de campus UACAM.
// Los marcadores se resuelven mediante Apple Maps al abrir la pantalla.
// No requiere permiso de localizacion ni datos del estudiante.

private struct SedeUACAM: Identifiable {
    let id: String
    let nombre: String
    let subtitulo: String
    let direccion: String
    let busqueda: String
    let icono: String
}

private struct MarcadorUACAM: Identifiable {
    let id: String
    let nombre: String
    let coordenada: CLLocationCoordinate2D
}

struct CampusView: View {

    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

    // Centro aproximado de San Francisco de Campeche, no de un edificio.
    @State private var posicionMapa: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 19.84, longitude: -90.53),
            span: MKCoordinateSpan(latitudeDelta: 0.19, longitudeDelta: 0.19)
        )
    )

    @State private var marcadores: [MarcadorUACAM] = []
    @State private var cargandoUbicaciones = false
    @State private var consultaTerminada = false
    @State private var sedeSeleccionada = "ingenieria"

    // Direcciones publicadas por la UACAM. Campus II e I son sedes,
    // no posiciones exactas de cada edificio dentro del campus.
    private let sedes: [SedeUACAM] = [
        SedeUACAM(
            id: "ingenieria",
            nombre: "Campus V · Facultad de Ingeniería",
            subtitulo: "Ingeniería en Sistemas, Software y otras especialidades",
            direccion: "Av. Ing. Humberto Lanz Cárdenas, Ex Hacienda Kalá, C.P. 24085, San Francisco de Campeche, Campeche, México",
            busqueda: "Facultad de Ingeniería Universidad Autónoma de Campeche Campus V, Ex Hacienda Kalá, Campeche",
            icono: "laptopcomputer"
        ),
        SedeUACAM(
            id: "principal",
            nombre: "Campus I · Ciudad Universitaria",
            subtitulo: "Sede principal y diversas facultades",
            direccion: "Av. Agustín Melgar s/n, Col. Buenavista, C.P. 24039, San Francisco de Campeche, Campeche, México",
            busqueda: "Universidad Autónoma de Campeche, Avenida Agustín Melgar, Buenavista, Campeche",
            icono: "building.columns"
        ),
        SedeUACAM(
            id: "biblioteca",
            nombre: "Biblioteca Central · José Ortiz Ávila",
            subtitulo: "Consulta y espacios de estudio en Campus I",
            direccion: "Av. Agustín Melgar, Col. Buenavista, San Francisco de Campeche, Campeche, México",
            busqueda: "Biblioteca Central General José Ortiz Ávila UACAM, Campeche",
            icono: "books.vertical"
        ),
        SedeUACAM(
            id: "salud",
            nombre: "Campus II · Salud",
            subtitulo: "Facultades de Medicina y Enfermería",
            direccion: "Av. Patricio Trueba y de Regil s/n, San Francisco de Campeche, Campeche, México",
            busqueda: "Facultad de Medicina Universidad Autónoma de Campeche, Avenida Patricio Trueba y de Regil, Campeche",
            icono: "cross.case"
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.section) {
                    encabezado
                    seccionMapa
                    seccionSedes
                    avisoUbicaciones
                }
                .padding(.horizontal, AppTheme.Spacing.screenHorizontal)
                .padding(.top, AppTheme.Spacing.md)
                .padding(.bottom, AppTheme.Spacing.xxxl)
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())
            .navigationTitle("Campus")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }

    // MARK: - Encabezado

    private var encabezado: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Label("UBICACIONES UNIVERSITARIAS", systemImage: "mappin.and.ellipse")
                .font(AppTheme.Typography.captionBold)
                .foregroundStyle(.white.opacity(0.85))

            Text("Encuentra tu campus")
                .font(AppTheme.Typography.title2)
                .foregroundStyle(.white)

            Text("Consulta las sedes de la UACAM en Campeche y abre indicaciones en Mapas.")
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

    // MARK: - Mapa

    private var seccionMapa: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PocketSectionHeader(
                title: "Mapa de campus",
                subtitle: "Selecciona una sede para centrar el mapa."
            )

            ZStack(alignment: .bottom) {
                Map(position: $posicionMapa) {
                    ForEach(marcadores) { marcador in
                        Marker(marcador.nombre, coordinate: marcador.coordenada)
                            .tint(AppTheme.Colors.blue)
                    }
                }
                .mapStyle(.standard(elevation: .flat))
                .frame(height: 285)
                .clipShape(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                )

                if cargandoUbicaciones {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        ProgressView()
                        Text("Buscando sedes en Apple Maps...")
                            .font(AppTheme.Typography.caption)
                    }
                    .padding(AppTheme.Spacing.sm)
                    .background(.regularMaterial, in: Capsule())
                    .padding(.bottom, AppTheme.Spacing.sm)
                }
            }
            .task {
                await obtenerMarcadores()
            }

            if consultaTerminada && marcadores.isEmpty {
                Label(
                    "No se pudieron ubicar los marcadores. Puedes usar «Cómo llegar» para abrir cada sede en Mapas.",
                    systemImage: "wifi.exclamationmark"
                )
                .font(AppTheme.Typography.footnote)
                .foregroundStyle(AppTheme.Colors.secondaryText)
            }

            HStack {
                Text("Las posiciones dependen de los resultados de Apple Maps.")
                    .font(AppTheme.Typography.small)
                    .foregroundStyle(AppTheme.Colors.secondaryText)

                Spacer(minLength: 8)

                Button("Ver todas") {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        posicionMapa = .automatic
                    }
                }
                .font(AppTheme.Typography.captionBold)
                .disabled(marcadores.isEmpty)
            }
        }
    }

    // MARK: - Tarjetas de sedes

    private var seccionSedes: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PocketSectionHeader(
                title: "Sedes y servicios",
                subtitle: "Direcciones institucionales de referencia"
            )

            ForEach(sedes) { sede in
                tarjetaSede(sede)
            }
        }
    }

    private func tarjetaSede(_ sede: SedeUACAM) -> some View {
        PocketCard(showBorder: sedeSeleccionada == sede.id) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                    Image(systemName: sede.icono)
                        .font(.title3)
                        .foregroundStyle(AppTheme.Colors.blue)
                        .frame(width: 44, height: 44)
                        .background(
                            AppTheme.Colors.blue.opacity(0.08),
                            in: RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                        )

                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text(sede.nombre)
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.Colors.primaryText)

                        Text(sede.subtitulo)
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                    }

                    Spacer(minLength: 0)
                }

                Label(sede.direccion, systemImage: "mappin.circle")
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: AppTheme.Spacing.sm) {
                    Button {
                        enfocar(sede)
                    } label: {
                        Label("Ver en mapa", systemImage: "map")
                            .font(AppTheme.Typography.captionBold)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .foregroundStyle(AppTheme.Colors.blue)
                            .background(
                                AppTheme.Colors.secondarySurface,
                                in: RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                            )
                    }
                    .buttonStyle(.plain)

                    Button {
                        abrirIndicaciones(sede)
                    } label: {
                        Label("Cómo llegar", systemImage: "arrow.triangle.turn.up.right.diamond")
                            .font(AppTheme.Typography.captionBold)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .foregroundStyle(.white)
                            .background(
                                AppTheme.Colors.blue,
                                in: RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Aviso

    private var avisoUbicaciones: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Label(
                "El mapa es una referencia de orientación. Verifica accesos y edificios con tu facultad; esta función no ofrece rutas internas ni rastrea tu ubicación.",
                systemImage: "info.circle"
            )
            .font(AppTheme.Typography.small)
            .foregroundStyle(AppTheme.Colors.secondaryText)

            PocketPrimaryButton(
                title: "Consultar campus en UACAM",
                systemImage: "arrow.up.right.square"
            ) {
                if let url = URL(string: "https://uacam.mx/paginas/ver/357") {
                    openURL(url)
                }
            }
        }
    }

    // MARK: - Acciones

    private func enfocar(_ sede: SedeUACAM) {
        sedeSeleccionada = sede.id
        guard let marcador = marcadores.first(where: { $0.id == sede.id }) else {
            // Si Apple Maps no pudo resolver esta sede, se abre su búsqueda externa.
            abrirBusquedaEnMapas(sede)
            return
        }

        withAnimation(.easeInOut(duration: 0.25)) {
            posicionMapa = .region(
                MKCoordinateRegion(
                    center: marcador.coordenada,
                    span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
                )
            )
        }
    }

    private func abrirIndicaciones(_ sede: SedeUACAM) {
        var componentes = URLComponents(string: "https://maps.apple.com/")
        componentes?.queryItems = [
            URLQueryItem(name: "daddr", value: "\(sede.nombre), \(sede.direccion)")
        ]
        if let url = componentes?.url {
            openURL(url)
        }
    }

    private func abrirBusquedaEnMapas(_ sede: SedeUACAM) {
        var componentes = URLComponents(string: "https://maps.apple.com/")
        componentes?.queryItems = [
            URLQueryItem(name: "q", value: sede.busqueda)
        ]
        if let url = componentes?.url {
            openURL(url)
        }
    }

    // MARK: - Ubicaciones obtenidas con MapKit

    @MainActor
    private func obtenerMarcadores() async {
        guard !consultaTerminada && !cargandoUbicaciones else { return }

        cargandoUbicaciones = true
        defer {
            cargandoUbicaciones = false
            consultaTerminada = true
        }

        var nuevos: [MarcadorUACAM] = []
        for sede in sedes {
            if Task.isCancelled { return }
            let solicitud = MKLocalSearch.Request()
            solicitud.naturalLanguageQuery = sede.busqueda

            do {
                let respuesta = try await MKLocalSearch(request: solicitud).start()
                if let encontrado = respuesta.mapItems.first {
                    nuevos.append(
                        MarcadorUACAM(
                            id: sede.id,
                            nombre: sede.nombre,
                            coordenada: encontrado.placemark.coordinate
                        )
                    )
                }
            } catch {
                // No inventamos coordenadas cuando la búsqueda falla.
                // Los enlaces para abrir Apple Maps siguen disponibles.
            }
        }

        marcadores = nuevos
        if !nuevos.isEmpty {
            posicionMapa = .automatic
        }
    }
}

// MARK: - VISTA PREVIA

#Preview("Campus - UACAM Pocket") {
    CampusView()
}
