//
//  ResultView.swift
//  golf-pose
//
//  Created by 이동현 on 2021/12/13.
//

import Foundation
import UIKit

final class ResultView: UIView {
    let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.numberOfLines = 0
        $0.textColor = .white
        $0.text = "Swing your left arm faster!!"
    }

    let descriptionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.numberOfLines = 0
        $0.textColor = .white
        $0.text = "Your arm is 20% slower than standard cases. Swing your left arm faster."
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        addSubview(descriptionLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setResult(title: String, description: String) {
        titleLabel.text = title
        descriptionLabel.text = description
    }
}
