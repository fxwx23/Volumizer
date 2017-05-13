Pod::Spec.new do |s|
  s.name     = 'Volumizer'
  s.version  = '1.0.4'
  s.platform = :ios, "8.0"
  s.license  = { :type => "MIT", :file => "license" }
  s.summary  = 'Volumizer replaces the system volume popup with a simple progress bar.'
  s.homepage = 'https://github.com/fxwx23/Volumizer'
  s.author   = { 'Fumitaka Watanabe' => 'fxwx23@gmail.com' }
  s.social_media_url   = "https://twitter.com/fxwx23"
  s.source   = { :git => 'https://github.com/fxwx23/Volumizer.git', :tag => "v#{s.version}" }
  s.description  = <<-DESC
                     -Volumizer replaces the system volume popup with a simple progress bar.
                     -Features
                     -1. Swift3
                     -2. Hide the system volume HUD typically displayed on volume button presses
                     -3. Show a simple progress bar like Instagram's iOS app does
                     -4. Well easy to customize appearance
                     -5. Only support portrait mode
                   DESC
  s.source_files = 'Volumizer/*.{h,m,swift}'
  s.framework    = 'MediaPlayer', 'AVFoundation'
  s.requires_arc = true
end
