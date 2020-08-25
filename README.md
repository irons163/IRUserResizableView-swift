![Build Status](https://img.shields.io/badge/build-%20passing%20-brightgreen.svg)
![Platform](https://img.shields.io/badge/Platform-%20iOS%20-blue.svg)

# IRUserResizableView-swift 

- IRUserResizableView-swift is a powerful resizable view for iOS.
- IRUserResizableView-swift is modeled after the resizable image view from the Pages iOS app. Any UIView can be provided as the content view for the IRUserResizableView-swift. As the view is respositioned and resized, setFrame: will be called on the content view accordingly.

## Features
- Resizable.

## Install
### Git
- Git clone this project.
- Copy this project into your own project.
- Add the .xcodeproj into you  project and link it as embed framework.
#### Options
- You can remove the `demo` and `ScreenShots` folder.

### Cocoapods
- Not support yet.

## Usage

### Basic
``` swift
import IRUserResizableView_swift

...

override func viewDidLoad() {
    super.viewDidLoad()

    let appFrame = UIScreen.main.bounds
    self.view = UIView.init(frame: appFrame);
    self.view.backgroundColor = .green;

    // (1) Create a user resizable view with a simple red background content view.
    let gripFrame = CGRect.init(x: 50, y: 50, width: 200, height: 150)
    let userResizableView = IRUserResizableView.init(frame: gripFrame)
    let contentView = UIView.init(frame: gripFrame);
    contentView.backgroundColor = .red;
    userResizableView.contentView = contentView;
    userResizableView.delegate = self;
    userResizableView.showEditingHandles()
    self.view.addSubview(userResizableView)
}
```

If you'd like to receive callbacks when the IRUserResizableView-swift receives touchBegan:, touchesEnded: and touchesCancelled: messages, set the delegate on the IRUserResizableView-swift accordingly. 

``` swift
userResizableView.delegate = self
```

Then implement the following delegate methods.

``` swift
func userResizableViewDidBeginEditing(userResizableView: IRUserResizableView)
func userResizableViewDidEndEditing(userResizableView: IRUserResizableView)
```

By default, IRUserResizableView-swift will show the editing handles (as seen in the screenshot above) whenever it receives a touch event. The editing handles will remain visible even after the userResizableViewDidEndEditing: message is sent. This is to provide visual feedback to the user that the view is indeed moveable and resizable. If you'd like to dismiss the editing handles, you must explicitly call -hideEditingHandles.

The IRUserResizableView-swift is customizable using the following properties:

``` swift
var minWidth: CGFloat = 0.0
var minHeight: CGFloat = 0.0
var preventsPositionOutsideSuperview: Bool?
```

For an example of how to use IRUserResizableView-swift, please see the included example project.


## Screenshots
![Demo](./ScreenShots/demo1.png)

## Copyright
##### This project is inspired from [SPUserResizableView](https://github.com/spoletto/SPUserResizableView).
