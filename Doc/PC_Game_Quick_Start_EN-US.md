[中文文档](端游接入说明.md)  
**GS Native SDK for iOS (Object-C)**
# I. Framework Component Description
- TCGSDK.framework: The cloud game business library
- TWEBRTC.framework: The basic communication capabilities library<br>

# II. TCGSDK Use Instructions

## 1. Overview of key classes
### a. TCGGamePlayer
The base cloud game class, which provides cloud game capabilities.<br>
Register `TCGGamePlayerDelegate` to listen for the callbacks for the cloud game lifecycle events.<br>
`gamePlayer.videoView` is the video rendering layer created during the initialization of `TCGGamePlayer`.
### b. TCGGameController
The cloud game control feature class, which provides keyboard, mouse, and virtual controller capabilities.<br>
Register *TCGGameControllerDelegate* to listen for the callbacks for cloud game control events.
### c. TCGDefaultMouseCursor
The default mouse implementation class of the SDK, which provides capabilities for controlling a cloud PC mouse on a mobile touchscreen.<br>
End users can click the screen to trigger a mouse click event, move a finger on the screen to control the cursor movement, and also drag and drop the mouse.

## 2. Overview of key processes
### a. Create `TCGGamePlayer` to initialize the local multimedia capabilities
```objectivec
[[TCGGamePlayer alloc] initWithParams:nil andDelegate:self]
// Set the connection timeout period.
[self.gamePlayer setConnectTimeout:10]; 
// Set the output bitrate range and frame rate of cloud video encoding.
[self.gamePlayer setStreamBitrateMix:1 max:2 fps:30]; 
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
    // Notify the cloud to connect to the virtual controller.
    [self.gameController enableVirtualGamePad:YES];
    // Set the rendering mode of the cloud cursor and show the cursor.
    [self.gameController setCursorShowMode:TCGMouseCursorShowMode_Local];
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
- When the connection is normal, but callbacks for video frames haven't been received for a certain period of time.

After the reconnection, you need to configure peripheral devices such as controller and keyboard again.<br>
*Note: If the cloud is disconnected for over 90 seconds, it will release the resources.*

### e. Pause/Resume the game
```objectivec
[gamePlayer pauseResumeGame:YES];    // Pause the game.
[gamePlayer pauseResumeGame:NO];    // Resume the game.
```
When the user pauses the game, the SDK will remain connected to the cloud, and the cloud will pause delivering the audio/video data.<br>
*Note: The game process doesn't pause, and the SDK doesn't disconnect from the cloud. If the SDK is disconnected due to network problems or other issues, automatic reconnection won't be triggered.*

### f. Configure log APIs
```objectivec
// Set the log delegate and the lowest log filter level.
[TCGGamePlayer setLogger:self withMinLevel:TCGLogLevelError];

// Receive the log callback of the SDK.
- (void)logWithLevel:(TCGLogLevel)logLevel log:(NSString *)log {
    NSLog(@"%d, %@", logLevel, log);
}
```

## 3. How to use the default mouse class *TCGDefaultMouseCursor*
Derived from the base class **UIView**, *TCGDefaultMouseCursor* converts the player's screen touch operations to mouse instructions that can be recognized by the cloud and sends them to the cloud through *TCGGameController*.

### a. Create a view
The size and position of the mouse view must be the same as those of the video view *gamePlayer.videoView*.

### b. Set the touch mode as well as the image and size of the initial cursor
```objectivec
typedef NS_ENUM(NSInteger, TCGMouseCursorTouchMode) {
    /** The cursor moves with the finger, and clicking the screen triggers a mouse button click. */
    TCGMouseCursorTouchMode_AbsoluteTouch = 0,
    /** Moving the finger on the screen controls the relative movement of the cursor.
     * Touching the screen triggers a left mouse button click.
     * Pressing and holding the screen triggers a left mouse button click, and dragging is supported.
     * Moving the finger on the screen only triggers a cursor movement.
    **/
    TCGMouseCursorTouchMode_RelativeTouch = 1,
    /** Moving the finger on the screen makes the cursor move at the relative position without triggering any click events. */
    TCGMouseCursorTouchMode_RelativeOnly = 2
};

[self.mouseCursor setCursorTouchMode:TCGMouseCursorTouchMode_RelativeTouch];
[self.mouseCursor setCursorImage:[UIImage imageNamed:@"default_cursor"] andRemoteFrame:CGRectMake(0, 0, 32, 32)];
```

### c. Set the rendering mode after successful connection to the cloud
```objectivec
typedef NS_ENUM(NSInteger, TCGMouseCursorShowMode) {
    /** The client renders the cursor on its own. **/
    TCGMouseCursorShowMode_Custom = 0,
    /** The cloud distributes the cursor image for local rendering by the client. **/
    TCGMouseCursorShowMode_Local = 1,
    /** The cursor image is rendered within the cloud image. **/
    TCGMouseCursorShowMode_Remote = 2
};

// We recommend you use the local rendering mode.
[self.gameController setCursorShowMode:TCGMouseCursorShowMode_Local];

```
*Note: If the connection is closed due to an exception, you need to set the rendering mode again after automatic reconnection succeeds.*

### d. Listen for the callback to update the cursor image and visibility in real time
```objectivec
- (void)onCursorImageUpdated:(UIImage *)image frame:(CGRect)imageFrame {
    // `imageFrame.origin` is the offset value relative to the top point of the current cursor.
    [self.mouseCursor setCursorImage:image andRemoteFrame:imageFrame];
}

- (void)onCursorVisibleChanged:(BOOL)isVisble {
    [self.mouseCursor setCursorIsShow:isVisble];
}
```
