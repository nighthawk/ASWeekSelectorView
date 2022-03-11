Pod::Spec.new do |s|
  s.name         = "ASWeekSelectorView"
  s.version      = "1.1.2"
  s.summary      = "iOS calendar-inspired simple mini week view to select swipe through weeks and tap on days"
  s.description  = <<-DESC
                      A mini week view to select a day. You can swipe through weeks and tap on days to select them, somewhat similar to the iOS 7 calendar app.
                    DESC
  s.homepage     = "https://github.com/nighthawk/ASWeekSelectorView"
  s.license      = 'FreeBSD'
  s.author       = { "Adrian Schoenig" => "adrian@schoenig.me" }
  # s.source       = { git: '.'}
  s.source       = { :git => "https://github.com/nighthawk/ASWeekSelectorView.git", :tag => "#{s.version}" }
  s.platform     = :ios, '10.0'
  s.source_files = [
    'Sources/**/*.{h,m}'
  ]
  s.resource_bundles = { "ASWeekSelectorView" => "Sources/ASWeekSelectorView/Resources/*" }
  s.requires_arc = true
end
