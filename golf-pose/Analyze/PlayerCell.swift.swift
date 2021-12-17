//
//  PlayerCell.swift.swift
//  golf-pose
//
//  Created by이동현 on 2021/12/13.
//

import Foundation
import UIKit
import AVFoundation

final class PlayerCell: UITableViewCell {
    static let reuseIdentifier = "PlayerCell"
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 22, weight: .bold)
        $0.numberOfLines = 0
        $0.textColor = .white
        $0.text = "1. Address"
    }
    private var playerLooper: AVPlayerLooper?
    private let playerView = AVPlayerView().then {
        $0.layer.borderWidth = 1
        $0.layer.masksToBounds = true
        $0.layer.cornerCurve = .continuous
        $0.layer.cornerRadius = 20
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .black
        selectionStyle = .none

        contentView.addSubview(titleLabel)
        contentView.addSubview(playerView)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.left.right.equalToSuperview().inset(24)
        }

        playerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.height.equalTo(400)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setResult(url: URL, title: String, start: Int, end: Int) {
        let asset = AVAsset(url: url)

        let playerItem = AVPlayerItem(asset: asset)
        let player = AVQueuePlayer(playerItem: playerItem).then {
            $0.isMuted = true
        }
        self.playerLooper = AVPlayerLooper(
            player: player,
            templateItem: playerItem,
            timeRange: CMTimeRange(
                start: CMTime(seconds: Double(start) / 60, preferredTimescale: 60),
                duration: CMTime(seconds: Double(start - end) / 60, preferredTimescale: 60)
            )
        )
        playerView.player = player
        playerView.player?.play()

        titleLabel.text = title
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        playerView.player?.pause()
    }
}
