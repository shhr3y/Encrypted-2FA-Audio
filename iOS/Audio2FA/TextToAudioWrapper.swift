//
//  TextToAudio.swift
//  Audio2FA
//
//  Created by Shrey Gupta on 26/10/22.
//

import AVFoundation
import UIKit
import AudioToolbox
//import SoundP

protocol TextToAudioWrapperDelegate
{
    func messageDidReceive(_ string :String)
    func messageDidSend()
}

@objc public class TextToAudioWrapper: NSObject {
    
    @objc static var shared = TextToAudioWrapper()
    
    private var textToAudioObj : TextToAudioSDK!
    var delegate : TextToAudioWrapperDelegate?
    
    private override init() {
        super.init()

        textToAudioObj = TextToAudioSDK()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveMessage(notification:)), name: Notification.Name("TextToAudioSdkReceivedMessage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didUpdateProgress(notification:)), name: Notification.Name("TextToAudioSdkPlayingProgress"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didFinishSending(notification:)), name: Notification.Name("TextToAudioSdkFinishedSending"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("TextToAudioSdkReceivedMessage"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("TextToAudioSdkPlayingProgress"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("TextToAudioSdkFinishedSending"), object: nil)
    }
    
    @objc func didUpdateProgress(notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            let infoType = userInfo["progress"] as? String ?? ""
            print("MES: \(infoType)")
        }
    }
    
    @objc func didReceiveMessage(notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            if let sdkMessage = userInfo["string_message"] as? String {
                self.delegate?.messageDidReceive(sdkMessage)
            }
        }
    }
   
    @objc func didFinishSending(notification: Notification) {
        self.delegate?.messageDidSend()
    }
    
    func broadCastText(_ string: String) {
        if string.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
            self.textToAudioObj.startPlayback(string.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
    
    func receiveBroadcastText() {
        self.textToAudioObj.startCapture()
    }
    
    func stopBroadCast() {
        self.textToAudioObj.stopPlayback()
    }
    
    func stopReceiving() {
        self.textToAudioObj.stopCapturing()
    }
    
}

