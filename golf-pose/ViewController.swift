//
//  ViewController.swift
//  golf-pose
//
//  Created by 이동현 on 2021/10/27.
//

import UIKit
import MLKitPoseDetectionAccurate
import MLKitVision
import AVFoundation
import RxSwift
import SnapKit
import Then

class ViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let imageView = UIImageView().then {
        $0.image = UIImage(named: "golf-sample")
    }
    private var playerLooper: AVPlayerLooper?

    private lazy var playerView = AVPlayerView().then {
        guard let path = Bundle.main.path(forResource: "sample", ofType: "mp4") else {
            return
        }
        let asset = AVAsset(url: URL(fileURLWithPath: path))

        let playerItem = AVPlayerItem(asset: asset)
        let player = AVQueuePlayer(playerItem: playerItem).then {
            $0.isMuted = true
        }
        self.playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        playerLooper?.disableLooping()

        $0.player = player
        $0.player?.play()
    }

    private let imageResultlabel = UILabel().then {
        $0.numberOfLines = 0
        $0.lineBreakMode = .byTruncatingTail
    }
    private let videoResultlabel = UILabel().then {
        $0.numberOfLines = 0
        $0.lineBreakMode = .byTruncatingTail
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()

        _ = Observable<String?>
            .deferred { [weak self] in
                guard let self = self else { return .empty() }
                let image = self.getVideoVisionImage()
                return .just(nil)
            }
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe()

//        _ = Observable<String?>
//            .deferred { [weak self] in
//                guard let self = self else { return .empty() }
//                let image = self.getVideoVisionImage()
//                return .just(self.detectPose(visionImage: image, mode: .stream))
//            }
//            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
//            .take(1)
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] text in
//                self?.videoResultlabel.text = text
//            })

//        _ = Observable<String?>
//            .deferred { [weak self] in
//                guard let self = self else { return .empty() }
//                let image = self.getImageVisionImage()
//                return .just(self.detectPose(visionImage: image, mode: .singleImage))
//            }
//            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
//            .take(1)
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] text in
//                self?.imageResultlabel.text = text
//            })
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func getImageVisionImage() -> VisionImage? {
        guard let image = UIImage(named: "golf-sample") else { return nil }
        return VisionImage(image: image)
    }

    private func getVideoVisionImage() -> VisionImage? {
        guard let path = Bundle.main.path(forResource: "sample", ofType: "mp4") else {
            return nil
        }
        let asset = AVAsset(url: URL(fileURLWithPath: path))
        let reader = try? AVAssetReader(asset: asset)

        guard let track = asset.tracks(withMediaType: .video).last else {
            return nil
        }
        let trackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: [String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_420YpCbCr8BiPlanarFullRange])
        reader?.add(trackOutput)
        reader?.startReading()

        // Get first sample buffer
        var sample = trackOutput.copyNextSampleBuffer()
//        var last = sample
//        var count = 0
//
//        while count < 10 {
//            last = sample
//            sample = trackOutput.copyNextSampleBuffer()
//            count += 1
//        }

        let options = AccuratePoseDetectorOptions()
        options.detectorMode = .stream
        let poseDetector = PoseDetector.poseDetector(options: options)

        var result = "index,landmark,xPosition,yPosition,zPosition\n"
        var index = 0
        while sample != nil {
            let sampleImage = VisionImage(buffer: sample!)
            if index % 3 == 0 {
                let csv = detectPose(index: index / 3, visionImage: sampleImage, mode: .singleImage) ?? ""

                result += csv
            }
            index += 1

            sample = trackOutput.copyNextSampleBuffer()
        }

        print(result)

        return nil
//        sampleImage.orientation = imageOrientation(
//            deviceOrientation: UIDevice.current.orientation,
//            cameraPosition: .back
//        )
    }

    private func detectPose(index: Int, visionImage: VisionImage?, mode: PoseDetectorMode) -> String? {
        guard let visionImage = visionImage else {
            return nil
        }

        let options = AccuratePoseDetectorOptions()
        options.detectorMode = mode
        let poseDetector = PoseDetector.poseDetector(options: options)

        var results: [Pose] = []
        do {
            results = try poseDetector.results(in: visionImage)
        } catch let error {
            return nil
        }
        guard !results.isEmpty else {
            return nil
        }

        return results.first?.getLandMarksCSV(index: index)
    }

    func imageOrientation(
        deviceOrientation: UIDeviceOrientation,
        cameraPosition: AVCaptureDevice.Position
    ) -> UIImage.Orientation {
        switch deviceOrientation {
        case .portrait:
            return cameraPosition == .front ? .leftMirrored : .right
        case .landscapeLeft:
            return cameraPosition == .front ? .downMirrored : .up
        case .portraitUpsideDown:
            return cameraPosition == .front ? .rightMirrored : .left
        case .landscapeRight:
            return cameraPosition == .front ? .upMirrored : .down
        case .faceDown, .faceUp, .unknown:
            return .up
        }
    }

    private func configure() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(imageResultlabel)
        contentView.addSubview(playerView)
        contentView.addSubview(videoResultlabel)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        playerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(500)
        }

        videoResultlabel.snp.makeConstraints { make in
            make.top.equalTo(playerView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(500)
        }

        imageView.snp.makeConstraints { make in
            make.top.equalTo(videoResultlabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(500)
        }

        imageResultlabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
            make.height.equalTo(500)
        }
    }
}


final class AVPlayerView: UIView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    private var playerLayer: AVPlayerLayer {
        guard let playerLayer = layer as? AVPlayerLayer else {
            assertionFailure()
            return AVPlayerLayer()
        }
        return playerLayer
    }

    var player: AVPlayer? {
        get {
            return playerLayer.player
        }

        set {
            playerLayer.player = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct LandMarkDTO: Encodable {
    let landMark: String
    let xPosision: Double
    let yPosision: Double
    let zPosision: Double
}

extension Pose {
    func getLandMarksCSV(index: Int) -> String {
        return landmarks.reduce("") { result, landmark in
            result + "\(index),\(landmark.type.rawValue),\(landmark.position.x),\(landmark.position.y),\(landmark.position.z)\n"
        }
    }
}
