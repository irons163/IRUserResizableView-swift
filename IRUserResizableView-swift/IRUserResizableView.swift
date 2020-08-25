//
//  IRUserResizableView.swift
//  IRUserResizableView-swift
//
//  Created by Phil on 2020/8/24.
//  Copyright © 2020 Phil. All rights reserved.
//

import Foundation
import UIKit
//import SPGripViewBorderView

public protocol IRUserResizableViewDelegate: NSObjectProtocol {
    // Called when the resizable view receives touchesBegan: and activates the editing handles.
    func userResizableViewDidBeginEditing(userResizableView: IRUserResizableView)

    // Called when the resizable view receives touchesEnded: or touchesCancelled:
    func userResizableViewDidEndEditing(userResizableView: IRUserResizableView)
}

struct IRUserResizableViewAnchorPoint {
    var adjustsX: Float
    var adjustsY: Float
    var adjustsH: Float
    var adjustsW: Float
}

public class IRUserResizableView: UIView {
    
    public weak var delegate: IRUserResizableViewDelegate?
    var borderView: SPGripViewBorderView?
    var touchStart: CGPoint?
    // Used to determine which components of the bounds we'll be modifying, based upon where the user's touch started.
    var anchorPoint: IRUserResizableViewAnchorPoint?
    
    // Will be retained as a subview.
    public weak var contentView: UIView? {
        didSet {
            contentView?.removeFromSuperview()
            contentView!.frame = self.bounds.insetBy(dx: CGFloat(kIRUserResizableViewGlobalInset + kIRUserResizableViewInteractiveBorderSize/2), dy: CGFloat(kIRUserResizableViewGlobalInset + kIRUserResizableViewInteractiveBorderSize/2))
            self.addSubview(contentView!)

            // Ensure the border view is always on top by removing it and adding it to the end of the subview list.
            borderView!.removeFromSuperview()
            self.addSubview(borderView!)
        }
    }

    // Default is 48.0 for each.
    var minWidth: CGFloat = 0.0
    var minHeight: CGFloat = 0.0

    // Defaults to YES. Disables the user from dragging the view outside the parent view's bounds.
    var preventsPositionOutsideSuperview: Bool?
    
    func userResizableViewDidBeginEditing(_ userResizableView: IRUserResizableView) -> () {
        
    }
    
    public func hideEditingHandles() {
        borderView!.isHidden = false
    }
    
    public func showEditingHandles() {
        borderView!.isHidden = true
    }
    
    
    func setupDefaultAttributes() {
        borderView = SPGripViewBorderView.init(frame: self.bounds.insetBy(dx: CGFloat(kIRUserResizableViewGlobalInset), dy: CGFloat(kIRUserResizableViewGlobalInset)))
        borderView!.isHidden = true
        self.addSubview(borderView!)
        self.minWidth = CGFloat(kIRUserResizableViewDefaultMinWidth)
        self.minHeight = CGFloat(kIRUserResizableViewDefaultMinHeight)
        self.preventsPositionOutsideSuperview = true
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupDefaultAttributes()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupDefaultAttributes()
    }

    public override var frame: CGRect {
        didSet {
            let newFrame = frame;
            super.frame = newFrame
            if (contentView != nil) {
                contentView!.frame = self.bounds.insetBy(dx: CGFloat(kIRUserResizableViewGlobalInset + kIRUserResizableViewInteractiveBorderSize/2), dy: CGFloat(kIRUserResizableViewGlobalInset + kIRUserResizableViewInteractiveBorderSize/2));
                borderView!.frame = self.bounds.insetBy(dx: CGFloat(kIRUserResizableViewGlobalInset), dy: CGFloat(kIRUserResizableViewGlobalInset));
                borderView!.setNeedsDisplay()
            }
        }
    }

    static func SPDistanceBetweenTwoPoints(point1: CGPoint, point2: CGPoint) -> CGFloat {
        let dx = point2.x - point1.x;
        let dy = point2.y - point1.y;
        return sqrt(dx*dx + dy*dy);
    };

    struct CGPointIRUserResizableViewAnchorPointPair {
        var point: CGPoint
        var anchorPoint: IRUserResizableViewAnchorPoint
    }

