# JHKVideoPlayer

[![CI Status](http://img.shields.io/travis/dinghanqing/JHKVideoPlayer.svg?style=flat)](https://travis-ci.org/dinghanqing/JHKVideoPlayer)
[![Version](https://img.shields.io/cocoapods/v/JHKVideoPlayer.svg?style=flat)](http://cocoapods.org/pods/JHKVideoPlayer)
[![License](https://img.shields.io/cocoapods/l/JHKVideoPlayer.svg?style=flat)](http://cocoapods.org/pods/JHKVideoPlayer)
[![Platform](https://img.shields.io/cocoapods/p/JHKVideoPlayer.svg?style=flat)](http://cocoapods.org/pods/JHKVideoPlayer)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

JHKVideoPlayer is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "JHKVideoPlayer"
```

## Usage

JHKVideoPlayer provides two overload init methods.

First with frame as parameter:
```Swift
JHKVideoPlayer(frame: CGRect)
```

Second with url as parameter:
```Swift
JHKVideoPlayer(url: String)
```

Also you can provide default settings:

1.autoHideMenu - Whether hide menu if not detect user intereaction in determined time period;

2.autoStartPlay - Whether start playing video after interrupt or at loading finished;

## Delegate

To setisfied custom response to buttons, you should implement JHKPlayerActionsDelegate.
It's supposed to achieve that by Swift syntax such as:
```Swift
extension JHKPlayerActionsDelegate where Self: 'Replace_By_Your_File' {
	func breakPointLisenter(time: Float) {
	}
}
```

## Author

dinghanqing, dinghanqing@hisense.com

## License

JHKVideoPlayer is available under the MIT license. See the LICENSE file for more info.
