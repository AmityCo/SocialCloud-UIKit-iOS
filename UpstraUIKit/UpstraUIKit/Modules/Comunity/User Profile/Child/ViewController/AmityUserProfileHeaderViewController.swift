//
//  AmityUserProfileHeaderViewController.swift
//  AmityUIKit
//
//  Created by Nontapat Siengsanor on 29/9/2563 BE.
//  Copyright © 2563 Amity. All rights reserved.
//

import AmitySDK
import UIKit

class AmityUserProfileHeaderViewController: AmityViewController, AmityRefreshable {
    
    // MARK: - Properties
    private var screenViewModel: AmityUserProfileHeaderScreenViewModelType!
    private var settings: AmityUserProfilePageSettings!
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak private var avatarView: AmityAvatarView!
    @IBOutlet weak private var displayNameLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var editProfileButton: AmityButton!
    @IBOutlet weak private var messageButton: AmityButton!
    @IBOutlet weak private var postsButton: AmityButton!
    @IBOutlet weak private var followingButton: AmityButton!
    @IBOutlet weak private var followersButton: AmityButton!
    @IBOutlet weak private var followButton: AmityButton!
    @IBOutlet weak private var followRequestsStackView: UIStackView!
    @IBOutlet weak private var followRequestBackgroundView: UIView!
    @IBOutlet weak private var dotView: UIView!
    @IBOutlet weak private var pendingRequestsLabel: UILabel!
    @IBOutlet weak private var followRequestDescriptionLabel: UILabel!
    
    // MARK: Initializer
    static func make(withUserId userId: String, settings: AmityUserProfilePageSettings) -> AmityUserProfileHeaderViewController {
        let viewModel = AmityUserProfileHeaderScreenViewModel(userId: userId)
        let vc = AmityUserProfileHeaderViewController(nibName: AmityUserProfileHeaderViewController.identifier, bundle: AmityUIKitManager.bundle)
        vc.screenViewModel = viewModel
        vc.settings = settings
        return vc
    }
    