    func anchorPointForTouchLocation(touchPoint: CGPoint) -> IRUserResizableViewAnchorPoint {
        // (1) Calculate the positions of each of the anchor points.
        let upperLeft: CGPointIRUserResizableViewAnchorPointPair = CGPointIRUserResizableViewAnchorPointPair.init(point: CGPoint.init(x: 0.0, y: 0.0), anchorPoint: IRUserResizableViewUpperLeftAnchorPoint)
        let upperMiddle: CGPointIRUserResizableViewAnchorPointPair = CGPointIRUserResizableViewAnchorPointPair.init(point: CGPoint.init(x: self.bounds.size.width/2, y: 0.0), anchorPoint: IRUserResizableViewUpperMiddleAnchorPoint)
        let upperRight: CGPointIRUserResizableViewAnchorPointPair = CGPointIRUserResizableViewAnchorPointPair.init(point: CGPoint.init(x: self.bounds.size.width, y: 0.0), anchorPoint: IRUserResizableViewUpperRightAnchorPoint)
        let middleRight: CGPointIRUserResizableViewAnchorPointPair = CGPointIRUserResizableViewAnchorPointPair.init(point: CGPoint.init(x: self.bounds.size.width, y: self.bounds.size.height/2), anchorPoint: IRUserResizableViewMiddleRightAnchorPoint)
        let lowerRight: CGPointIRUserResizableViewAnchorPointPair = CGPointIRUserResizableViewAnchorPointPair.init(point: CGPoint.init(x: self.bounds.size.width, y: self.bounds.size.height), anchorPoint: IRUserResizableViewLowerRightAnchorPoint)
        let lowerMiddle: CGPointIRUserResizableViewAnchorPointPair = CGPointIRUserResizableViewAnchorPointPair.init(point: CGPoint.init(x: self.bounds.size.width/2, y: self.bounds.size.height), anchorPoint: IRUserResizableViewLowerMiddleAnchorPoint)
        let lowerLeft: CGPointIRUserResizableViewAnchorPointPair = CGPointIRUserResizableViewAnchorPointPair.init(point: CGPoint.init(x: 0, y: self.bounds.size.height), anchorPoint: IRUserResizableViewLowerLeftAnchorPoint)
        let middleLeft: CGPointIRUserResizableViewAnchorPointPair = CGPointIRUserResizableViewAnchorPointPair.init(point: CGPoint.init(x: 0, y: self.bounds.size.height/2), anchorPoint: IRUserResizableViewMiddleLeftAnchorPoint)
        let centerPoint: CGPointIRUserResizableViewAnchorPointPair = CGPointIRUserResizableViewAnchorPointPair.init(point: CGPoint.init(x: self.bounds.size.width/2, y: self.bounds.size.height/2), anchorPoint: IRUserResizableViewNoResizeAnchorPoint)
        
        // (2) Iterate over each of the anchor points and find the one closest to the user's touch.
        let allPoints: [CGPointIRUserResizableViewAnchorPointPair] = [ upperLeft, upperRight, lowerRight, lowerLeft, upperMiddle, lowerMiddle, middleLeft, middleRight, centerPoint ]
        var smallestDistance: CGFloat = CGFloat(MAXFLOAT)
        var closestPoint: CGPointIRUserResizableViewAnchorPointPair = centerPoint
        for i in 0..<9 {
            let distance: CGFloat = IRUserResizableView.SPDistanceBetweenTwoPoints(point1: touchPoint, point2: allPoints[i].point);
            if (distance < smallestDistance) {
                closestPoint = allPoints[i];
                smallestDistance = distance;
            }
        }
        return closestPoint.anchorPoint;
    }

