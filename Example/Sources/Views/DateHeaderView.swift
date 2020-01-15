//
//  DateHeaderView.swift
//  ChatExample
//
//  Copyright © 2020 MessageKit. All rights reserved.
//

import Foundation
import UIKit
import MessageKit

class DateHeaderView: MessageReusableView {
  
  // MARK: - Private Properties
  private static let attributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.hiraKakuW6(size: 10),
    .foregroundColor: UIColor.white
  ]
  private static let insets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

  private var label: UILabel!

  // MARK: - Public Methods
  static var height: CGFloat {
    return insets.top + insets.bottom + 24
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    createUI()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    createUI()
  }

    /// Setup the receiver with text.
    ///
  /// - Parameter text: The text to be displayed.
  func setup(with text: String) {
    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont.hiraKakuW6(size: 10),
      .foregroundColor: UIColor.white
    ]
    label.attributedText = NSAttributedString(string: text, attributes: attributes)
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    label.attributedText = nil
  }

  // MARK: - Private Methods
  private func createUI() {
    let insets = DateHeaderView.insets
    let frame = bounds.inset(by: insets)
    label = UILabel(frame: frame)
    label.preferredMaxLayoutWidth = frame.width
    label.numberOfLines = 1
    label.textAlignment = .center
    label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    label.backgroundColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
    label.layer.cornerRadius = 13
    label.clipsToBounds = true
    addSubview(label)
  }
}
