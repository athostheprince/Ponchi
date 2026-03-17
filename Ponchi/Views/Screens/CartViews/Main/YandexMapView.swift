//
//  YandexMapView.swift
//  Ponchi
//
//  Created by mary romanova on 15.01.2026.
//

import SwiftUI

#if canImport(YandexMapsMobile)
import YandexMapsMobile
#endif

#if canImport(YandexMapsMobile)
struct YandexMapView: UIViewRepresentable {
    let latitude: Double
    let longitude: Double

    func makeUIView(context: Context) -> YMKMapView {
        let mapView = YMKMapView(frame: .zero)
        let point = YMKPoint(latitude: latitude, longitude: longitude)

        let camera = YMKCameraPosition(target: point, zoom: 20, azimuth: 0, tilt: 0)
        let animation = YMKAnimation(type: .smooth, duration: 5)
        mapView?.mapWindow.map.move(with: camera, animation: animation, cameraCallback: nil)

        let placemark = mapView?.mapWindow.map.mapObjects.addPlacemark()
        placemark?.geometry = point

        if let image = UIImage(named: "меткаКарты") {
            let style = YMKIconStyle(
                anchor: CGPoint(x: 0.5, y: 1.0) as NSValue,
                rotationType: .none,
                zIndex: 1,
                flat: true,
                visible: true,
                scale: 0.5,
                tappableArea: nil)
            
            placemark?.setIconWith(image, style: style)
        }

        context.coordinator.placemark = placemark
        return mapView!
    }

    func updateUIView(_ uiView: YMKMapView, context: Context) {
        if let placemark = context.coordinator.placemark {
            placemark.geometry = YMKPoint(latitude: latitude, longitude: longitude)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var placemark: YMKPlacemarkMapObject?
    }
}
#else
struct YandexMapView: View {
    let latitude: Double
    let longitude: Double

    var body: some View {
        ZStack {
            Color.biege.opacity(0.5)
            VStack(spacing: 6) {
                Image(systemName: "map")
                    .font(.title2)
                Text("Карта недоступна в Debug")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
    }
}
#endif
