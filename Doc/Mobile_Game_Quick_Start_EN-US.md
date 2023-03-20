[中文文档](手游接入说明.md)  
**GS Native SDK for iOS (Object-C)**
# I. Framework Component Description
- TCGSDK.framework: The cloud game business library
- TWEBRTC.framework: The basic communication capabilities library<br>

# II. TCGSDK Use Instructions
## 1. The SDK supports both PC and mobile games
The TCGSDK can run both mobile and PC games in the cloud but doesn't identify the game type by itself. The business layer needs to identify the game type when pulling the game. The features of `TCGGamePlayer` and `TCGGameController` classes are reusable.

Difference 1: The control class for PC games is `TCGDefaultMouseCursor`, while for mobile games is `TCGRemoteTouchScreen`.

Difference 2: `gamePlayer.videoView` for PC games is fixed in landscape mode, while for mobile games is fixed at portrait mode.

The business layer decides on the control class to be used based on the game type after the game is started.
*Note: Some APIs are only compatible with PC games, such as the API for querying the cloud keyboard letter case.*

## 2. Overview of key classes
### a. TCGGamePlayer
It is the base cloud game class, which provides cloud game capabilities.<br>
Register `TCGGamePlayerDelegate` to listen for the callbacks for the cloud game lifecycle events.<br>
`gamePlayer.videoView` is the video rendering layer created during the initialization of `TCGGamePlayer`.
### b. TCGGameController
It is the cloud game control feature class, which provides keyboard, mouse, and virtual controller capabilities.<br>
Register *TCGGameControllerDelegate* to listen for the callbacks for cloud game control events.
### c. TCGRemoteTouchScreen (mobile game control class)
It is the default cloud touchscreen mapping class of the SDK, which maps local touch events to cloud phones.<br>


## 3. Overview of key processes
### a. Create `TCGGamePlayer` to initialize the local multimedia capabilities
```objectivec
[[TCGGamePlayer alloc] initWithParams:nil andDelegate:self]
// Set the connection timeout period.
[self.gamePlayer setConnectTimeout:10]; 
// Set the output bitrate range and frame rate of cloud video encoding.
[self.gamePlayer setStreamBitrateMix:1000 max:3000 fps:30]; 
```
Implement the listener API of the delegate, get the local session information, and apply to the backend for `remoteSession`.
```objectivec
- (void)onInitSuccess:(NSString *)localSession;
```

### b. Get the `remoteSession` returned by the backend and connect to the cloud to start the game
```objectivec
[self.gamePlayer startGameWithRemoteSession:remoteSession error:&err]
```

### c. Listen for the callback for a successful connection of *TCGGameControllerDelegate*
```objectivec
- (void)onVideoSizeChanged:(CGSize)videoSize {
    // Set a correct size of the video source image, so that the cursor coordinates can be converted to the correct values.
    [self.mouseCursor setVideoSize:videoSize];
}

// Frame rendering of the video stream (including the first frame rendering after reconnection) started.
- (void)onVideoShow {

}
```

### d. Listen for the callback for automatic reconnection
```objectivec
- (void)onStartReConnectWithReason:(TCGErrorType)reason {
    NSLog(@"A connection error occurred, and the system tried reconnection. The disconnection cause is: %zd", reason);
}
```
The SDK will try reconnection three times in the following cases:
- When the application is switched to the background, iOS will reclaim the socket resources, and the connection between the underlying layer and the cloud will be closed immediately. Then, the application is activated again.
- When a network exception occurs, the connection may close.
- The connection is normal, but callbacks for video frames haven't been received for a certain period of time.

After the reconnection, you need to configure peripheral devices such as controller and keyboard again.<br>
*Note: If the cloud is disconnected for over 90 seconds, it will release the resources.*


### e. Log APIs
```objectivec
// Set the log delegate and the lowest log filter level.
[TCGGamePlayer setLogger:self withMinLevel:TCGLogLevelError];

// Receive the log callback of the SDK.
- (void)logWithLevel:(TCGLogLevel)logLevel log:(NSString *)log {
    NSLog(@"%d, %@", logLevel, log);
}
```

## 4. How to use the *TCGRemoteTouchScreen* cloud touchscreen class
Derived from the base class **UIView**, *TCGRemoteTouchScreen* maps the player's screen touch operations to the cloud phone screen and sends relevant events to the cloud through *TCGGameController*.

### a. Create a view
The cloud touchscreen view must be used as a subview of *gamePlayer.videoView* with the same size and position.
```objectivec
self.mobileTouch = [[TCGRemoteTouchScreen alloc] initWithFrame:self.gamePlayer.videoView.bounds
                                                    controller:self.gameController];
[self.gamePlayer.videoView addSubview:self.mobileTouch];
```

## 5. How to process the landscape/portrait mode
The mobile game video image is fixed in the portrait mode (the resolution width is less than the height).

### a. If `ViewController` is in portrait mode during creation
Create the frame of `videoView` normally and align it with the screen at the aspect ratio of the video.

### b. If `ViewController` is in landscape mode during creation
As the mobile game video image is fixed in portrait mode, `videoView` needs to be rotated by 90 degrees counterclockwise to be displayed normally. In addition, when `videoView` is created, its width and height need to be aligned with the height and width of `VC.view` respectively as follows:
```objectivec
- (void)resetGamePlayViewWithSize:(CGSize)videoSize {
    UIInterfaceOrientation vcOrient = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat newWidth = 0;
    CGFloat newHeight = 0;
    if (vcOrient == UIInterfaceOrientationPortrait) {
        newWidth = self.view.frame.size.width;
        newHeight = self.view.frame.size.height;
        newHeight -= [self.view safeAreaInsets].top + [self.view safeAreaInsets].bottom;
    } else if (vcOrient == UIInterfaceOrientationLandscapeRight) {
        // The mobile game video image is fixed in portrait mode (the width is less than the height). If the mobile phone is in landscape mode, you need to rotate the image of `videoView` by 90 degrees counterclockwise.
        newWidth = self.view.frame.size.height;
        newHeight = self.view.frame.size.width;
        newHeight -= [self.view safeAreaInsets].left + [self.view safeAreaInsets].right;
    }

    // The game image is converted to the landscape mode forcibly. The long sides are aligned, and the short sides are scaled proportionally with empty spaces. You can consider creating `subview` after `viewSafeAreaInsetsDidChange`.
    newWidth -= [self.view safeAreaInsets].left + [self.view safeAreaInsets].right;
    if (newWidth/newHeight < videoSize.width/videoSize.height) {
        newHeight = floor(newWidth * videoSize.height / videoSize.width);
    } else {
        newWidth = floor(newHeight * videoSize.width / videoSize.height);
    }

    self.videoRenderFrame = CGRectMake((self.view.frame.size.width - newWidth) / 2,
                                       (self.view.frame.size.height - newHeight) / 2,
                                       newWidth, newHeight);
    [self.gamePlayer.videoView setFrame:self.videoRenderFrame];
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
        // If the mobile phone is in landscape mode, you need to rotate the image of `videoView` by 90 degrees counterclockwise.
        self.gamePlayer.videoView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_2);
    }
}
```

### c. Listen for the change in the cloud phone orientation
Although the mobile game video image is fixed in portrait mode (where the resolution width is less than height), the game image in landscape mode may still be shown. You can listen for `TCGGamePlayerDelegate onVideoOrientationChanged` to get the change in the image content orientation.

You can also call the `TCGGamePlayer.videoOrientation` API to query the current orientation.
