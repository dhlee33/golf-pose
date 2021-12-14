//
//  TitleCell.swift
//  golf-pose
//
//  Created by 이동현 on 2021/12/14.
//

import Foundation
import UIKit
import AVFoundation

final class TitleCell: UITableViewCell {
    static let reuseIdentifier = "TitleCell"
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 25, weight: .bold)
        $0.numberOfLines = 0
        $0.textColor = .white
        $0.text = "Good Full Swing!"
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .black
        selectionStyle = .none

        contentView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(24)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}
