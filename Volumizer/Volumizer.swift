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
    case overlayIsTranslucent(Bool)
    case overlayBackgroundBlurEffectStyle(UIBlurEffect.Style)
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
        self.init(frame: CGRect(x: 0, y: 0,
                                width: UIScreen.main.bounds.height,
                                height: UIApplication.shared.statusBarFrame.height))
        self.base = base
        isAppActive = true
        setupSession(options)
    }
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
        overlay.frame = frame
    }
    
    required public init() {
        fatalError("Please use the convenience initializer `init(options:_, base:_)` instead.")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    deinit {
        session.removeObserver(self, forKeyPath: AVAudioSessionOutputVolumeKey, context: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
        overlay.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: statusBarHeight)
        overlayBlur.frame = overlay.bounds
        
        // Progress view frame is defined based on the device model.
        // Slider view style would be like Instagram's way (of course iPhoneX too).
        let deviceHasNotch = UIDevice.current.hasNotch
        let marginLeft = deviceHasNotch ? (layoutMargins.left * 2) : layoutMargins.left
        let top: CGFloat = (overlay.frame.height - slider.frame.height) / 2
        let width: CGFloat = deviceHasNotch ? (marginLeft * 2 + statusBarHeight) - marginLeft : overlay.frame.width - (marginLeft * 2)
        slider.frame = CGRect(x: marginLeft, y: top, width: width, height: slider.frame.height)
        slider.layer.cornerRadius = slider.bounds.height / 2
        slider.clipsToBounds = true
    }
    
    // MARK: Convenience
    
    @discardableResult
    open class func configure(_ options: [VolumizerAppearanceOption] = []) -> Volumizer {
        let base = UIWindow(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height, height: UIApplication.shared.statusBarFrame.height))
        base.windowLevel = UIWindow.Level.statusBar + 1.0
        
        let instance = Volumizer(options: options, base: base)
        base.addSubview(instance)
        base.makeKeyAndVisible()
        
        return instance
    }
    
    open func change(options: [VolumizerAppearanceOption]) {
        options.forEach {
            switch $0 {
            case .overlayIsTranslucent(let isTranslucent):
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
                backgroundColor = color
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
        do { try session.setCategory( .playback, mode: .default, options: .mixWithOthers) }
        catch { print("Unable to set audio session category.") }
        
        do { try session.setActive(true) }
        catch  { print("Unable to initialize AVAudioSession.") }
        
        volumeView.setVolumeThumbImage(UIImage(), for: UIControl.State())
        volumeView.isUserInteractionEnabled = false
        volumeView.showsRouteButton = false
        addSubview(volumeView)
        
        /// overlay's `backgroundColor` is white by default.
        overlay.backgroundColor = .white
        addSubview(overlay)
        
        overlayBlur = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        overlayBlur.frame = overlay.bounds
        overlay.addSubview(overlayBlur)
        
        /// slider's `thumbTintColor` is black by default.
        slider.backgroundColor = .white
        slider.progressTintColor = .black
        slider.trackTintColor = UIColor.lightGray.withAlphaComponent(0.5)
        addSubview(slider)
        
        change(options: options)
        update(volume: session.outputVolume, animated: false)
        
        /// add observers.
        session.addObserver(self, forKeyPath: AVAudioSessionOutputVolumeKey, options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionInterrupted(_:)), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionRouteChanged(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidChangeActive(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidChangeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    private func update(volume value: Float, animated: Bool) {
        volume = value
        slider.setProgress(volume, animated: true)
        
        do { try setSystem(volume: value) }
        catch { print("unable to change system volume level.") }
       
        let deviceHasNotch = UIDevice.current.hasNotch
        let animationDuration = deviceHasNotch ? 1.0 : 2.0
        let showRelativeDuration = deviceHasNotch ? 0.05 : 0.1
        let hideRelativeDuration = deviceHasNotch ? 0.3 : 0.1
        UIView.animateKeyframes(withDuration: animated ? animationDuration : 0, delay: 0, options: .beginFromCurrentState, animations: { () -> Void in
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: showRelativeDuration, animations: {
                self.animateProgressView(showing: true)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: hideRelativeDuration, animations: { () -> Void in
                self.animateProgressView(showing: false)
            })
        }) { _ in }
    }
    
    private func setSystem(volume value: Float) throws {
        guard let systemSlider = volumeView.subviews.compactMap({ $0 as? UISlider }).first else {
            throw VolumizerError.disableToChangeVolumeLevel
        }
        
        systemSlider.value = max(0, min(1, value))
    }
    
    private func animateProgressView(showing: Bool) {
        if showing {
            self.alpha = 1
            self.base?.transform = CGAffineTransform.identity
        } else {
            self.alpha = 0.0001
            self.base?.transform = UIDevice.current.hasNotch ?
                CGAffineTransform.identity :
                CGAffineTransform(translationX: 0, y: -self.frame.height)
        }
    }
    
    // MARK: Notification
    
    @objc private func audioSessionInterrupted(_ notification: Notification) {
        guard
            let interruptionInfo = notification.userInfo,
            let rawValue = interruptionInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let interruptionType = AVAudioSession.InterruptionType(rawValue: rawValue)
        else {
            return
        }
        
        switch interruptionType {
        case .began:
            print("Audio Session Interruption: began.")
            break
        case .ended:
            print("Audio Session Interruption: ended.")
            do { try session.setActive(true) }
            catch { print("Unable to initialize AVAudioSession.") }
        @unknown default:
            fatalError("unknown AVAudioSessio.InterruptionType is addded.")
        }
    }
    
    @objc private func audioSessionRouteChanged(_ notification: Notification) {
        guard
            let interruptionInfo = notification.userInfo,
            let rawValue = interruptionInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue: rawValue)
        else {
                return
        }
        
        switch reason {
        case .newDeviceAvailable:
            print("Audio seesion route changed: new device available.")
            break
        case .oldDeviceUnavailable:
            print("Audio seesion route changed: old device unavailable.")
            break
        default:
            print("Audio seesion route changed: \(reason.rawValue)")
            break
        }
    }
    
    @objc private func applicationDidChangeActive(_ notification: Notification) {
        isAppActive = notification.name == UIApplication.didBecomeActiveNotification
        if isAppActive {
            update(volume: session.outputVolume, animated: false)
        }
    }
    
    @objc private func orientationDidChange(_ notification: Notification) {
        // TODO: [wip] support landscape mode.
        // print("orientation changed.")
        /**
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
        */
    }
    
    // MARK: KVO
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let change = change, let value = change[.newKey] as? Float , keyPath == AVAudioSessionOutputVolumeKey else { return }
        update(volume: value, animated: UIDevice.current.orientation.isPortrait)
    }
}

extension UIDevice {
    fileprivate var hasNotch: Bool {
        guard let window = UIApplication.shared.keyWindow else {
            return false
        }
        
        if #available(iOS 11.0, *) {
            return window.safeAreaInsets.bottom > 0.0 && UIDevice.current.userInterfaceIdiom == .phone
        } else {
            return false
        }
    }
}
