# Volumizer
[![Platform](https://img.shields.io/cocoapods/p/Volumizer.svg?style=flat)](https://github.com/fxwx23/Volumizer)
[![Language](https://img.shields.io/badge/language-swift-orange.svg?style=flat)](https://developer.apple.com/swift)
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/Volumizer.svg)](https://cocoapods.org/pods/Volumizer)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/fxwx23/Volumizer/master/license)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md#pull-requests)

**Volumizer** replaces the system volume popup with a simple progress bar.

Before | After | After (iPhoneX)
--- | --- | ---
![good](https://raw.githubusercontent.com/fxwx23/Volumizer/master/Screenshots/before.png) | ![good](https://raw.githubusercontent.com/fxwx23/Volumizer/master/Screenshots/after.png) | ![good](https://raw.githubusercontent.com/fxwx23/Volumizer/master/Screenshots/after_iphonex.png) 

### Features

- Swift 4.2
- Hide the system volume HUD typically displayed on volume button presses
- Show a simple progress bar like Instagram's iOS app does
- Support iPhoneX, XS, XS Max, XR
- Well easy to customize appearance
- Only support `portrait` mode

## Installation

##### [CocoaPods](https://cocoapods.org) 
```ruby
platform :ios, '8.0'
use_frameworks!

pod 'Volumizer'
```
##### [Carthage](https://github.com/Carthage/Carthage)
```
github "fxwx23/Volumizer"
```

##### Manually
Drag the `Volumizer` folder into your project and link the `MediaPlayer` and `AVFoundation` frameworks to your project.


## Usage
Use of `Volumizer` is a simple way with one line. Just call `configure()` after set a window at least.

```swift
Volumizer.configure()
```

You can customize the bar's appearance with `VolumizerAppearanceOption`.

```swift
/**
public enum VolumizerAppearanceOption {
   case overlayIsTranslucent(Bool) default is `true`.
   case overlayBackgroundBlurEffectStyle(UIBlurEffectStyle) default is `.extraLight`.
   case overlayBackgroundColor(UIColor) default is `.white`.
   case sliderProgressTintColor(UIColor) default is `.black`.
   case sliderTrackTintColor(UIColor) default is `.lightGray.withAlphaComponent(0.5)`
}
*/

let options: [VolumizerAppearanceOption] = [ .overlayIsTranslucent(true),
                                             .overlayBackgroundBlurEffect( .extraLight),
                                             .overlayBackgroundColor( .white),
                                             .sliderProgressTintColor( .black)]

let volumizer = Volumizer.configure(options)

/// To change options based on view's current appearance, call `change(options:_)` .
volumizer.change(options: otherOptions)
```
If you want to release `volumizer` 's window, please call `resign()`. Once you released, the system volume popup will be shown again.

```swift
volumizer.resign()
```

## WIP
- [ ] support `landscape` mode.
- [ ] support [SPM]().
- [ ] manage window level to be below `UIWindowLevelAlert` .
- [ ] `Objective-C` compatible.

## License
This project is under the MIT license.
