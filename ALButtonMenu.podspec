Pod::Spec.new do |s|

  s.name         = "ALButtonMenu"
  s.version      = "1.1.0"
  s.summary      = "A simple, fully customizable menu solution for iOS."
  s.description  = <<-DESC
                     ALButtonMenu is a customizable menu solution for iOS. Create a menu view controller (or use
                     the one provided) and specify the characteristics of the shortcut button. Then tap the button
                     to quickly show and hide the menu using an animated mask transition effect.
                   DESC
  s.homepage     = "https://github.com/lobianco/ALButtonMenu"
  s.screenshots  = "https://raw.githubusercontent.com/lobianco/ALButtonMenu/master/Screenshots/demo1.gif", "https://raw.githubusercontent.com/lobianco/ALButtonMenu/master/Screenshots/demo2.gif"
  s.license      = "MIT"
  s.author             = { "Anthony Lobianco" => "anthony@lobian.co" }
  s.social_media_url   = "https://twitter.com/lobnco"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/lobianco/ALButtonMenu.git", :tag => "#{s.version}" }
  s.source_files = "Source/*.{h,m}"
  s.private_header_files = "Source/*_ALPrivate.h"
  s.requires_arc = true

end
