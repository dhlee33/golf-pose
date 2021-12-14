//
//  ButtonCell.swift
//  golf-pose
//
//  Created by 이동현 on 2021/12/14.
//

import Foundation
import UIKit
import AVFoundation

final class ButtonCell: UITableViewCell {
    static let reuseIdentifier = "ButtonCell"
    private let retryButton = UIButton().then {
        $0.setTitle("RETRY", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        $0.backgroundColor = .primary
        $0.roundCorner(7)
        $0.isEnabled = false
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .black
        selectionStyle = .none

        contentView.addSubview(retryButton)

        retryButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(60)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