    // MARK: - View's life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewNavigation()
        setupDisplayName()
        setupDescription()
        setupEditButton()
        setupChatButton()
        setupViewModel()
        setupPostsButton()
        setupFollowingButton()
        setupFollowersButton()
        setupFollowButton()
        setupFollowRequestsView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        screenViewModel.action.fetchUserData()
        screenViewModel.action.fetchFollowInfo()
    }
    
    // MARK: - Refreshable
    
    func handleRefreshing() {
        screenViewModel.action.fetchUserData()
        screenViewModel.action.fetchFollowInfo()
    }
    
    // MARK: - Setup
    
    private func setupViewNavigation() {
        navigationController?.setBackgroundColor(with: .clear, shadow: false)
    }
    
    private func setupDisplayName() {
        avatarView.placeholder = AmityIconSet.defaultAvatar
        displayNameLabel.text = ""
        displayNameLabel.font = AmityFontSet.headerLine
        displayNameLabel.textColor = AmityColorSet.base
        displayNameLabel.numberOfLines = 3
    }
    
    private func setupDescription() {
        descriptionLabel.text = ""
        descriptionLabel.font = AmityFontSet.body
        descriptionLabel.textColor = AmityColorSet.base
        descriptionLabel.numberOfLines = 0
    }
    
    private func setupEditButton() {
        editProfileButton.setImage(AmityIconSet.iconEdit, position: .left)
        editProfileButton.setTitle(AmityLocalizedStringSet.communityDetailEditProfileButton.localizedString, for: .normal)
        editProfileButton.tintColor = AmityColorSet.secondary
        editProfileButton.layer.borderColor = AmityColorSet.base.blend(.shade3).cgColor
        editProfileButton.layer.borderWidth = 1
        editProfileButton.layer.cornerRadius = 6
        editProfileButton.isHidden = true
        editProfileButton.setTitleFont(AmityFontSet.bodyBold)
    }
    
    private func setupChatButton() {
        messageButton.setImage(AmityIconSet.iconChat, position: .left)
        messageButton.setTitle(AmityLocalizedStringSet.communityDetailMessageButton.localizedString, for: .normal)
        messageButton.tintColor = AmityColorSet.secondary
        messageButton.layer.borderColor = AmityColorSet.secondary.blend(.shade3).cgColor
        messageButton.layer.borderWidth = 1
        messageButton.layer.cornerRadius = 6
        messageButton.isHidden = settings.shouldChatButtonHide
    }
    
    private func setupViewModel() {
        screenViewModel.delegate = self
    }
    
    private func setupPostsButton() {
        let attribute = AmityAttributedString()
        attribute.setBoldFont(for: AmityFontSet.captionBold)
        attribute.setNormalFont(for: AmityFontSet.caption)
        attribute.setColor(for: AmityColorSet.secondary)
        postsButton.attributedString = attribute
        postsButton.isHidden = true
    }
    
    private func setupFollowingButton() {
        let attribute = AmityAttributedString()
        attribute.setBoldFont(for: AmityFontSet.captionBold)
        attribute.setNormalFont(for: AmityFontSet.caption)
        attribute.setColor(for: AmityColorSet.secondary)
        followingButton.attributedString = attribute
        followingButton.isHidden = false
        followingButton.isUserInteractionEnabled = false
        
        followingButton.addTarget(self, action: #selector(followingAction(_:)), for: .touchUpInside)
        
        followingButton.attributedString.setTitle(String.localizedStringWithFormat(AmityLocalizedStringSet.userDetailFollowingCount.localizedString, "0"))
    }
    
    private func setupFollowersButton() {
        let attribute = AmityAttributedString()
        attribute.setBoldFont(for: AmityFontSet.captionBold)
        attribute.setNormalFont(for: AmityFontSet.caption)
        attribute.setColor(for: AmityColorSet.secondary)
        followersButton.attributedString = attribute
        followersButton.isHidden = false
        followersButton.isUserInteractionEnabled = false
        
        followersButton.addTarget(self, action: #selector(followersAction(_:)), for: .touchUpInside)
        
        followersButton.attributedString.setTitle(String.localizedStringWithFormat(AmityLocalizedStringSet.userDetailFollowersCount.localizedString, "0"))
    }
    
    private func setupFollowButton() {
        followButton.setTitleShadowColor(AmityColorSet.baseInverse, for: .normal)
        followButton.setTitleFont(AmityFontSet.bodyBold)
        followButton.tintColor = AmityColorSet.baseInverse
        followButton.backgroundColor = AmityColorSet.primary
        followButton.layer.cornerRadius = 4
        followButton.setTitle(AmityLocalizedStringSet.userDetailFollowButtonFollow.localizedString, for: .normal)
        followButton.setImage(AmityIconSet.iconAdd, position: .left)
        
        followButton.isHidden = true
    }
    
    private func setupFollowRequestsView() {
        followRequestsStackView.isHidden = true
        
        followRequestBackgroundView.backgroundColor = AmityColorSet.secondary.blend(.shade4)
        followRequestBackgroundView.layer.cornerRadius = 4
        
        dotView.layer.cornerRadius = 3
        dotView.backgroundColor = AmityColorSet.primary
        
        pendingRequestsLabel.font = AmityFontSet.bodyBold
        pendingRequestsLabel.textColor = AmityColorSet.secondary
        pendingRequestsLabel.text = AmityLocalizedStringSet.userDetailsPendingRequests.localizedString
        
        followRequestDescriptionLabel.font = AmityFontSet.caption
        followRequestDescriptionLabel.textColor = AmityColorSet.base.blend(.shade1)
        followRequestDescriptionLabel.text = AmityLocalizedStringSet.userDetailsPendingRequestsDescription.localizedString
    }
    
    private func updateView(with user: AmityUserModel) {
        avatarView.setImage(withImageURL: user.avatarURL, placeholder: AmityIconSet.defaultAvatar)
        displayNameLabel.text = user.displayName
        descriptionLabel.text = user.about
        editProfileButton.isHidden = !user.isCurrentUser
        messageButton.isHidden = settings.shouldChatButtonHide || user.isCurrentUser
    }
    
    private func updateFollowInfo(with model: AmityFollowInfo) {
        updateFollowingCount(with: model.followingCount)
        updateFollowerCount(with: model.followerCount)
    }
    
    private func updatePostsCount(with postCount: Int) {
        let format = postCount == 1 ? AmityLocalizedStringSet.Unit.postSingular.localizedString : AmityLocalizedStringSet.Unit.postPlural.localizedString
        let value = postCount.formatUsingAbbrevation()
        let string = String.localizedStringWithFormat(format, value)
        postsButton.attributedString.setTitle(string)
        postsButton.attributedString.setBoldText(for: [value])
        postsButton.setAttributedTitle()
    }
    
    private func updateFollowingCount(with followingCount: Int) {
        let value = followingCount.formatUsingAbbrevation()
        let string = String.localizedStringWithFormat(AmityLocalizedStringSet.userDetailFollowingCount.localizedString, value)
        followingButton.attributedString.setTitle(string)
        followingButton.attributedString.setBoldText(for: [value])
        followingButton.setAttributedTitle()
    }
    
    private func updateFollowerCount(with followerCount: Int) {
        let value = followerCount.formatUsingAbbrevation()
        let string = String.localizedStringWithFormat(AmityLocalizedStringSet.userDetailFollowersCount.localizedString, value)
        followersButton.attributedString.setTitle(string)
        followersButton.attributedString.setBoldText(for: [value])
        followersButton.setAttributedTitle()
    }
    
    private func updateFollowButton(with status: AmityFollowStatus) {
        
        // Hide message button
        messageButton.isHidden = status == .blocked
        
        switch status {
        case .accepted:
            followButton.isHidden = true
        case .pending:
            followButton.isHidden = false
            followButton.setTitle(AmityLocalizedStringSet.userDetailFollowButtonCancel.localizedString, for: .normal)
            followButton.setImage(AmityIconSet.Follow.iconFollowPendingRequest, position: .left)
            followButton.backgroundColor = .white
            followButton.layer.borderColor = AmityColorSet.base.blend(.shade3).cgColor
            followButton.layer.borderWidth = 1
            followButton.tintColor = AmityColorSet.secondary
        case .blocked:
            // Change follow button to unblock
            followButton.isHidden = false
            followButton.setTitle(AmityLocalizedStringSet.userDetailsButtonUnblock.localizedString, for: .normal)
            followButton.setImage(AmityIconSet.Follow.iconUnblockUser, position: .left)
            followButton.backgroundColor = .white
            followButton.layer.borderColor = AmityColorSet.base.blend(.shade3).cgColor
            followButton.layer.borderWidth = 1
            followButton.tintColor = AmityColorSet.secondary
        case .none:
            followButton.isHidden = false
            followButton.setTitle(AmityLocalizedStringSet.userDetailFollowButtonFollow.localizedString, for: .normal)
            followButton.setImage(AmityIconSet.iconAdd, position: .left)
            followButton.backgroundColor = AmityColorSet.primary
            followButton.layer.borderWidth = 0
            followButton.tintColor = AmityColorSet.baseInverse
       case .blocked:
            followButton.isHidden = true
        @unknown default:
            fatalError()
        }
    }
    
    private func updateFollowRequestsView(with count: Int) {
        followRequestsStackView.isHidden = count == 0
    }
    
    @IBAction func editButtonTap(_ sender: Any) {
        AmityEventHandler.shared.editUserDidTap(from: self, userId: screenViewModel.userId)
    }
    
    @IBAction func chatButtonTap(_ sender: Any) {
        screenViewModel.action.createChannel()
    }
    
    @IBAction func followAction(_ sender: UIButton) {
        let status = screenViewModel.dataSource.followStatus ?? .none
        switch status {
        case .blocked:
            screenViewModel.action.unblockUser()
        case .pending:
            unfollow()
        case .none:
            follow()
            updateFollowButton(with: .pending)
        default:
            break
        }
    }
    
    @objc func postsAction(_ sender: UIButton) {
    }
    
    @objc func followingAction(_ sender: UIButton) {
        handleTapAction(isFollowersSelected: false)
    }
    
    @objc func followersAction(_ sender: UIButton) {
        handleTapAction(isFollowersSelected: true)
    }
    
    @IBAction func followRequestsAction(_ sender: UIButton) {
        let requestsViewController = AmityFollowRequestsViewController.make(withUserId: screenViewModel.dataSource.userId)
        navigationController?.pushViewController(requestsViewController, animated: true)
    }
}

// MARK:- Follow/Unfollow handlers
private extension AmityUserProfileHeaderViewController {
    func follow() {
        screenViewModel.action.follow()
    }
    
    func unfollow() {
        screenViewModel.action.unfollow()
    }
    
    func handleTapAction(isFollowersSelected: Bool) {
        let vc = AmityUserFollowersViewController.make(withUserId: screenViewModel.dataSource.userId, isFollowersSelected: isFollowersSelected)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AmityUserProfileHeaderViewController : AmityUserProfileHeaderScreenViewModelDelegate {
    
    func screenViewModel(_ viewModel: AmityUserProfileHeaderScreenViewModelType, didUnblockUser error: AmityError?) {
        if let _ = error {
            let failureMessage = AmityLocalizedStringSet.UserSettings.UserSettingsMessages.unblockUserFailedTitle.localizedString
            AmityHUD.show(.error(message: failureMessage))
        } else {
            updateFollowButton(with: .none)
        }
    }
    
    func screenViewModel(_ viewModel: AmityUserProfileHeaderScreenViewModelType, didUnfollowUser status: AmityFollowStatus, error: AmityError?) {
        updateFollowButton(with: status)
    }
    
    func screenViewModel(_ viewModel: AmityUserProfileHeaderScreenViewModelType, didFollowUser status: AmityFollowStatus, error: AmityError?) {
        updateFollowButton(with: status)

        // Incase of follow error, we show alert
        if let _ = error {
            let userName = screenViewModel.dataSource.user?.displayName ?? ""
            let title = String.localizedStringWithFormat(AmityLocalizedStringSet.userDetailsUnableToFollow.localizedString, userName)
            let alert = UIAlertController(title: title, message: AmityLocalizedStringSet.somethingWentWrongWithTryAgain.localizedString, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: AmityLocalizedStringSet.General.ok.localizedString, style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func screenViewModel(_ viewModel: AmityUserProfileHeaderScreenViewModelType, didReceiveError error: AmityError) {
    }
    
    func screenViewModel(_ viewModel: AmityUserProfileHeaderScreenViewModelType, didGetUser user: AmityUserModel) {
        updateView(with: user)
    }
    
    func screenViewModel(_ viewModel: AmityUserProfileHeaderScreenViewModelType, didGetFollowInfo followInfo: AmityFollowInfo) {
        updateFollowInfo(with: followInfo)
        if let pendingCount = screenViewModel.dataSource.followInfo?.pendingCount {
            updateFollowRequestsView(with: pendingCount)
            followersButton.isUserInteractionEnabled = true
            followingButton.isUserInteractionEnabled = true
        } else if let status = screenViewModel.dataSource.followInfo?.status {
            updateFollowButton(with: status)
            followersButton.isUserInteractionEnabled = status == .accepted
            followingButton.isUserInteractionEnabled = status == .accepted
        }
    }
    
    func screenViewModel(_ viewModel: AmityUserProfileHeaderScreenViewModelType, didCreateChannel channel: AmityChannel) {
        AmityChannelEventHandler.shared.channelDidTap(from: self, channelId: channel.channelId, subChannelId: channel.defaultSubChannelId)
    }
}
