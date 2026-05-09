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

private enum PreviewRuntime {
    static var isActive: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" ||
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PLAYGROUNDS"] == "1"
    }
}

@main
struct PonchiApp: App {
    private enum StartupPhase {
        case launch
        case bootstrapping
        case ready
    }

    private static let previewMenuURL = URL(string: "https://riknabdpryhyoyrgjkgk.supabase.co/storage/v1/object/public/menu/Ponchi.json")!
    private static let previewAuthBaseURL = URL(string: "https://d5dv0tsfdqg45rj2b9i8.4b4k4pg5.apigw.yandexcloud.net/v1")!
    private let launchDelay: TimeInterval = 1.5

    let ponchiViewModel: PonchiViewModel
    let cart = Cart()
    let order = OrderViewModel()
    @StateObject private var user: UserViewModel

    @State private var startupPhase: StartupPhase = .launch
    @State private var didStartBootstrap = false

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    private var isRunningPreviews: Bool {
        PreviewRuntime.isActive
    }

    private static func makeNetworkService() -> NetworkService {
        NetworkService()
    }

    private static func makeMenuUseCase(network: NetworkService, isPreview: Bool) -> LoadMenuUseCase {
        let url = isPreview ? previewMenuURL : AppConfig.menuURL
        let remote = MenuRemoteDataSource(menuURL: url, network: network)
        let local = MenuLocalDataSource()
        let repo = DefaultMenuRepository(remote: remote, local: local)

        return LoadMenuUseCase(repo: repo)
    }

    private static func makeUserViewModel(network: NetworkService, isPreview: Bool) -> UserViewModel {
        let authBaseURL = isPreview ? previewAuthBaseURL : AppConfig.apiBaseURL
        let authBackend: AppConfig.AuthBackend = isPreview ? .yandex : AppConfig.authBackend
        let authService = AuthService(network: network, baseURL: authBaseURL, backend: authBackend)
        let keychain = KeychainService(service: isPreview ? "Ponchi.preview" : Bundle.main.bundleIdentifier ?? "Ponchi")
        let sessionManager = SessionManager(keychain: keychain)

        return UserViewModel(
            authService: authService,
            sessionManager: sessionManager
        )
    }

    init() {
        let isPreview = PreviewRuntime.isActive
        let network = Self.makeNetworkService()

        self.ponchiViewModel = PonchiViewModel(
            loadMenuUseCase: Self.makeMenuUseCase(network: network, isPreview: isPreview)
        )
        _user = StateObject(
            wrappedValue: Self.makeUserViewModel(network: network, isPreview: isPreview)
        )

        if !isRunningPreviews {
            UITraitCollection.current = UITraitCollection(userInterfaceStyle: .light)
        }
    }

    var body: some Scene {
        WindowGroup {
            rootContent
        }
    }

    @ViewBuilder
    private var rootContent: some View {
        if isRunningPreviews {
            PreviewHostView()
        } else {
            ZStack {
                switch startupPhase {
                case .launch:
                    launchScreen
                case .bootstrapping:
                    bootstrapScreen
                case .ready:
                    mainAppScreen
                }
            }
        }
    }

    private var launchScreen: some View {
        LaunchScreenView()
            .onAppear {
                runLaunchSequence()
            }
    }

    private var bootstrapScreen: some View {
        SessionRestoreLoadingView()
            .task {
                await startBootstrapIfNeeded()
            }
    }

    private var mainAppScreen: some View {
        PonchiCustomTabBar()
            .environmentObject(cart)
            .environmentObject(order)
            .environmentObject(ponchiViewModel)
            .environmentObject(user)
            .preferredColorScheme(.light)
    }

    private func runLaunchSequence() {
        guard startupPhase == .launch else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + launchDelay) {
            guard startupPhase == .launch else { return }

            triggerLaunchHaptic()

            withAnimation {
                startupPhase = .bootstrapping
            }
        }
    }

    private func triggerLaunchHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }

    @MainActor
    private func startBootstrapIfNeeded() async {
        guard !didStartBootstrap else { return }
        didStartBootstrap = true

        async let menuLoad: Void = ponchiViewModel.loadPonchi()
        async let sessionRestore: Void = user.restoreSession()
        _ = await (menuLoad, sessionRestore)

        withAnimation {
            startupPhase = .ready
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    private var isRunningPreviews: Bool {
        PreviewRuntime.isActive
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
