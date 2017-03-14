//
//  TVOSToast.swift
//  TVOSToast
//
//  Created by Cem Olcay on 17/02/16.
//  Copyright Â© 2016 MovieLaLa. All rights reserved.
//

import UIKit
import ManualLayout

// MARK: - UIViewController Extension

public extension UIViewController {
    
    public func presentToast(toast: TVOSToast) {
        toast.presentOnView(view: self.view)
    }
}

// MARK: - NSAttributedString

public extension NSAttributedString {
    
    public convenience init(text: String, fontName: String, fontSize: CGFloat, color: UIColor) {
        let font = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        self.init(text: text, font: font, color: color)
    }
    
    public convenience init(text: String, font: UIFont, color: UIColor) {
        let attributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color
        ]
        self.init(string: text, attributes: attributes)
    }
    
    public convenience init(imageName: String, bounds: CGRect?, bundle: Bundle) {
        let textAttachment = NSTextAttachment()
        textAttachment.image = UIImage(named: imageName, in: bundle, compatibleWith: nil)
        if let bounds = bounds {
            textAttachment.bounds = bounds
        }
        self.init(attachment: textAttachment)
    }
    
    public convenience init(attributedStrings: NSAttributedString...) {
        let mutableAttributedString = NSMutableAttributedString()
        for attributedString in attributedStrings {
            mutableAttributedString.append(attributedString)
        }
        self.init(attributedString: mutableAttributedString)
    }
}

// MARK: - TVOSToastButtonType

public enum TVOSToastRemoteButtonType: String {
    case MenuBlack = "MenuBlack"
    case MenuWhite = "MenuWhite"
    case ScreenBlack = "ScreenBlack"
    case ScreenWhite = "ScreenWhite"
    case PlayPauseBlack = "PlayPauseBlack"
    case PlayPauseWhite = "PlayPauseWhite"
    case SiriBlack = "SiriBlack"
    case SiriWhite = "SiriWhite"
    case VolumeWhite = "VolumeWhite"
    case VolumeBlack = "VolumeBlack"
    
    private func getImageName() -> String {
        return "tvosToast\(rawValue).png"
    }
    
    public func getAttributedString(bounds: CGRect? = nil) -> NSAttributedString {
        return  NSAttributedString(imageName: self.getImageName(), bounds: bounds, bundle: Bundle(for: TVOSToast.self))
    }
}

// MARK: - TVOSToastHintText

public class TVOSToastHintText {
    
    public var elements: [Any]
    
    public init(elements: Any...) {
        self.elements = elements
    }
    
    public func buildAttributedString(font: UIFont, textColor: UIColor) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString()
        for element in elements {
            if let text = element as? String  {
                mutableAttributedString.append(NSAttributedString(text: text, font: font, color: textColor))
            } else if element is TVOSToastRemoteButtonType {
                let size = font.pointSize + 30
                mutableAttributedString.append((element as! TVOSToastRemoteButtonType)
                    .getAttributedString(bounds: CGRect(
                        x: 0,
                        y: -size/4,
                        width: size,
                        height: size)))
            }
        }
        return mutableAttributedString.mutableCopy() as! NSAttributedString
    }
}

// MARK: - Position

public enum TVOSToastPosition {
    case Top(insets: CGFloat)
    case TopLeft(insets: CGFloat)
    case TopRight(insets: CGFloat)
    case Bottom(insets: CGFloat)
    case BottomLeft(insets: CGFloat)
    case BottomRight(insets: CGFloat)
}

// MARK: - Style

public struct TVOSToastStyle {
    // presentation
    public var position: TVOSToastPosition?
    public var duration: TimeInterval?
    // appearance
    public var backgroundColor: UIColor?
    public var cornerRadius: CGFloat?
    // text style
    public var font: UIFont?
    public var textColor: UIColor?
    
    public init() {
        position = nil
        duration = nil
        backgroundColor = nil
        cornerRadius = nil
        font = nil
        textColor = nil
    }
}

// MARK: - Toast

public class TVOSToast: UIView {
    
    // MARK: Properties
    
    public var style: TVOSToastStyle = TVOSToastStyle()
    
    public var customContent: UIView?
    public var text: String?
    public var attributedText: NSAttributedString?
    public var hintText: TVOSToastHintText?
    
    private var customContentView: UIView?
    private var textLabel: UILabel?
    
    // MARK: Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public init(frame: CGRect, style: TVOSToastStyle) {
        super.init(frame: frame)
        self.style = style
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public func commonInit() {
        // content view
        customContentView = UIView(frame: frame)
        addSubview(customContentView!)
        // text
        textLabel = UILabel(frame: frame)
        textLabel?.numberOfLines = 0
        textLabel?.textAlignment = .center
        addSubview(textLabel!)
    }
    
    // MARK: Present
    
    public func presentOnView(view: UIView) {
        
        // get style
        let position = style.position ?? .Bottom(insets: 20)
        let duration = style.duration ?? 3
        let backgroundColor = style.backgroundColor ?? UIColor.gray
        let cornerRadius = style.cornerRadius ?? 10
        let font = style.font ?? UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        let textColor = style.textColor ?? UIColor.white
        
        // setup style
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadius
        self.alpha = 0
        view.addSubview(self)
        
        // setup text
        if let hintText = hintText {
            textLabel?.attributedText = hintText.buildAttributedString(font: font, textColor: textColor)
        } else if let attributedText = attributedText {
            textLabel?.attributedText = attributedText
        } else if let text = text {
            textLabel?.text = text
            textLabel?.textColor = textColor
            textLabel?.font = font
        }
        
        // setup custom content
        if let customContent = customContent {
            customContentView?.addSubview(customContent)
        }
        
        // setup position
        switch position {
        case .Top(let insets):
            top = insets
            centerX = view.width / 2
        case .TopLeft(let insets):
            top = insets
            left = insets
        case .TopRight(let insets):
            top = insets
            right = view.right - insets
        case .Bottom(let insets):
            bottom = view.bottom - insets
            centerX = view.width / 2
        case .BottomLeft(let insets):
            bottom = view.bottom - insets
            left = insets
        case .BottomRight(let insets):
            bottom = view.bottom - insets
            right = view.right - insets
        }
        
        // animate toast
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: .allowAnimatedContent,
                       animations: {
                        self.alpha = 1
        },
                       completion: { finished in
                        UIView.animate(withDuration: 0.3,
                                       delay: duration,
                                       usingSpringWithDamping: 1,
                                       initialSpringVelocity: 0,
                                       options: .allowAnimatedContent,
                                       animations: {
                                        self.alpha = 0
                        },
                                       completion: { finished in
                                        self.removeFromSuperview()
                        })
        })
    }
}
