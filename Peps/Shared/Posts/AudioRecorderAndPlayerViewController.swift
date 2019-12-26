//
//  AudioRecorderAndPlayerViewController.swift
//  Peps
//
//  Created by Shubham Garg on 08/06/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import AVFoundation
import UIKit

protocol AudioRecorderDelegate {
    var recordedAudioURL: URL? { get set }
    var uploadType: UploadType { get set }
}

class AudioRecorderAndPlayerViewController: UIViewController, AVAudioRecorderDelegate {
    @IBOutlet var btnAudioRecord: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var settings = [String: Int]()
    var delegate: AudioRecorderDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAudioRecord.layer.cornerRadius = btnAudioRecord.frame.height / 2
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSession.Category.playAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission { allowed in
                DispatchQueue.main.async {
                    if allowed {
//                        print("Allow")
                    } else {
//                        print("Dont Allow")
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } catch {
            print("failed to record!")
        }

        // Audio Settings

        settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]
    }

    override func viewWillAppear(_: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    @IBAction func cancel(_: AnyObject) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func click_AudioRecord(_: AnyObject) {
        if audioRecorder == nil {
            btnAudioRecord.setTitle("Stop", for: UIControl.State.normal)
            btnAudioRecord.backgroundColor = .red
            startRecording()
        } else {
            btnAudioRecord.setTitle("Record", for: UIControl.State.normal)
            btnAudioRecord.backgroundColor = .green
            finishRecording(success: true)
            navigationController?.popViewController(animated: true)
        }
    }

    func directoryURL() -> NSURL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.appendingPathComponent("podcast_audio.m4a")
        delegate?.recordedAudioURL = soundURL
        return soundURL as NSURL?
    }

    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            audioRecorder = try AVAudioRecorder(url: directoryURL()! as URL,
                                                settings: settings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        } catch {
            finishRecording(success: false)
        }
        do {
            try audioSession.setActive(true)
            audioRecorder.record()
        } catch {}
    }

    func finishRecording(success: Bool) {
        audioRecorder.stop()
        if success {
            delegate?.uploadType = .audio
//            print(success)
        } else {
            audioRecorder = nil
//            print("Somthing Wrong.")
        }
    }

    func audioRecorderDidFinishRecording(_: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}
