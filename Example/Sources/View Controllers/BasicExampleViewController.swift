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

  override func configureMessageCollectionView() {
    super.configureMessageCollectionView()

    guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else {
      return
    }
    layout.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)

    // Hide the outgoing avatar and adjust the label alignment to line up with the messages
    layout.setMessageOutgoingAvatarSize(.zero)
    layout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: .zero))
    layout.setMessageOutgoingMessagePadding(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 16))
    layout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)))

    // Set outgoing avatar to overlap with the message bubble
    // layout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 18, bottom: outgoingAvatarOverlap, right: 0)))
    layout.setMessageIncomingAvatarSize(CGSize(width: 30, height: 30))
    layout.setMessageIncomingMessagePadding(UIEdgeInsets(top: 0, left: 12, bottom: -30, right: 18))

    layout.setMessageIncomingAccessoryViewSize(CGSize(width: 30, height: 30))
    layout.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 8, right: 0))
    layout.setMessageIncomingAccessoryViewPosition(.messageBottom)
    layout.setMessageOutgoingAccessoryViewSize(CGSize(width: 30, height: 30))
    layout.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))

    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
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

  // MARK: - Text Messages

  func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
    return isFromCurrentSender(message: message) ? .white : .darkText
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
    return isFromCurrentSender(message: message) ? .primaryColor : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
  }

  func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

    let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
    return .bubbleTail(tail, .curved)
  }

  func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
    let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
    avatarView.set(avatar: avatar)
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

  func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    return 18
  }

  func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    return 17
  }

  func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    return 20
  }

  func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    return 16
  }
}
