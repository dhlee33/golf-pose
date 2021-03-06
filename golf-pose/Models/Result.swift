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

struct DTOResult: Decodable {
    static let mock = DTOResult(title: "Full Swing", details: DTOResultDetail.mocks)

    let title: String
    let details: [DTOResultDetail]
}

struct DTOResultDetail: Decodable {
    static let mocks = [
        DTOResultDetail(title: "Back Swing", startFrame: 10, endFrame: 40, improvements: [.HEAD, .WAIST]),
        DTOResultDetail(title: "Back Swing", startFrame: 40, endFrame: 60, improvements: [.HEAD]),
        DTOResultDetail(title: "Back Swing", startFrame: 60, endFrame: 80, improvements: [.LEFT_ARM, .RIGHT_ARM])
    ]
    let title: String
    let startFrame: Int
    let endFrame: Int
    let improvements: [Improvement]
}

enum Improvement: String, Decodable {
    case HEAD
    case LEFT_ARM
    case RIGHT_ARM
    case WAIST
    case PELVIS

    var title: String {
        switch self {
        case .HEAD:
            return "Keep your head still!!"
        case .LEFT_ARM:
            return "Extend your left arm more!!"
        case .RIGHT_ARM:
            return "Extend your right arm more!!"
        case .WAIST:
            return "Keep your waist still!!"
        case .PELVIS:
            return "Make sure to rotate your pelvis!!"
        }
    }

    var description: String {
        switch self {
        case .HEAD:
            return "Your head is moving too much."
        case .LEFT_ARM:
            return "Your left arm bent too much."
        case .RIGHT_ARM:
            return "Your right arm bent too much."
        case .WAIST:
            return "It will help you to hit a consistent shot."
        case .PELVIS:
            return "It will help you to hit a consistent shot."
        }
    }
}
