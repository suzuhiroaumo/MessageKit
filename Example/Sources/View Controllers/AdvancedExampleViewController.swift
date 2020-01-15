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
import InputBarAccessoryView
import Nantes

final class AdvancedExampleViewController: ChatViewController {

  let outgoingAvatarOverlap: CGFloat = 17.5

  var currentDate: Date = Date()

  override func viewDidLoad() {
    messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CustomMessagesFlowLayout())
    messagesCollectionView.register(CustomCell.self)
    super.viewDidLoad()

    updateTitleView(title: "MessageKit", subtitle: "2 Online")
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    MockSocket.shared.connect(with: [SampleData.shared.nathan, SampleData.shared.wu]).onTypingStatus { [weak self] in
      guard let self = self else {
        return
      }
      self.setTypingIndicatorViewHidden(false)
    }.onNewMessage { [weak self] message in
      guard let self = self else {
        return
      }
      self.setTypingIndicatorViewHidden(true, performUpdates: {
        self.insertMessage(message)
      })
    }
  }

  override func loadFirstMessages() {
    DispatchQueue.global(qos: .userInitiated).async {
      let count = UserDefaults.standard.mockMessagesCount()
      SampleData.shared.getAdvancedMessages(count: count) { messages in
        DispatchQueue.main.async {
          self.messageList = messages
          self.messagesCollectionView.reloadData()
          self.messagesCollectionView.scrollToBottom()
        }
      }
    }
  }

  override func loadMoreMessages() {
    DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
      SampleData.shared.getAdvancedMessages(count: 20) { messages in
        DispatchQueue.main.async {
          self.messageList.insert(contentsOf: messages, at: 0)
          self.messagesCollectionView.reloadDataAndKeepOffset()
          self.refreshControl.endRefreshing()
        }
      }
    }
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

  // MARK: - Helpers

  private func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
    return true
  }

  /// 入力中のステータス
  ///
  /// - Parameters:
  ///   - isHidden: 入力中を有効にするかどうか
  ///   - updates: 更新が完了したか
  private func setTypingIndicatorViewHidden(_ isHidden: Bool, performUpdates updates: (() -> Void)? = nil) {
    updateTitleView(title: "MessageKit", subtitle: isHidden ? "2 Online" : "Typing...")
    setTypingIndicatorViewHidden(isHidden, animated: true, whilePerforming: updates) { [weak self] success in
      guard let self = self else {
        return
      }
      if success, self.isLastSectionVisible() == true {
        self.messagesCollectionView.scrollToBottom(animated: true)
      }
    }
  }

  private func makeButton(named: String) -> InputBarButtonItem {
    return InputBarButtonItem()
      .configure {
        $0.spacing = .fixed(10)
        $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
        $0.setSize(CGSize(width: 25, height: 25), animated: false)
        $0.tintColor = UIColor(white: 0.8, alpha: 1)
      }.onSelected {
        $0.tintColor = .primaryColor
      }.onDeselected {
        $0.tintColor = UIColor(white: 0.8, alpha: 1)
      }.onTouchUpInside {
        print("Item Tapped")
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(action)
        if let popoverPresentationController = actionSheet.popoverPresentationController {
          popoverPresentationController.sourceView = $0
          popoverPresentationController.sourceRect = $0.frame
        }
        self.navigationController?.present(actionSheet, animated: true, completion: nil)
      }
  }

  // MARK: - UICollectionViewDataSource

  public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
      fatalError("Ouch. nil data source for messages")
    }

    // Very important to check this when overriding `cellForItemAt`
    // Super method will handle returning the typing indicator cell
    guard !isSectionReservedForTypingIndicator(indexPath.section) else {
      return super.collectionView(collectionView, cellForItemAt: indexPath)
    }

    let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
    print("\n",
          "message",
          "\n",
          message
    )
    if case .custom = message.kind {
      let cell = messagesCollectionView.dequeueReusableCell(CustomCell.self, for: indexPath)
      cell.configure(with: message, at: indexPath, and: messagesCollectionView)
      return cell
    } else {
      print("\n",
            "message.kind",
            "\n",
            message.kind
      )
      return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
  }

  // MARK: - MessagesDataSource

  /// 日付のまとまりのString
  /// - Parameters:
  ///   - message: message
  ///   - indexPath: パス
  override func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    guard isTimeLabelVisible(at: indexPath) else {
      return nil
    }
    return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                              attributes: [NSAttributedString.Key.font: UIFont.hiraKakuW6(size: 10),
                                           NSAttributedString.Key.foregroundColor: UIColor.darkGray])
  }

  override func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    return nil
  }

  override func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    return nil
  }
}

// MARK: - MessagesDisplayDelegate

extension AdvancedExampleViewController: MessagesDisplayDelegate {

  // MARK: - Text Messages

  // 送信済みテキストの色
  func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
    return isFromCurrentSender(message: message) ? .darkText : .darkText
  }

  func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
    switch detector {
    case .hashtag, .mention:
      if isFromCurrentSender(message: message) {
        return [.foregroundColor: UIColor.white]
      } else {
        return [.foregroundColor: UIColor.primaryColor]
      }
    default: return MessageLabel.defaultAttributes
    }
  }

  func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
    return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
  }

  // MARK: - All Messages

    /// 送信済みメッセージの背景色
    ///
    /// - Parameters:
    ///   - message: MessageType
    ///   - indexPath: IndexPath
    ///   - messagesCollectionView: MessagesCollectionView
  /// - Returns: 送信済みメッセージの背景色
  func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
    return isFromCurrentSender(message: message) ? UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1) : UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1)
  }

    /// メッセージの形式
    ///
    /// - Parameters:
    ///   - message: メッセージ内容
    ///   - indexPath: パス
    ///   - messagesCollectionView: MessagesCollectionView
  /// - Returns: メッセージの形式
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


  // アイコンの表示
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
}

// MARK: - MessagesLayoutDelegate

extension AdvancedExampleViewController: MessagesLayoutDelegate {

  func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    if isTimeLabelVisible(at: indexPath) {
      return 18
    }
    return 0
  }

  func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    return 0
  }

  func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    return 0
  }
}
