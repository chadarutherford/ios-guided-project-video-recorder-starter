//
//  CameraViewController.swift
//  VideoRecorder
//
//  Created by Paul Solt on 10/2/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import AVFoundation
import UIKit

class CameraViewController: UIViewController {

    @IBOutlet var recordButton: UIButton!
    @IBOutlet var cameraView: CameraPreviewView!
    
    private lazy var captureSession = AVCaptureSession()
    private lazy var fileOutput = AVCaptureMovieFileOutput()
    private var player: AVPlayer!
    var isRecording: Bool {
        fileOutput.isRecording
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()
		cameraView.videoPlayerView.videoGravity = .resizeAspectFill // Resize camera preview to fill the entire screen
        setupCamera()
	}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    private func setupCamera() {
        let camera = bestCamera()
        captureSession.beginConfiguration()
        
        // Inputs
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else { fatalError("Device configured incorrectly") }
        guard captureSession.canAddInput(cameraInput) else { fatalError("Unable to add camera input") }
        captureSession.addInput(cameraInput)
        
        // Resolution
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }
        
        // Microphone
        
        // Outputs
        guard captureSession.canAddOutput(fileOutput) else { fatalError("Cannot add file output") }
        captureSession.addOutput(fileOutput)
        
        captureSession.commitConfiguration()
        cameraView.session = captureSession
    }
    
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return device
        }
        
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        
        fatalError("No cameras available on device (or running in the Simulator)")
        
    }
    
    @IBAction func recordButtonPressed(_ sender: Any) {
        toggleRecord()
	}
    
    private func toggleRecord() {
        if isRecording {
            fileOutput.stopRecording()
        } else {
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
	
	/// Creates a new file URL in the documents directory
	private func newRecordingURL() -> URL {
		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime]

		let name = formatter.string(from: Date())
		let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
		return fileURL
	}
    
    private func updateViews() {
        recordButton.isSelected = isRecording
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        updateViews()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("URL: \(outputFileURL.path)")
        updateViews()
    }
}
