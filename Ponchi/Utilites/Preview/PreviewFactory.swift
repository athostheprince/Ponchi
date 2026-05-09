//
//  PreviewFactory.swift
//  Ponchi
//
//  Created by Codex on 11.03.2026.
//

import Foundation

#if DEBUG
enum PreviewFactory {
    
    private static let authBaseURL = URL(
        string: "https://d5dv0tsfdqg45rj2b9i8.4b4k4pg5.apigw.yandexcloud.net/v1"
    )!
    
    static func makeNetworkService() -> NetworkService {
        NetworkService()
    }

    static func makeMenuUseCase(network: NetworkService? = nil) -> LoadMenuUseCase {
        let network = network ?? makeNetworkService()
        let url = URL(string: "https://riknabdpryhyoyrgjkgk.supabase.co/storage/v1/object/public/menu/Ponchi.json")!
        let remote = MenuRemoteDataSource(menuURL: url, network: network)
        let local = MenuLocalDataSource()
        let repo = DefaultMenuRepository(remote: remote, local: local)
        return LoadMenuUseCase(repo: repo)
    }

    static func makePonchiViewModel(network: NetworkService? = nil) -> PonchiViewModel {
        let network = network ?? makeNetworkService()
        return PonchiViewModel(loadMenuUseCase: makeMenuUseCase(network: network))
    }

    @MainActor static func makeUserViewModel(network: NetworkService? = nil) -> UserViewModel {
        let network = network ?? makeNetworkService()
        let authService = AuthService(network: network, baseURL: authBaseURL, backend: .yandex)
        let keychain = KeychainService(service: "Ponchi.preview")
        let sessionManager = SessionManager(keychain: keychain)

        return UserViewModel(
            authService: authService,
            sessionManager: sessionManager
        )
    }
}
#endif
