//
//  EkoCommentView.swift
//  UpstraUIKit
//
//  Created by Nontapat Siengsanor on 23/9/2563 BE.
//  Copyright © 2563 Upstra. All rights reserved.
//

import UIKit

enum EkoCommentViewLayout {
    case comment(contentExpanded: Bool, shouldActionShow: Bool, shouldLineShow: Bool)
    case commentPreview(shouldActionShow: Bool)
    case reply(contentExpanded: Bool, shouldActionShow: Bool, shouldLineShow: Bool)
}

enum EkoCommentViewAction {
    case avatar
    case like
    case reply
    case option
}

protocol EkoCommentViewDelegate: class {
    func commentView(_ view: EkoCommentView, didTapAction action: EkoCommentViewAction)
}

class EkoCommentView: EkoView {
    
    @IBOutlet private weak var avatarView: EkoAvatarView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: EkoExpandableLabel!
    @IBOutlet private weak var actionStackView: UIStackView!
    @IBOutlet private weak var likeButton: EkoButton!
    @IBOutlet private weak var replyButton: EkoButton!
    @IBOutlet private weak var optionButton: UIButton!
    @IBOutlet private weak var lineView: UIView!
    @IBOutlet private weak var separatorLineView: UIView!
    @IBOutlet private weak var topAvatarImageViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomContentLabelConstraint: NSLayoutConstraint!
    
    weak var delegate: EkoCommentViewDelegate?
    private(set) var comment: EkoCommentModel?
    
    override func initial() {
        loadNibContent()
        setupView()
    }
    
    private func setupView() {
        avatarView.placeholder = EkoIconSet.defaultAvatar
        avatarView.actionHandler = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.commentView(strongSelf, didTapAction: .avatar)
        }
        titleLabel.textColor = EkoColorSet.base
        contentLabel.textColor = EkoColorSet.base
        contentLabel.font = EkoFontSet.body
        contentLabel.numberOfLines = 8
        likeButton.setTitle(EkoLocalizedStringSet.like, for: .normal)
        likeButton.setTintColor(EkoColorSet.primary, for: .selected)
        likeButton.setTintColor(EkoColorSet.base.blend(.shade2), for: .normal)
        likeButton.setTitleColor(EkoColorSet.primary, for: .selected)
        likeButton.setTitleColor(EkoColorSet.base.blend(.shade2), for: .normal)
        likeButton.addTarget(self, action: #selector(likeButtonTap), for: .touchUpInside)
        likeButton.setInsets(forContentPadding: .zero, imageTitlePadding: 4)
        lineView.backgroundColor = EkoColorSet.secondary.blend(.shade4)
        replyButton.setTitle(EkoLocalizedStringSet.reply, for: .normal)
        replyButton.setImage(EkoIconSet.iconReply, for: .normal)
        replyButton.tintColor = EkoColorSet.base.blend(.shade2)
        replyButton.setTitleColor(EkoColorSet.primary, for: .selected)
        replyButton.setTitleColor(EkoColorSet.base.blend(.shade2), for: .normal)
        replyButton.addTarget(self, action: #selector(replyButtonTap), for: .touchUpInside)
        replyButton.setInsets(forContentPadding: .zero, imageTitlePadding: 4)
        separatorLineView.backgroundColor  = EkoColorSet.secondary.blend(.shade4)
        optionButton.addTarget(self, action: #selector(optionButtonTap), for: .touchUpInside)
        optionButton.tintColor = EkoColorSet.base.blend(.shade2)
    }
    
    func configure(with comment: EkoCommentModel, layout: EkoCommentViewLayout) {
        self.comment = comment
        let attributedTitle = NSMutableAttributedString()
        let name = NSAttributedString(string: comment.displayName + " • ", attributes: [.foregroundColor: EkoColorSet.base, .font: EkoFontSet.bodyBold])
        attributedTitle.append(name)
        let stringDate = comment.isEdited ? String.localizedStringWithFormat(EkoLocalizable.localizedString(forKey: "post_detail_comment_edited"), comment.createdAt.relativeTime) : comment.createdAt.relativeTime
        let attributedDate = NSAttributedString(string: stringDate, attributes: [.foregroundColor: EkoColorSet.base.blend(.shade1), .font: EkoFontSet.body])
        attributedTitle.append(attributedDate)
        avatarView.setImage(withImageId: comment.fileId, placeholder: EkoIconSet.defaultAvatar)
        titleLabel.attributedText = attributedTitle
        contentLabel.text = comment.text
        replyButton.isHidden = true // not support yet
        likeButton.isSelected = comment.isLiked
        likeButton.setTitle(comment.reactionsCount.formatUsingAbbrevation(), for: .selected)
        
        if case .comment(let settings) = layout {
            topAvatarImageViewConstraint.constant = 16
            lineView.isHidden = !settings.shouldLineShow
            separatorLineView.isHidden = true
            contentLabel.isExpanded = settings.contentExpanded
            actionStackView.isHidden = !settings.shouldActionShow
            bottomContentLabelConstraint.constant = settings.shouldActionShow ? 42 : 12
        } else if case .commentPreview(let shouldActionShow) = layout {
            topAvatarImageViewConstraint.constant = 16
            lineView.isHidden = true
            separatorLineView.isHidden = false
            contentLabel.isExpanded = false
            actionStackView.isHidden = !shouldActionShow
            bottomContentLabelConstraint.constant = shouldActionShow ? 42 : 12
        } else if case .reply(let settings) = layout {
            topAvatarImageViewConstraint.constant = 0
            lineView.isHidden = !settings.shouldLineShow
            separatorLineView.isHidden = true
            contentLabel.isExpanded = settings.contentExpanded
            actionStackView.isHidden = !settings.shouldActionShow
            bottomContentLabelConstraint.constant = settings.shouldActionShow ? 42 : 12
        }
    }

    @objc private func replyButtonTap() {
        delegate?.commentView(self, didTapAction: .reply)
    }

    @objc private func likeButtonTap() {
        delegate?.commentView(self, didTapAction: .like)
    }

    @objc private func optionButtonTap() {
        delegate?.commentView(self, didTapAction: .option)
    }
    
}
