[中文文档](外设交互处理.md)

# Introduction
The client App can send peripheral events such as keyboard, mouse, gamepad, and touch events to the cloud system through the SDK. The interaction process between the front and back ends can be found in this [link](https://cloud.tencent.com/document/product/1547/102297).

# Basic Usage

## Keyboard Events
The client can obtain the `Keyboard` object through `TcrSession#getKeyboard()` and send any key press and release events of the keyboard to the cloud. The KeyCode specification for the Windows keyboard can be found in this [link](https://www.toptal.com/developers/keycode).

## Mouse Events
The client can obtain the `Mouse` object through `TcrSession#getMouse()` and send mouse left and right button press, release, and movement events, as well as mouse middle button wheel events to the cloud.

## Gamepad Events
If the cloud application supports gamepad operation (e.g., gamepad games), the client can obtain the `Gamepad` object through `TcrSession#getGamepad()` and send any gamepad key press and release events to the cloud. To trigger the connection and disconnection events of the gamepad on the cloud side, you can call the `Gamepad#connectGamepad()` and `Gamepad#disconnectGamepad()` methods.

## Touch Events
Both mobile applications (Android system) and desktop applications (Windows system) in the cloud can support touch screen operation. When the cloud application supports touch screen operation, the client can obtain the `TouchScreen` object through `TcrSession#getTouchScreen()` and send touch events to the cloud.

# Touch to Peripheral Events
If you use the SDK-provided `TcrRenderView` view for rendering, we also provide some default implementation classes for the touch events on this view, which can easily convert client touch events into cloud peripheral events and send them to the cloud, such as mapping the click events on the client touch screen to the click events of the cloud mouse. This is suitable for most customers to use without complex development.

## MobileTouchView

### Default Behavior
This class is used to automatically convert touch events triggered on the rendering view into touch events on the cloud touch screen and send them to the cloud.

### Usage
Create an instance of this object and add the touch view through `TcrRenderView#addSubView(MobileTouchView)`, for example:

```
[self.renderView addSubview:self.mobileTouchView];
```

## PcTouchView
### Default Behavior
Set the operation response mode through PctouchView#setCursorTouchMode
- TCRMouseCursorTouchMode_AbsoluteTouch 
   Single-finger short press: When the user presses down on the `TcrRenderView`, the left mouse button press event is sent to the cloud, and when the user releases, the left mouse button release event is sent to the cloud.
   Single-finger movement: Click on the point on the view, and map it to the corresponding mouse position on the Windows screen.
- TCRMouseCursorTouchMode_RelativeTouch 
   Single-finger long press: When the user presses down on the `TcrRenderView`, the left mouse button press event is sent to the cloud, and when the user releases, the left mouse button release event is sent to the cloud.
   Single-finger movement: When the user moves on the `PcTouchView`, the mouse movement event is sent to the cloud.
- Two-finger operation: When the user pinches with two fingers on the `TcrRenderView`, the view can be scaled; when the user translates with two fingers, the view can be dragged, and this operation will not send any events to the cloud.

### Usage
Create an instance of this object and add the touch view through `TcrRenderView#addSubView(PcTouchView)`, for example:

```
[self.renderView addSubview:self.pcTouchView];
```