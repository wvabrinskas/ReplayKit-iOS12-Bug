//
//  ViewController.swift
//  Record
//
//  Created by William Vabrinskas on 8/28/19.
//  Copyright © 2019 William Vabrinskas. All rights reserved.
//

import UIKit
import ReplayKit
import AVKit

class ViewController: UIViewController, RPPreviewViewControllerDelegate {
    private let recorder = RPScreenRecorder.shared()
    private var isRecording = false
    private let recordingSession = AVAudioSession.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func react() {
        if !self.recorder.isRecording {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.backgroundColor = .red
                })
                self.startRecording()
            }
        } else {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.backgroundColor = .white
                })
                self.stopRecording()
            }
        }
    }
    
    private func startRecording() {

        guard self.recorder.isAvailable else {
            print("Recording is not available at this time.")
            return
        }
        self.recorder.isMicrophoneEnabled = true

        self.recorder.startRecording { (error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.recorder.isMicrophoneEnabled = false
                self.recorder.isMicrophoneEnabled = true
            }
        }

    }

    private func stopRecording() {
        recorder.stopRecording { [unowned self] (preview, error) in
            print("Stopped recording")
            guard preview != nil else {
                print(error)
                print("Preview controller is not available.")
                return
            }
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Recording Finished", message: "Would you like to edit or delete your recording?", preferredStyle: .alert)

                let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction) in
                    self.recorder.discardRecording(handler: { () -> Void in
                        print("Recording suffessfully deleted.")
                    })
                })

                let editAction = UIAlertAction(title: "Edit", style: .default, handler: { (action: UIAlertAction) -> Void in
                    preview?.previewControllerDelegate = self
                    self.present(preview!, animated: true, completion: nil)
                })

                alert.addAction(editAction)
                alert.addAction(deleteAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func previewController(_ previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
        
    }
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true)
    }
    
}

