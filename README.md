# JHKVideoPlayer

[![CI Status](http://img.shields.io/travis/dinghanqing/JHKVideoPlayer.svg?style=flat)](https://travis-ci.org/dinghanqing/JHKVideoPlayer)
[![Version](https://img.shields.io/cocoapods/v/JHKVideoPlayer.svg?style=flat)](http://cocoapods.org/pods/JHKVideoPlayer)
[![License](https://img.shields.io/cocoapods/l/JHKVideoPlayer.svg?style=flat)](http://cocoapods.org/pods/JHKVideoPlayer)
[![Platform](https://img.shields.io/cocoapods/p/JHKVideoPlayer.svg?style=flat)](http://cocoapods.org/pods/JHKVideoPlayer)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

From version0.1.3 it requires `Swift4/Xcode9` environment to compile sourcefile.  
In the meanwhile earlier version of JHKVideoPlayer use swift3.2 as default.

## Installation

JHKVideoPlayer is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "JHKVideoPlayer"
```

## Usage

### Initialize

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

1. autoHideMenu - Whether hide menu if not detect user intereaction in determined time period.
2. autoStartPlay - Whether start playing video after interrupt or at loading finished.
3. autoNext - Whether automatically trigger playNextAction after finish playing one media episode.
4. autoLandscape - Whether player is suport orientation screen.
5. fillMode - Content mode of player screen.

### Delegate

To setisfied custom response to buttons, you should implement JHKPlayerActionsDelegate.
It's supposed to achieve that by Swift syntax such as:
```Swift
extension JHKPlayerActionsDelegate where Self: 'Replace_By_Your_File' {
	func breakPointLisenter(time: Float) {
	}
}
```
I really suggest you to read file 'JHKPlayerTransport' carefully before use this cocoaPods component.  
Typically there are multiple actions you should defined for further implements.

```Swift
    /// Primary listener, providing top level user defined manipulation.
    ///
    /// - Parameter time: playing rate
    func breakPointListener(time: CGFloat)

    /// Event of start playing, called every time player status change to 'play', whether from 'stop' or 'pause'.
    func startPlayingListener()

    /// Event of failed loading media resources.
    func failLoadListener()

    /// Intereaction of click previous button.
    func playPreviousAction()

    /// Intereaction of click pause button.
    func playPauseAction()

    /// Intereaction of click next button.
    func playNextAction()

    /// Intereaction of click quit button.
    func playerQuitAction()

    /// Intereaction of click push-screen button.
    func pushScreenAction()

    /// Intereaction of click more-menu button.
    /// Return: - UIView you want to display on side menu.
    func moreMenuAction() -> UIView

    /// Intereaction of click definition button.
    func determinedDefinition() -> UIView
```

### Command

We provide some useful command to modify player status.

1. `JHKPlayer.lockPlayer(with warning: String, actions: [LockAction] = [])` - Lock player with provided message and `LockActions`. Tips: `LockAction` is a swift class simply copycat from UIKit.AlertAction.
2. `JHKPlayer.unlocakPlayer()` - Release player and continues playing media resources.
3. `JHKPlayer.startPoint` - Assign float value to this stored property would change the start playing point after media loading. Be careful, this would keep in round if you assgin that after playing and constained to next play action.

## Development

### Design
Whole module is Protocol-Oriented-Programmed, which means all principle is listed with clear protocol. There are three major part for the moment.

1. JHKPlayerActionDelegate - That's the customize handler determined by user. All functions and their parameters have detailed information in documents.
2. JHKPlayerGestureHandler - Both for developer and user, if you want to change default gesture response, simple make a instance obaying this protocol and make sure `JHKPlayerView.customizeGestureHandler` is equals to that.
3. JHKInternalTransport - It's the 'always-worked' interactions for UI response. Consider the difference with 4.
4. JHKPlayerClosure - It's the 'defer-load' interactions for internal operation. Designed for developer only. For example, no matter media failed loading or not, 'return button' should alway responds to applications' input. But 'drag slider' should only worked after playing.

## Author

dinghanqing, dinghanqing@hisense.com

## License

JHKVideoPlayer is available under the MIT license. See the LICENSE file for more info.
