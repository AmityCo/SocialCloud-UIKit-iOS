//
//  AmityNewsfeedViewController.swift
//  AmityUIKit
//
//  Created by Sarawoot Khunsri on 24/8/2563 BE.
//  Copyright © 2563 Amity. All rights reserved.
//

import UIKit
import AmitySDK

/// A view controller for providing global feed with create post functionality.
public class AmityNewsfeedViewController: AmityViewController, IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: AmityPagerTabViewController) -> IndicatorInfo {
        return IndicatorInfo(title: pageTitle)
    }
    
    // MARK: - Properties
    var pageTitle: String?
    
    private let emptyView = AmityNewsfeedEmptyView()
    private var headerView = AmityMyCommunityPreviewViewController.make()
    private let createPostButton: AmityFloatingButton = AmityFloatingButton()
    private let feedViewController = AmityFeedViewController.make(feedType: .globalFeed)
    private var screenViewModel: AmityNewsFeedScreenViewModelType? = nil
    
    private var permissionCanLive: Bool = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupScreenViewModel()
        setupFeedView()
        setupHeaderView()
        setupEmptyView()
        setupPostButton()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AmityEventHandler.shared.communityToNewsfeedTracking()
        headerView.retrieveCommunityList()
    }
    
    public static func make() -> AmityNewsfeedViewController {
        let vc = AmityNewsfeedViewController(nibName: nil, bundle: nil)
        return vc
    }
}

// MARK: - Setup view
private extension AmityNewsfeedViewController {
    
    private func setupScreenViewModel() {
        screenViewModel = AmityNewsFeedScreenViewModel()
        screenViewModel?.delegate = self
        fetchUserProfile()
    }
    
    private func setupFeedView() {
        addChild(viewController: feedViewController)
        feedViewController.dataDidUpdateHandler = { [weak self] itemCount in
            self?.emptyView.setNeedsUpdateState()
        }
        
        feedViewController.pullRefreshHandler = { [weak self] in
            self?.headerView.retrieveCommunityList()
        }
    }
    
    private func setupHeaderView() {
        headerView.delegate = self
    }
    
    private func setupEmptyView() {
        emptyView.exploreHandler = { [weak self] in
            AmityEventHandler.shared.communityExploreButtonTracking()
            guard let parent = self?.parent as? AmityCommunityHomePageViewController else { return }
            // Switch to explore tap which is an index 1.
            parent.setCurrentIndex(1)
        }
        emptyView.createHandler = { [weak self] in
            let vc = AmityCommunityCreatorViewController.make()
            vc.delegate = self
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .overFullScreen
            self?.present(nav, animated: true, completion: nil)
        }
        feedViewController.emptyView = emptyView

    }
    
    private func setupPostButton() {
        // setup button
        createPostButton.add(to: view, position: .bottomRight)
        createPostButton.image = AmityIconSet.iconCreatePost
        createPostButton.actionHandler = { [weak self] _ in
//            let vc = AmityPostTargetPickerViewController.make()
//            let nvc = UINavigationController(rootViewController: vc)
//            nvc.modalPresentationStyle = .fullScreen
//            self?.present(nvc, animated: true, completion: nil)
            guard let strongSelf = self else { return }
            AmityEventHandler.shared.createPostBeingPrepared(from: strongSelf,liveStreamPermission: self?.permissionCanLive ?? false)
        }
    }
    
}

extension AmityNewsfeedViewController: AmityCommunityProfileEditorViewControllerDelegate {
    
    public func viewController(_ viewController: AmityCommunityProfileEditorViewController, didFinishCreateCommunity communityId: String) {
        AmityEventHandler.shared.communityDidTap(from: self, communityId: communityId)
    }
    
}

extension AmityNewsfeedViewController: AmityMyCommunityPreviewViewControllerDelegate {

    public func viewController(_ viewController: AmityMyCommunityPreviewViewController, didPerformAction action: AmityMyCommunityPreviewViewController.ActionType) {
        switch action {
        case .seeAll:
            AmityEventHandler.shared.communityMyCommunitySectionTracking()
            let vc = AmityMyCommunityViewController.make()
            navigationController?.pushViewController(vc, animated: true)
        case .communityItem(let communityId):
            AmityEventHandler.shared.communityDidTap(from: self, communityId: communityId)
        }
    }

    public func viewController(_ viewController: AmityMyCommunityPreviewViewController, shouldShowMyCommunityPreview: Bool) {
        if shouldShowMyCommunityPreview {
            feedViewController.headerView = headerView
        } else {
            feedViewController.headerView = nil
        }
    }
}

// MARK: - Action
extension AmityNewsfeedViewController {
    
    func fetchUserProfile() {
        screenViewModel?.fetchUserProfile(with: AmityUIKitManagerInternal.shared.currentUserId)
    }
    
}
// MARK: - Delegate
extension AmityNewsfeedViewController: AmityNewsFeedScreenViewModelDelegate {
    
    func didFetchUserProfile(user: AmityUser) {
        switch AmityUIKitManagerInternal.shared.envByApiKey {
        case .staging:
            user.roles.filter{ $0 == AmityUIKitManagerInternal.shared.stagingLiveRoleID}.count > 0 ? (permissionCanLive = true) : (permissionCanLive = false)
        case .production:
            user.roles.filter{ $0 == AmityUIKitManagerInternal.shared.productionLiveRoleID}.count > 0 ? (permissionCanLive = true) : (permissionCanLive = false)
        }
    }
    
}
