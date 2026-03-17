//
//  GiftLaunchScreenView.swift
//  Ponchi
//
//  Created by mary romanova on 29.10.2025.
//

import SwiftUI
import AVKit

struct VideoPlayerView: UIViewRepresentable {
    let videoName: String

    func makeUIView(context: Context) -> PlayerUIView {
        return PlayerUIView(videoName: videoName)
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {}
}

final class PlayerUIView: UIView {
    private var playerLayer = AVPlayerLayer()
    private var player: AVPlayer?

    init(videoName: String) {
        super.init(frame: .zero)
        backgroundColor = .clear
        setupPlayer(videoName: videoName)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPlayer(videoName: String) {
        guard let path = Bundle.main.path(forResource: videoName, ofType: "mp4") else {
            print("⚠️ Video not found: \(videoName).mp4")
            return
        }

        let player = AVPlayer(url: URL(fileURLWithPath: path))
        self.player = player
        player.isMuted = true
        player.play()

        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill  // 🔥 убирает чёрные рамки
        layer.addSublayer(playerLayer)

        // Зацикливаем видео
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Обновляем фрейм слоя при изменении размеров
        playerLayer.frame = bounds
    }
}