    func isResizing() -> Bool {
        return (anchorPoint!.adjustsH != 0 || anchorPoint!.adjustsW != 0 || anchorPoint!.adjustsX != 0 || anchorPoint!.adjustsY != 0);
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Notify the delegate we've begun our editing session.
        if (self.delegate != nil  && self.delegate!.responds(to: Selector(("userResizableViewDidBeginEditing")))) {
            self.delegate?.userResizableViewDidBeginEditing(userResizableView: self)
        }
        
        borderView!.isHidden = false
        let touch: UITouch = touches.first!;
        anchorPoint = anchorPointForTouchLocation(touchPoint: touch.location(in: self))
        
        // When resizing, all calculations are done in the superview's coordinate space.
        touchStart = touch.location(in: self.superview)
        if (!self.isResizing()) {
            // When translating, all calculations are done in the view's coordinate space.
            touchStart = touch.location(in: self)
        }
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Notify the delegate we've ended our editing session.
        if (self.delegate != nil  && self.delegate!.responds(to: Selector(("userResizableViewDidEndEditing")))) {
            self.delegate?.userResizableViewDidEndEditing(userResizableView: self)
        }
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Notify the delegate we've ended our editing session.
        if (self.delegate != nil  && self.delegate!.responds(to: Selector(("userResizableViewDidEndEditing")))) {
            self.delegate?.userResizableViewDidEndEditing(userResizableView: self)
        }
    }

    func resizeUsingTouchLocation(touchPoint: CGPoint) {
        var touchPoint = touchPoint
        // (1) Update the touch point if we're outside the superview.
        if (self.preventsPositionOutsideSuperview!) {
            let border: CGFloat = CGFloat(kIRUserResizableViewGlobalInset + kIRUserResizableViewInteractiveBorderSize/2);
            if (touchPoint.x < border) {
                touchPoint.x = border;
            }
            if (touchPoint.x > self.superview!.bounds.size.width - border) {
                touchPoint.x = self.superview!.bounds.size.width - border;
            }
            if (touchPoint.y < border) {
                touchPoint.y = border;
            }
            if (touchPoint.y > self.superview!.bounds.size.height - border) {
                touchPoint.y = self.superview!.bounds.size.height - border;
            }
        }
        
        // (2) Calculate the deltas using the current anchor point.
        var deltaW: CGFloat = CGFloat(anchorPoint!.adjustsW) * (touchStart!.x - touchPoint.x);
        let deltaX: CGFloat = CGFloat(anchorPoint!.adjustsX) * (-1.0 * deltaW);
        var deltaH: CGFloat = CGFloat(anchorPoint!.adjustsH) * (touchPoint.y - touchStart!.y);
        let deltaY: CGFloat = CGFloat(anchorPoint!.adjustsY) * (-1.0 * deltaH);
        
        // (3) Calculate the new frame.
        var newX: CGFloat = self.frame.origin.x + deltaX;
        var newY: CGFloat = self.frame.origin.y + deltaY;
        var newWidth: CGFloat = self.frame.size.width + deltaW;
        var newHeight: CGFloat = self.frame.size.height + deltaH;
        
        // (4) If the new frame is too small, cancel the changes.
        if (newWidth < self.minWidth) {
            newWidth = self.frame.size.width;
            newX = self.frame.origin.x;
        }
        if (newHeight < self.minHeight) {
            newHeight = self.frame.size.height;
            newY = self.frame.origin.y;
        }
        
        // (5) Ensure the resize won't cause the view to move offscreen.
        if (self.preventsPositionOutsideSuperview!) {
            if (newX < self.superview!.bounds.origin.x) {
                // Calculate how much to grow the width by such that the new X coordintae will align with the superview.
                deltaW = self.frame.origin.x - self.superview!.bounds.origin.x;
                newWidth = self.frame.size.width + deltaW;
                newX = self.superview!.bounds.origin.x;
            }
            if (newX + newWidth > self.superview!.bounds.origin.x + self.superview!.bounds.size.width) {
                newWidth = self.superview!.bounds.size.width - newX;
            }
            if (newY < self.superview!.bounds.origin.y) {
                // Calculate how much to grow the height by such that the new Y coordintae will align with the superview.
                deltaH = self.frame.origin.y - self.superview!.bounds.origin.y;
                newHeight = self.frame.size.height + deltaH;
                newY = self.superview!.bounds.origin.y;
            }
            if (newY + newHeight > self.superview!.bounds.origin.y + self.superview!.bounds.size.height) {
                newHeight = self.superview!.bounds.size.height - newY;
            }
        }
        
        self.frame = CGRect.init(x: newX, y: newY, width: newWidth, height: newHeight)
        touchStart = touchPoint;
    }

