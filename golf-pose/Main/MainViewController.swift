//
//  MainViewController.swift
//  golf-pose
//
//  Created by 이동현 on 2021/12/11.
//

import UIKit
import MLKitPoseDetectionAccurate
import MLKitVision
import AVFoundation
import RxSwift
import RxCocoa
import SnapKit
import Then
import ScreenCorners
import ReactorKit

class MainViewController: UIViewController, View {
    private let idleView = UIView()
    private let analyzingLabel = UILabel().then {
        $0.text = "Analyzing..."
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 30, weight: .bold)
    }

    private let recordingView = UIView().then {
        $0.layer.borderColor = UIColor.primary.cgColor
        $0.layer.borderWidth = 6
        $0.layer.cornerCurve = .continuous
        $0.layer.cornerRadius = UIScreen.main.displayCornerRadius
    }

    private let indicatorView = UIActivityIndicatorView().then {
        $0.style = .large
        $0.color = .white
        $0.hidesWhenStopped = true
    }

    private var playerLooper: AVPlayerLooper?
    private let processingView = AVPlayerView().then {
        $0.backgroundColor = .black
    }
    private let playerView = AVPlayerView().then {
        $0.layer.borderWidth = 1
        $0.layer.masksToBounds = true
        $0.layer.cornerCurve = .continuous
        $0.layer.cornerRadius = 20
    }
    var outputURL: URL?

    private let recordingLabel = UILabel().then {
        $0.text = " Recording..."
        $0.font = .systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .warning
    }

    private let analyzeButton = UIButton().then {
        $0.setTitle("ANALYZE", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        $0.backgroundColor = .primary
        $0.roundCorner(7)
    }

    private let cancelButton = UIButton().then {
        $0.setTitle("CANCEL", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        $0.backgroundColor = .gray
        $0.roundCorner(7)
    }

    private let cancelAnalyzingButton = UIButton().then {
        $0.setTitle("CANCEL", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        $0.backgroundColor = .gray
        $0.roundCorner(7)
    }

    private let doneButton = UIButton().then {
        $0.setTitle("DONE", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        $0.backgroundColor = .primary
        $0.roundCorner(7)
    }

    private let previewView = UIView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerCurve = .continuous
        $0.layer.cornerRadius = UIScreen.main.displayCornerRadius
    }
    private var videoPreviewLayer: CALayer?
    private let videoOutput = AVCaptureMovieFileOutput()
    private let startButton = UIButton().then {
        $0.setTitle("START", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        $0.backgroundColor = .primary
        $0.roundCorner(7)
    }

    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        checkCameraPermission()
        installCamera()

        reactor = MainViewReactor()
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func configure() {
        view.addSubview(previewView)
        view.addSubview(idleView)
        view.addSubview(recordingView)
        view.addSubview(processingView)
        idleView.addSubview(startButton)
        recordingView.addSubview(doneButton)
        recordingView.addSubview(recordingLabel)
        processingView.addSubview(playerView)
        processingView.addSubview(cancelButton)
        processingView.addSubview(analyzeButton)
        processingView.addSubview(indicatorView)
        processingView.addSubview(cancelAnalyzingButton)
        processingView.addSubview(analyzingLabel)

        analyzingLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(indicatorView.snp.top).offset(-20)
        }

        idleView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        previewView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        recordingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        processingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        cancelAnalyzingButton.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.height.equalTo(60)
        }

        startButton.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.height.equalTo(60)
        }

        doneButton.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.height.equalTo(60)
        }

        cancelButton.snp.makeConstraints { make in
            make.left.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.height.equalTo(60)
        }

        analyzeButton.snp.makeConstraints { make in
            make.width.equalTo(cancelButton)
            make.left.equalTo(cancelButton.snp.right).offset(10)
            make.right.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.height.equalTo(60)
        }

        recordingLabel.snp.makeConstraints { make in
            make.left.equalTo(doneButton)
            make.bottom.equalTo(doneButton.snp.top).offset(-5)
        }

        indicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        playerView.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaInsets).inset(24)
            make.bottom.equalTo(cancelButton.snp.top).offset(-24)
        }
    }

    private func installCamera() {
        let captureSession = AVCaptureSession()

        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video) else {
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(input), captureSession.canAddOutput(videoOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(videoOutput)
                // 여기에서 preview 세팅하는 함수 호출
            }
        } catch {
            return
        }


        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        captureSession.startRunning()
        self.videoPreviewLayer = videoPreviewLayer

        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
    }


    func checkCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in

        })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        videoPreviewLayer?.frame = previewView.bounds
    }


    func bind(reactor: MainViewReactor) {
        reactor.state.map(\.mainState)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .idle:
                    self.stopRecording()
                    self.idleView.isHidden = false
                    self.recordingView.isHidden = true
                    self.processingView.isHidden = true
                    self.playerView.player?.pause()
                case .processing:
                    self.analyzingLabel.isHidden = true
                    self.cancelAnalyzingButton.isHidden = true
                    self.stopRecording()
                    self.idleView.isHidden = true
                    self.recordingView.isHidden = true
                    self.processingView.isHidden = false
                case .analyzing:
                    self.analyzingLabel.isHidden = false
                    self.cancelAnalyzingButton.isHidden = false
                    self.indicatorView.startAnimating()
                case .recording:
                    self.startRecording()
                    self.playerView.player?.pause()
                    self.blinkRecordingLabel()
                    self.idleView.isHidden = true
                    self.recordingView.isHidden = false
                    self.processingView.isHidden = true
                }
            })
            .disposed(by: disposeBag)

        Observable.merge(
            startButton.rx.tap.map { .setState(.recording) },
            cancelButton.rx.tap.map { .setState(.idle) },
            analyzeButton.rx.tap.map { .setState(.analyzing) },
            doneButton.rx.tap.map { .setState(.processing) },
            cancelAnalyzingButton.rx.tap
                .do(onNext: { [weak self] _ in self?.indicatorView.stopAnimating() })
                .map { .setState(.processing) }
        )
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        analyzeButton.rx.tap
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .map { [weak self] _ -> String? in
                guard let self = self, let url = self.outputURL else {
                    reactor.action.onNext(.setState(.idle))
                    return nil
                }
                return DefaultPoseManager().extractPoses(url)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] poses in
                guard let self = self, let url = self.outputURL, let poses = poses else {
                    reactor.action.onNext(.setState(.idle))
                    return
                }

                let viewController = AnalyzeViewController(sourceURL: url, result: poses)
                self.present(viewController, animated: true)
                reactor.action.onNext(.setState(.idle))
            })
            .disposed(by: disposeBag)
    }


    func blinkRecordingLabel() {
        guard reactor?.currentState.mainState == .recording else {
            recordingLabel.alpha = 0
            return
        }

        let delay = self.recordingLabel.alpha == 1 ? 0.5 : 0
        UIView.animate(withDuration: 0.5, delay: delay, options: [.curveEaseInOut, .beginFromCurrentState]) { [weak self] in
            guard let self = self else { return }
            self.recordingLabel.alpha = 1 - self.recordingLabel.alpha
        } completion: { [weak self] _ in
            self?.blinkRecordingLabel()
        }
    }

    private func startRecording() {
        let fileManager = FileManager.default
        let path = fileManager.temporaryDirectory.appendingPathComponent("pose_data").absoluteURL
        print(path)
        videoOutput.startRecording(to: path, recordingDelegate: self)
    }

    private func stopRecording() {
        if videoOutput.isRecording {
            self.indicatorView.startAnimating()
            videoOutput.stopRecording()
        }
    }

    private func playVideo() {
        guard let outputURL = outputURL, reactor?.currentState.mainState == .processing else {
            return
        }
        let asset = AVAsset(url: outputURL)

        let playerItem = AVPlayerItem(asset: asset)
        let player = AVQueuePlayer(playerItem: playerItem).then {
            $0.isMuted = true
        }
        self.playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)

        self.indicatorView.stopAnimating()
        playerView.player = player
        playerView.player?.play()
    }
}

extension MainViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil, let fileData = try? Data(contentsOf: outputFileURL) {
            let fileManager = FileManager.default
            let url = fileManager.temporaryDirectory.appendingPathComponent("temp.mov").absoluteURL
            try? fileData.write(to: url)

            outputURL = url

            playVideo()
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

    }
}
