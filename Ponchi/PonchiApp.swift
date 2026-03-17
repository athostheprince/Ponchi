//
//  PonchiApp.swift
//  Ponchi
//
//  Created by mary romanova on 03.09.2024.
//

import SwiftUI
import UIKit
#if canImport(YandexMapsMobile)
import YandexMapsMobile
#endif

@main
struct PonchiApp: App {
    let ponchiViewModel: PonchiViewModel
    var cart = Cart()
    var order = OrderViewModel()
    var user = UserViewModel()

    @State private var showLaunchScreen = true

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    private var isRunningPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" ||
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PLAYGROUNDS"] == "1"
    }

    private static func makeMenuUseCase() -> LoadMenuUseCase {
        let url = URL(string: "https://storage.yandexcloud.net/ponchibucket/Ponchi.json")!
        let remote = MenuRemoteDataSource(menuURL: url)
        let local = MenuLocalDataSource()
        let repo = DefaultMenuRepository(remote: remote, local: local)

        return LoadMenuUseCase(repo: repo)
    }

    init() {
        self.ponchiViewModel = PonchiViewModel(loadMenuUseCase: Self.makeMenuUseCase())
        if !isRunningPreviews {
            UITraitCollection.current = UITraitCollection(userInterfaceStyle: .light)
        }
    }

    var body: some Scene {
        WindowGroup {
            if isRunningPreviews {
                PreviewHostView()
            } else {
                ZStack {
                    if showLaunchScreen {

                        LaunchScreenView()

                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {

                                    let generator = UIImpactFeedbackGenerator(style: .soft)
                                    generator.prepare()
                                    generator.impactOccurred()

                                    withAnimation {
                                        showLaunchScreen.toggle()
                                    }
                                }
                            }
                    } else {
                        PonchiCustomTabBar()
                            .environmentObject(cart)
                            .environmentObject(order)
                            .environmentObject(ponchiViewModel)
                            .environmentObject(user)
                            .preferredColorScheme(.light)
                    }
                }
                .onAppear {
                    Task { await ponchiViewModel.loadPonchi() }
                }
            }

        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    private var isRunningPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" ||
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PLAYGROUNDS"] == "1"
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        if isRunningPreviews {
            return true
        }
#if canImport(YandexMapsMobile)
        YMKMapKit.setApiKey("73c729c4-32c8-4eb6-8825-1aa50c160ecc")
#endif
        return true
    }
}

private struct PreviewHostView: View {
    var body: some View {
        Color.clear
    }
}