    func translateUsingTouchLocation(touchPoint: CGPoint) {
        var newCenter: CGPoint = CGPoint.init(x: self.center.x + touchPoint.x - touchStart!.x, y: self.center.y + touchPoint.y - touchStart!.y)
        if (self.preventsPositionOutsideSuperview!) {
            // Ensure the translation won't cause the view to move offscreen.
            let midPointX: CGFloat = self.bounds.midX;
            if (newCenter.x > self.superview!.bounds.size.width - midPointX) {
                newCenter.x = self.superview!.bounds.size.width - midPointX;
            }
            if (newCenter.x < midPointX) {
                newCenter.x = midPointX;
            }
            let midPointY: CGFloat = self.bounds.midY;
            if (newCenter.y > self.superview!.bounds.size.height - midPointY) {
                newCenter.y = self.superview!.bounds.size.height - midPointY;
            }
            if (newCenter.y < midPointY) {
                newCenter.y = midPointY;
            }
        }
        self.center = newCenter;
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.isResizing()) {
            self.resizeUsingTouchLocation(touchPoint: (touches.first?.location(in: self.superview))!)
        } else {
            self.translateUsingTouchLocation(touchPoint: (touches.first?.location(in: self))!)
        }
    }
}

/* Let's inset everything that's drawn (the handles and the content view)
 so that users can trigger a resize from a few pixels outside of
 what they actually see as the bounding box. */
let kIRUserResizableViewGlobalInset = 5.0

let kIRUserResizableViewDefaultMinWidth = 48.0
let kIRUserResizableViewDefaultMinHeight = 48.0
let kIRUserResizableViewInteractiveBorderSize = 10.0

let IRUserResizableViewNoResizeAnchorPoint: IRUserResizableViewAnchorPoint = IRUserResizableViewAnchorPoint.init(adjustsX: 0.0, adjustsY: 0.0, adjustsH: 0.0, adjustsW: 0.0)
let IRUserResizableViewUpperLeftAnchorPoint: IRUserResizableViewAnchorPoint = IRUserResizableViewAnchorPoint.init(adjustsX: 1.0, adjustsY: 1.0, adjustsH: -1.0, adjustsW: 1.0)
let IRUserResizableViewMiddleLeftAnchorPoint: IRUserResizableViewAnchorPoint = IRUserResizableViewAnchorPoint.init(adjustsX: 1.0, adjustsY: 0.0, adjustsH: 0.0, adjustsW: 1.0)
let IRUserResizableViewLowerLeftAnchorPoint: IRUserResizableViewAnchorPoint = IRUserResizableViewAnchorPoint.init(adjustsX: 1.0, adjustsY: 0.0, adjustsH: 1.0, adjustsW: 0.0)
let IRUserResizableViewUpperMiddleAnchorPoint: IRUserResizableViewAnchorPoint = IRUserResizableViewAnchorPoint.init(adjustsX: 0.0, adjustsY: 1.0, adjustsH: -1.0, adjustsW: 0.0)
let IRUserResizableViewUpperRightAnchorPoint: IRUserResizableViewAnchorPoint = IRUserResizableViewAnchorPoint.init(adjustsX: 0.0, adjustsY: 1.0, adjustsH: -1.0, adjustsW: -1.0)
let IRUserResizableViewMiddleRightAnchorPoint: IRUserResizableViewAnchorPoint = IRUserResizableViewAnchorPoint.init(adjustsX: 0.0, adjustsY: 0.0, adjustsH: 0.0, adjustsW: -1.0)
let IRUserResizableViewLowerRightAnchorPoint: IRUserResizableViewAnchorPoint = IRUserResizableViewAnchorPoint.init(adjustsX: 0.0, adjustsY: 0.0, adjustsH: 1.0, adjustsW: -1.0)
let IRUserResizableViewLowerMiddleAnchorPoint: IRUserResizableViewAnchorPoint = IRUserResizableViewAnchorPoint.init(adjustsX: 0.0, adjustsY: 0.0, adjustsH: 1.0, adjustsW: 0.0)

