# `ASWeekSelectorView`

[![CocoaPod badge w/ platform](http://cocoapod-badges.herokuapp.com/p/ASWeekSelectorView/badge.png)](http://cocoadocs.org/docsets/ASWeekSelectorView)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/nighthawk/ASWeekSelectorView?display_name=tag&label=spm)
[![CocoaPod badge w/ version](http://cocoapod-badges.herokuapp.com/v/ASWeekSelectorView/badge.png)](http://cocoadocs.org/docsets/ASWeekSelectorView)
![GitHub all releases](https://img.shields.io/github/downloads/nighthawk/ASWeekSelectorView/total)

A mini week view to select a day. You can swipe through weeks and tap on a day to select them, somewhat similar to the iOS calendar app (since iOS 7).
 
It's using the methodology described in Apple's excellent WWDC 2011 session 104 "Advanced ScrollView Techniques".

![Week selector](https://github.com/nighthawk/ASWeekSelectorView/raw/main/weekpicker.gif)

# Setup

1) Add to your project.

Using Swift Package Manager:

```swift
.package(url: "https://github.com/nighthawk/ASWeekSelectorView.git", from: "1.0.0")
```

Using Cocoapods:

```ruby
pod 'ASWeekSelectorView', '~> 1.0'
```

2) Add an instance of `ASWeekSelectorView` to your view hierarchy, configure it, provide a delegate and implement the delegate smethod. (Note that you won't need to use `ASDaySelectionView` and `ASSingleWeekView` yourself - they are internal helper class.)

3) When using Auto Layout, adjust the frame in `viewWillLayoutSubviews`:

```swift
override func viewWillLayoutSubviews() {
  super.viewWillLayoutSubviews()
  weekSelector.frame.size.width = self.view.frame.width
}
```

```objective-c
- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  
  CGRect frame = self.weekSelector.frame;
  frame.size.width = CGRectGetWidth(self.view.frame);
  self.weekSelector.frame = frame;
}
```


# Example

See the included example project for a very basic implementation.
