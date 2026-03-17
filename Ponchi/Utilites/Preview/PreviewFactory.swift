//
//  PreviewFactory.swift
//  Ponchi
//
//  Created by Codex on 11.03.2026.
//

import Foundation

#if DEBUG
enum PreviewFactory {
    static func makeMenuUseCase() -> LoadMenuUseCase {
        let url = URL(string: "https://storage.yandexcloud.net/ponchibucket/Ponchi.json")!
        let remote = MenuRemoteDataSource(menuURL: url)
        let local = MenuLocalDataSource()
        let repo = DefaultMenuRepository(remote: remote, local: local)
        return LoadMenuUseCase(repo: repo)
    }

    static func makePonchiViewModel() -> PonchiViewModel {
        PonchiViewModel(loadMenuUseCase: makeMenuUseCase())
    }
}
#endif