class SPGripViewBorderView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context!.saveGState()
        
        // (1) Draw the bounding box.
        context!.setLineWidth(1.0);
        context!.setStrokeColor(UIColor.blue.cgColor);
        context!.addRect(self.bounds.insetBy(dx: CGFloat(kIRUserResizableViewInteractiveBorderSize/2), dy: CGFloat(kIRUserResizableViewInteractiveBorderSize/2)));
        context!.strokePath();
        
        // (2) Calculate the bounding boxes for each of the anchor points.
        let upperLeft = CGRect.init(x: 0.0, y: 0.0, width: kIRUserResizableViewInteractiveBorderSize, height: kIRUserResizableViewInteractiveBorderSize)
        let upperRight = CGRect.init(x: Double(self.bounds.size.width) - kIRUserResizableViewInteractiveBorderSize, y: 0.0, width: kIRUserResizableViewInteractiveBorderSize, height: kIRUserResizableViewInteractiveBorderSize)
        let lowerRight = CGRect.init(x: Double(self.bounds.size.width) - kIRUserResizableViewInteractiveBorderSize, y: Double(self.bounds.size.height) - kIRUserResizableViewInteractiveBorderSize, width: kIRUserResizableViewInteractiveBorderSize, height: kIRUserResizableViewInteractiveBorderSize)
        let lowerLeft = CGRect.init(x: 0.0, y: Double(self.bounds.size.height) - kIRUserResizableViewInteractiveBorderSize, width: kIRUserResizableViewInteractiveBorderSize, height: kIRUserResizableViewInteractiveBorderSize)
        let upperMiddle = CGRect.init(x: (Double(self.bounds.size.width) - kIRUserResizableViewInteractiveBorderSize)/2, y: 0.0, width: kIRUserResizableViewInteractiveBorderSize, height: kIRUserResizableViewInteractiveBorderSize)
        let lowerMiddle = CGRect.init(x: (Double(self.bounds.size.width) - kIRUserResizableViewInteractiveBorderSize)/2, y: Double(self.bounds.size.height) - kIRUserResizableViewInteractiveBorderSize, width: kIRUserResizableViewInteractiveBorderSize, height: kIRUserResizableViewInteractiveBorderSize)
        let middleLeft = CGRect.init(x: 0.0, y: (Double(self.bounds.size.height) - kIRUserResizableViewInteractiveBorderSize)/2, width: kIRUserResizableViewInteractiveBorderSize, height: kIRUserResizableViewInteractiveBorderSize)
        let middleRight = CGRect.init(x: Double(self.bounds.size.width) - kIRUserResizableViewInteractiveBorderSize, y: (Double(self.bounds.size.height) - kIRUserResizableViewInteractiveBorderSize)/2, width: kIRUserResizableViewInteractiveBorderSize, height: kIRUserResizableViewInteractiveBorderSize)
        
        // (3) Create the gradient to paint the anchor points.
        let colors: [CGFloat] = [
            0.4, 0.8, 1.0, 1.0,
            0.0, 0.0, 1.0, 1.0
        ]
        let baseSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB();
        let gradient: CGGradient = CGGradient(colorSpace: baseSpace, colorComponents: colors, locations: nil, count: 2)!;
        
        // (4) Set up the stroke for drawing the border of each of the anchor points.
        context!.setLineWidth(1);
        context!.setShadow(offset: CGSize.init(width: 0.5, height: 0.5), blur: 1);
        context!.setStrokeColor(UIColor.white.cgColor);
        
        // (5) Fill each anchor point using the gradient, then stroke the border.
        let allPoints: [CGRect] = [ upperLeft, upperRight, lowerRight, lowerLeft, upperMiddle, lowerMiddle, middleLeft, middleRight ]
        for i in 0...7 {
            let currPoint: CGRect = allPoints[i]
            context!.saveGState();
            context!.addEllipse(in: currPoint);
            context!.clip();
            let startPoint: CGPoint = CGPoint.init(x: currPoint.midX, y: currPoint.minY)
            let endPoint: CGPoint = CGPoint.init(x: currPoint.midX, y: currPoint.maxY)
            context!.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0));
            context!.restoreGState();
            context!.strokeEllipse(in: currPoint.insetBy(dx: 1, dy: 1));
        }
        context!.restoreGState();
    }
}
