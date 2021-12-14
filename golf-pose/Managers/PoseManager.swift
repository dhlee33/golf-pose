//
//  PoseManager.swift
//  golf-pose
//
//  Created by 이동현 on 2021/12/11.
//

import Foundation
import MLKitPoseDetectionAccurate
import MLKitVision
import AVFoundation

protocol PoseManagser {
    func extractPoses(_ url: URL) -> String?
}

final class DefaultPoseManager: PoseManagser {
    func getVideoVisionImage(_ buffer: CMSampleBuffer) -> VisionImage {
        let sampleImage = VisionImage(buffer: buffer)

        sampleImage.orientation = imageOrientation(
            deviceOrientation: UIDevice.current.orientation,
            cameraPosition: .back
        )

        return sampleImage
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
        } catch _ {
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


    func extractPoses(_ url: URL) -> String? {
        let asset = AVAsset(url: url)
        let reader = try? AVAssetReader(asset: asset)

        guard let track = asset.tracks(withMediaType: .video).last else {
            return nil
        }
        let trackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: [String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_420YpCbCr8BiPlanarFullRange])
        reader?.add(trackOutput)
        reader?.startReading()
        var sample = trackOutput.copyNextSampleBuffer()

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

        return result
    }
}
