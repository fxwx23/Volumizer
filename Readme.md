# Volumizer 
 [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md#pull-requests) [![Language](https://img.shields.io/badge/language-swift-orange.svg?style=flat)](https://developer.apple.com/swift)

`Volumizer` replaces the system volume popup with a simple progress bar.

### Features

- Swift3
- Hide the system volume HUD typically displayed on volume button presses
- Show a simple progress bar like Instagram's iOS app does
- Well easy to customize appearance
- Only support `portrait` mode.

## Installation

##### CocoaPods
[CocoaPods](https://cocoapods.org) 0.36 adds supports for Swift and embedded frameworks. To integrate Volumizer into your project add the following to your `Podfile`: 

```ruby
platform :ios, '8.0'
use_frameworks! 

pod 'Volumizer'
```
##### Carthage
Add the following to your `Cartfile` and follow [these instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application)

```
github "fxwx23/Voumizer"
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
   case oberlayIsTranslucent(Bool) default is `true`.
   case overlayBackgroundBlurEffectStyle(UIBlurEffectStyle) default is `.extraLight`.
   case overlayBackgroundColor(UIColor) default is `.white`.
   case sliderProgressTintColor(UIColor) default is `.black`.
   case sliderTrackTintColor(UIColor) default is `.lightGray.withAlphaComponent(0.5)`
}
*/

let options: [VolumizerAppearanceOption] = [ .oberlayIsTranslucent(true),
                                             .overlayBackgroundBlurEffect( .extraLight),
                                             .overlayBackgroundColor( .white),
                                             .sliderProgressTintColor( .black)]
                                             
let volumizer = Volumizer.configure(options)

/// To change options based on view's current appearance, call `update(options:_)` .
volumizer.update(options: otherOptions)
```
If you want to release `volumizer` 's window, please call `resign()`. Once you released, the system volume popup will be shown again.

```swift
volumizer.resign()
```

## License
This project is under the MIT license.