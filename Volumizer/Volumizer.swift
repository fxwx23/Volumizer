//
//  Volumizer.swift
//  Volumizer
//
//  Created by Fumitaka Watanabe on 2017/03/16.
//  Copyright © 2017年 Fumitaka Watanabe. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

fileprivate let AVAudioSessionOutputVolumeKey = "outputVolume"

/**
 Errors being thrown by `VolumizerError`.
 - disableToChangeVolumeLevel: `Volumizer` was unable to change audio level
 */
public enum VolumizerError: Error {
    case disableToChangeVolumeLevel
}

/**
 VolumizerAppearanceOption
 */
public enum VolumizerAppearanceOption {
    case oberlayIsTranslucent(Bool)
    case overlayBackgroundBlurEffectStyle(UIBlurEffectStyle)
    case overlayBackgroundColor(UIColor)
    case sliderProgressTintColor(UIColor)
    case sliderTrackTintColor(UIColor)
}

/**
 - Volumizer
 Replace default `MPVolumeView` by volumizer.
 */
open class Volumizer: UIView {
    // MARK: Properties
    // current volume value.
    public fileprivate(set) var volume: Float = 0
    
    private let session = AVAudioSession.sharedInstance()
    private let volumeView = MPVolumeView(frame: CGRect.zero)
    private let overlay = UIView()
    private var overlayBlur = UIVisualEffectView()
    private var slider = UIProgressView()
    private var base: UIWindow?
    private var isAppActive = false
    private var isAlreadyWindowLevelAboveNormal = false
    
    // MARK: Initializations
    
    public convenience init(options: [VolumizerAppearanceOption], base: UIWindow) {
        /// default width 
        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height, height: 20.0))
        self.base = base
        isAppActive = true
        setupSession(options)
    }
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
        overlay.frame = frame
    }
    
    required public init() {
        fatalError("Please use the convenience initializer `init(options:_, base:_)` instead")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        session.removeObserver(self, forKeyPath: AVAudioSessionOutputVolumeKey, context: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        base?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20.0)
        overlay.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20.0)
        
        let side: CGFloat = 8.0
        slider.frame = CGRect(x: side,
                              y: (overlay.frame.height - slider.frame.height) / 2,
                              width: overlay.frame.width - (side * 2),
                              height: slider.frame.height)
        
        overlayBlur.frame = overlay.bounds
    }
    
    // MARK: Convenience
    
    open class func configure(_ options: [VolumizerAppearanceOption]) -> Volumizer {
        let base = UIWindow(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height, height: 20.0))
        base.windowLevel = UIWindowLevelStatusBar + 1.0
        
        let instance = Volumizer(options: options, base: base)
        base.addSubview(instance)
        base.makeKeyAndVisible()
        
        return instance
    }
    
    open func update(options: [VolumizerAppearanceOption]) {
        options.forEach {
            switch $0 {
            case .oberlayIsTranslucent(let isTranslucent):
                if isTranslucent {
                    overlayBlur.isHidden = false
                }
                else {
                    overlayBlur.isHidden = true
                }
            case .overlayBackgroundBlurEffectStyle(let style):
                overlayBlur.effect = UIBlurEffect(style: style)
            case .overlayBackgroundColor(let color):
                overlay.backgroundColor = color
            case .sliderProgressTintColor(let color):
                slider.progressTintColor = color
            case .sliderTrackTintColor(let color):
                slider.trackTintColor = color
            }
        }
    }
    
    open func resign() {
        base?.resignKey()
        base = nil
    }
    
    // MARK: Private
    
    private func setupSession(_ options: [VolumizerAppearanceOption]) {
        do {
            try session.setActive(true)
        } catch {
            NSLog("Unable to initialize AVAudioSession")
        }
        
        update(volume: session.outputVolume, animated: false)
        
        backgroundColor = .white
        
        volumeView.setVolumeThumbImage(UIImage(), for: UIControlState())
        volumeView.isUserInteractionEnabled = false
        volumeView.showsRouteButton = false
        addSubview(volumeView)
        
        /// overlay's `backgroundColor` is white by default.
        overlay.backgroundColor = .white
        overlayBlur = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        overlayBlur.frame = overlay.bounds
        addSubview(overlay)
        overlay.addSubview(overlayBlur)
        
        /// slider's `thumbTintColor` is black by default.
        slider.backgroundColor = .white
        slider.progressTintColor = .black
        slider.trackTintColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        update(options: options)
        addSubview(slider)
    
        /// add observers.
        session.addObserver(self, forKeyPath: AVAudioSessionOutputVolumeKey, options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionInterrupted(_:)), name: .AVAudioSessionInterruption, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidChangeActive(_:)), name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidChangeActive(_:)), name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange(_:)), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    private func update(volume value: Float, animated: Bool) {
        volume = value
        slider.setProgress(volume, animated: true)
        
        do {
            try setSystem(volume: value)
        } catch {
            NSLog("unable to change system volume level.")
        }
        
        UIView.animateKeyframes(withDuration: animated ? 2 : 0, delay: 0, options: .beginFromCurrentState, animations: { () -> Void in
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1, animations: {
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.1, animations: { () -> Void in
                self.transform = CGAffineTransform(translationX: 0, y: -self.frame.height)
                self.alpha = 0.0001
            })
        }) { _ in }
    }
    
    private func setSystem(volume value: Float) throws {
        guard let systemSlider = volumeView.subviews.flatMap({ $0 as? UISlider }).first else {
            throw VolumizerError.disableToChangeVolumeLevel
        }
        
        systemSlider.value = max(0, min(1, value))
    }
    
    // MARK: Notification
    
    @objc private func audioSessionInterrupted(_ notification: Notification) {
        guard let interuptionInfo = notification.userInfo,
            let rawValue = interuptionInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let interuptionType = AVAudioSessionInterruptionType(rawValue: rawValue) else {
            return
        }
        
        switch interuptionType {
        case .began:
            // NSLog("Audio Session Interruption case started.")
            break
        case .ended:
            do {
                try session.setActive(true)
            } catch {
                NSLog("Unable to initialize AVAudioSession")
            }
        }
    }
    
    @objc private func applicationDidChangeActive(_ notification: Notification) {
        isAppActive = notification.name == Notification.Name.UIApplicationDidBecomeActive
        if isAppActive {
            update(volume: session.outputVolume, animated: false)
        }
    }
    
    @objc private func orientationDidChange(_ notification: Notification) {
        // TODO: [wip] support landscape mode.
        // NSLog("orientation changed.")
        let currentOrientation = UIDevice.current.orientation
        switch currentOrientation {
        case .landscapeLeft:
            base?.transform = CGAffineTransform(rotationAngle: -CGFloat(90 * M_PI / 180.0))
        case .landscapeRight:
            base?.transform = CGAffineTransform(rotationAngle: CGFloat(90 * M_PI / 180.0))
        case .portraitUpsideDown:
            base?.transform = CGAffineTransform(rotationAngle: CGFloat(180.0 * M_PI / 180.0))
        default:
            base?.transform = CGAffineTransform(rotationAngle: CGFloat(0.0 * M_PI / 180.0))
        }
    }
    
    // MARK: KVO
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let change = change, let value = change[.newKey] as? Float , keyPath == AVAudioSessionOutputVolumeKey else { return }
        
        update(volume: value, animated: UIDeviceOrientationIsPortrait(UIDevice.current.orientation))
    }
}
