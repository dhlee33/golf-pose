//
//  ResultCell.swift
//  golf-pose
//
//  Created by 이동현 on 2021/12/14.
//

import Foundation
import UIKit
import AVFoundation

final class ResultCell: UITableViewCell {
    static let reuseIdentifier = "ResultCell"
    private let resultView = ResultView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .black
        selectionStyle = .none

        contentView.addSubview(resultView)

        resultView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(24)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setResult(_ improvement: Improvement) {
        resultView.titleLabel.text = improvement.title
        resultView.descriptionLabel.text = improvement.description
    }
}
