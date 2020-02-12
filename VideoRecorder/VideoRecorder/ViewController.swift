//
//  ViewController.swift
//  VideoRecorder
//
//  Created by Paul Solt on 10/2/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import AVFoundation
import UIKit

class ViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		requestPermissionAndShowCamera()
	}
    
    private func requestPermissionAndShowCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            requestVideoPermission()
        case .restricted:
            fatalError("Parental controls have been enabled. Video access is denied.")
        case .denied:
            fatalError("Tell User to enable permission for Video/Camera")
        case .authorized:
            showCamera()
        @unknown default:
            fatalError("Apple added a new case for status that we aren't handling yet.")
        }
    }
    
    private func requestVideoPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let self = self, granted else {
                fatalError("Tell User to enable permission for Video/Camera")
            }
            DispatchQueue.main.async { self.showCamera() }
        }
    }
	
	private func showCamera() {
		performSegue(withIdentifier: "ShowCamera", sender: self)
	}
}
