//
//  UIFont+.swift
//  ChatExample
//
//  Copyright © 2020 MessageKit. All rights reserved.
//
import UIKit

extension UIFont {
  class func hiraKakuW3(size: CGFloat = 12) -> UIFont {
    return UIFont(name: "HiraKakuProN-W3", size: size) ?? UIFont.systemFont(ofSize: size)
  }

  class func hiraKakuW6(size: CGFloat = 12) -> UIFont {
    return UIFont(name: "HiraKakuProN-W6", size: size) ?? UIFont.systemFont(ofSize: size)
  }

  class func hiraginoSansW3(size: CGFloat = 12) -> UIFont {
    return UIFont(name: "HiraginoSans-W3", size: size) ?? UIFont.systemFont(ofSize: size)
  }

  class func hiraginoSansW6(size: CGFloat = 12) -> UIFont {
    return UIFont(name: "HiraginoSans-W6", size: size) ?? UIFont.systemFont(ofSize: size)
  }

  class func avenirNextMedium(size: CGFloat = 12) -> UIFont {
    return UIFont(name: "AvenirNext-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
  }
}
