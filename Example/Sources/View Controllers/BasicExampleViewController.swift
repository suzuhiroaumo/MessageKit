/*
 MIT License

 Copyright (c) 2017-2019 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit
import MapKit
import MessageKit

final class BasicExampleViewController: ChatViewController {
  let outgoingAvatarOverlap: CGFloat = 17.5

  override func viewDidLoad() {
    messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CustomMessagesFlowLayout())
    messagesCollectionView.register(CustomCell.self)
    messagesCollectionView.register(DateHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
    super.viewDidLoad()
  }

  override func configureMessageCollectionView() {
    super.configureMessageCollectionView()

    guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else {
      return
    }
    layout.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)

    // Hide the outgoing avatar and adjust the label alignment to line up with the messages
    layout.setMessageOutgoingAvatarSize(.zero)

    layout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: .zero))
    layout.setMessageOutgoingMessagePadding(UIEdgeInsets(top: 0, left: 12, bottom: 16, right: 16))

    // Set outgoing avatar to overlap with the message bubble
    layout.setMessageIncomingAvatarPosition(.init(vertical: .messageBottom))
    layout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 18, bottom: outgoingAvatarOverlap, right: 0)))
    layout.setMessageIncomingAvatarSize(CGSize(width: 30, height: 30))
    layout.setMessageIncomingMessagePadding(UIEdgeInsets(top: 0, left: 12, bottom: 16, right: 18))

    layout.setMessageIncomingAccessoryViewSize(CGSize(width: 36, height: 10))
    layout.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 8, right: 0))
    layout.setMessageIncomingAccessoryViewPosition(.messageBottom)

    layout.setMessageOutgoingAccessoryViewSize(CGSize(width: 36, height: 10))
    layout.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))
    layout.setMessageOutgoingAccessoryViewPosition(.messageBottom)

    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
  }

  // テキスト入力
  override func configureMessageInputBar() {
    super.configureMessageInputBar()

    messageInputBar.isTranslucent = true
    messageInputBar.separatorLine.isHidden = true
    messageInputBar.inputTextView.tintColor = UIColor.yellow
    messageInputBar.inputTextView.placeholder = ""
    messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
    messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
    messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
    messageInputBar.inputTextView.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
    messageInputBar.inputTextView.layer.borderWidth = 1.0
    messageInputBar.inputTextView.layer.cornerRadius = 16.0
    messageInputBar.inputTextView.layer.masksToBounds = true
    messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    configureInputBarItems()
  }

  // テキスト入力周りのアイテム(主に送信するボタン)
  private func configureInputBarItems() {
    messageInputBar.setRightStackViewWidthConstant(to: 64, animated: false)
    messageInputBar.sendButton.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
    messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    messageInputBar.sendButton.setSize(CGSize(width: 64, height: 36), animated: false)
    messageInputBar.sendButton.title = "送信する"
    messageInputBar.sendButton.setTitleColor(UIColor.yellow, for: .normal)
    messageInputBar.sendButton.setTitleColor(UIColor.yellow, for: .disabled)
    messageInputBar.middleContentViewPadding.right = -68
    messageInputBar.middleContentViewPadding.bottom = 8

    // This just adds some more flare
    messageInputBar.sendButton
      .onEnabled { item in
        UIView.animate(withDuration: 0.3, animations: {
          item.imageView?.backgroundColor = .primaryColor
        })
      }.onDisabled { item in
        UIView.animate(withDuration: 0.3, animations: {
          item.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
        })
      }
  }

  /// 送信者名のラベル
  /// - Parameters:
  ///   - message: message
  ///   - indexPath: パス
  override func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    return nil
  }

  override func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    return nil
  }
}

// MARK: - MessagesDisplayDelegate

extension BasicExampleViewController: MessagesDisplayDelegate {

  func messageHeaderView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView {
    let header = messagesCollectionView.dequeueReusableHeaderView(DateHeaderView.self, for: indexPath)
    guard indexPath.row == 0 else {
      return header
    }
    let message = messageForItem(at: indexPath, in: messagesCollectionView)

    let f = DateFormatter()
    f.dateFormat =  "yyyy/MM/dd(EEE)"
    f.locale = Locale(identifier: "ja_JP")

    let dateString = f.string(from: message.sentDate)

    header.setup(with: dateString)
    return header
  }

  // MARK: - Text Messages

  func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
    return isFromCurrentSender(message: message) ? .darkText : .darkText
  }

  func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
    switch detector {
    case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
    default: return MessageLabel.defaultAttributes
    }
  }

  func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
    return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
  }

  // MARK: - All Messages

  func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
    return isFromCurrentSender(message: message) ? UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1) : UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1)
  }

  func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

    // 角丸にするcorner
    var corners: UIRectCorner = []

    var isFromSelfSender = false

    if isFromCurrentSender(message: message) {
      corners.formUnion(.topLeft)
      corners.formUnion(.bottomLeft)
      corners.formUnion(.topRight)
      isFromSelfSender = true
    } else {
      corners.formUnion(.topRight)
      corners.formUnion(.bottomRight)
      corners.formUnion(.topLeft)
      isFromSelfSender = false
    }

    return .custom { view in
      /*
       if isFromSelfSender {
         view.layer.borderWidth = 0
         view.layer.masksToBounds = false
         view.layer.borderColor = UIColor.gray.cgColor
       } else {
         view.layer.borderWidth = 1
         view.layer.masksToBounds = false
         view.layer.borderColor = UIColor.gray.cgColor
       }
       */

      let radius: CGFloat = 16
      let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
      let mask = CAShapeLayer()
      path.addLine(to: CGPoint(x: 0.0, y: 100))
      UIColor.red.setFill()
      path.close()
      mask.path = path.cgPath
      view.layer.mask = mask
    }
  }

  func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
    let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
    avatarView.set(avatar: avatar)
  }

  func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
    let subViews = accessoryView.subviews
    for subView in subViews {
      subView.removeFromSuperview()
    }

    let f = DateFormatter()
    f.timeStyle = .short
    f.dateStyle = .none

    let dateLabel = UILabel()
    dateLabel.font = UIFont.hiraKakuW3(size: 10)
    if isFromCurrentSender(message: message) {
      dateLabel.textAlignment = .right
    } else {
      dateLabel.textAlignment = .left
    }

    dateLabel.frame = CGRect(x: 0, y: 0, width: 36, height: 10)
    let dateString = f.string(from: message.sentDate)
    dateLabel.text = dateString
    dateLabel.textColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)
    accessoryView.addSubview(dateLabel)
  }

  // MARK: - Location Messages

  func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
    let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
    let pinImage = #imageLiteral(resourceName: "ic_map_marker")
    annotationView.image = pinImage
    annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
    return annotationView
  }

  func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
    return { view in
      view.layer.transform = CATransform3DMakeScale(2, 2, 2)
      UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
        view.layer.transform = CATransform3DIdentity
      }, completion: nil)
    }
  }

  func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {

    return LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
  }

  // MARK: - Audio Messages

  func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
    return isFromCurrentSender(message: message) ? .white : UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
  }

  func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
    audioController.configureAudioCell(cell, message: message) // this is needed especily when the cell is reconfigure while is playing sound
  }
}

// MARK: - MessagesLayoutDelegate

extension BasicExampleViewController: MessagesLayoutDelegate {

  func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
    return CGSize(width: messagesCollectionView.bounds.width, height: DateHeaderView.height)
  }

  func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    return 0
  }

  /*
   func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
     return 0
   }
   */
  func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    return 0
  }

  func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    return 0
  }
}
