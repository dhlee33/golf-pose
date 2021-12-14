//
//  Result.swift
//  golf-pose
//
//  Created by 이동현 on 2021/12/14.
//

import Foundation

struct Result {
    static let mocks = [
        Result(title: "1. Address", details: [ResultDetail.mock, ResultDetail.mock], start: 0, duration: 1),
        Result(title: "2. Back swing", details: [ResultDetail.mock, ResultDetail.mock], start: 1, duration: 2),
        Result(title: "3. Back swing top", details: [ResultDetail.mock, ResultDetail.mock], start: 2, duration: 3)
    ]

    let title: String
    let details: [ResultDetail]
    let start: Double
    let duration: Double
}

struct ResultDetail {
    static let mock = ResultDetail(
        title: "Swing your left arm faster!!",
        description: "Your arm is 20% slower than standard cases. Swing your left arm faster."
    )
    let title: String
    let description: String
}
