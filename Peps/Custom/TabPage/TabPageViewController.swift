//
//  TabPageViewController.swift
//  TabPageViewController
//
//  Created by EndouMari on 2016/02/24.
//  Copyright © 2016年 EndouMari. All rights reserved.
//

import UIKit

class TabPageViewController: UIPageViewController {
    open var isInfinity: Bool = false
    open var option: TabPageOption = TabPageOption()
    open var tabItems: [(viewController: UIViewController, title: String)] = []

    var currentIndex: Int? {
        guard let viewController = viewControllers?.first else {
            return nil
        }
        return tabItems.map { $0.viewController }.firstIndex(of: viewController)
    }

    fileprivate var beforeIndex: Int = 0
    fileprivate var tabItemsCount: Int {
        return tabItems.count
    }

    fileprivate var defaultContentOffsetX: CGFloat {
        return view.bounds.width
    }

    fileprivate var shouldScrollCurrentBar: Bool = true
//    lazy fileprivate var tabView: TabView = self.configuredTabView()
    fileprivate var statusView: UIView?
    fileprivate var statusViewHeightConstraint: NSLayoutConstraint?
    fileprivate var tabBarTopConstraint: NSLayoutConstraint?

    init() {
        let optionsDict = [UIPageViewController.OptionsKey.interPageSpacing: 20]
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: optionsDict)
    }

    required init?(coder _: NSCoder) {
        let optionsDict = [UIPageViewController.OptionsKey.interPageSpacing: 20]
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: optionsDict)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        setupPageViewController()
//        setupScrollView()
        updateNavigationBar()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        if tabView.superview == nil {
//            tabView = configuredTabView()
//        }
//
//        if let currentIndex = currentIndex , isInfinity {
//            tabView.updateCurrentIndex(currentIndex, shouldScroll: true)
//        }
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        updateNavigationBar()
//        tabView.layouted = true
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

// MARK: - Interface

extension TabPageViewController {
    func displayControllerWithIndex(_ index: Int, direction: UIPageViewController.NavigationDirection, animated: Bool) {
        beforeIndex = index
        shouldScrollCurrentBar = false
        let nextViewControllers: [UIViewController] = [tabItems[index].viewController]

        let completion: ((Bool) -> Void) = { [weak self] _ in
            self?.shouldScrollCurrentBar = true
            self?.beforeIndex = index
        }

        setViewControllers(
            nextViewControllers,
            direction: direction,
            animated: animated,
            completion: completion
        )

        guard isViewLoaded else { return }
//        tabView.updateCurrentIndex(index, shouldScroll: true)
    }
}

// MARK: - View

extension TabPageViewController {
    fileprivate func setupPageViewController() {
        dataSource = self
        delegate = self
        automaticallyAdjustsScrollViewInsets = true

        setViewControllers([tabItems[beforeIndex].viewController],
                           direction: .forward,
                           animated: false,
                           completion: nil)
    }

    fileprivate func setupScrollView() {
        // Disable PageViewController's ScrollView bounce
        let scrollView = view.subviews.compactMap { $0 as? UIScrollView }.first
        scrollView?.scrollsToTop = false
        scrollView?.delegate = self
        scrollView?.backgroundColor = option.pageBackgoundColor

        let height = CGFloat(40)
        if var frame = scrollView?.frame {
            frame.origin.y = height
            frame.size.height -= height
            scrollView?.frame = frame
        }

        let insets = UIEdgeInsets(top: height, left: 0.0, bottom: 0.0, right: 0.0)
        scrollView?.contentInset = insets
        scrollView?.scrollIndicatorInsets = insets
    }

    /**
     Update NavigationBar
     */

    fileprivate func updateNavigationBar() {
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.shadowImage = UIImage()
            navigationBar.setBackgroundImage(option.tabBackgroundImage, for: .default)
            navigationBar.isTranslucent = option.isTranslucent
        }
    }

    fileprivate func configuredTabView() -> TabView {
        let tabView = TabView(isInfinity: isInfinity, option: option)
        tabView.translatesAutoresizingMaskIntoConstraints = false

        let height = NSLayoutConstraint(item: tabView,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .height,
                                        multiplier: 1.0,
                                        constant: option.tabHeight)
        tabView.addConstraint(height)
        view.addSubview(tabView)

        let top = NSLayoutConstraint(item: tabView,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: topLayoutGuide,
                                     attribute: .bottom,
                                     multiplier: 1.0,
                                     constant: 0.0)

        let left = NSLayoutConstraint(item: tabView,
                                      attribute: .leading,
                                      relatedBy: .equal,
                                      toItem: view,
                                      attribute: .leading,
                                      multiplier: 1.0,
                                      constant: 0.0)

        let right = NSLayoutConstraint(item: view as Any,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: tabView,
                                       attribute: .trailing,
                                       multiplier: 1.0,
                                       constant: 0.0)

        view.addConstraints([top, left, right])

        tabView.pageTabItems = tabItems.map({ $0.title })
        tabView.updateCurrentIndex(beforeIndex, shouldScroll: true)

        tabView.pageItemPressedBlock = { [weak self] (index: Int, direction: UIPageViewController.NavigationDirection) in
            self?.displayControllerWithIndex(index, direction: direction, animated: true)
        }

        tabBarTopConstraint = top

        return tabView
    }

    private func setupStatusView() {
        let statusView = UIView()
        statusView.backgroundColor = option.tabBackgroundColor
        statusView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusView)

        let top = NSLayoutConstraint(item: statusView,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: view,
                                     attribute: .top,
                                     multiplier: 1.0,
                                     constant: 0.0)

        let left = NSLayoutConstraint(item: statusView,
                                      attribute: .leading,
                                      relatedBy: .equal,
                                      toItem: view,
                                      attribute: .leading,
                                      multiplier: 1.0,
                                      constant: 0.0)

        let right = NSLayoutConstraint(item: view as Any,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: statusView,
                                       attribute: .trailing,
                                       multiplier: 1.0,
                                       constant: 0.0)

        let height = NSLayoutConstraint(item: statusView,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .height,
                                        multiplier: 1.0,
                                        constant: topLayoutGuide.length)

        view.addConstraints([top, left, right, height])

        statusViewHeightConstraint = height
        self.statusView = statusView
    }

    func updateNavigationBarHidden(_ hidden: Bool, animated _: Bool) {
        guard let navigationController = navigationController else { return }

        switch option.hidesTopViewOnSwipeType {
        case .tabBar:
            updateTabBarOrigin(hidden: hidden)
        case .navigationBar:
            if hidden {
                navigationController.setNavigationBarHidden(true, animated: true)
            } else {
                showNavigationBar()
            }
        case .all:
            updateTabBarOrigin(hidden: hidden)
            if hidden {
                navigationController.setNavigationBarHidden(true, animated: true)
            } else {
                showNavigationBar()
            }
        default:
            break
        }
        if statusView == nil {
            setupStatusView()
        }

        statusViewHeightConstraint!.constant = topLayoutGuide.length
    }

    func showNavigationBar() {
        guard let navigationController = navigationController else { return }
        guard navigationController.isNavigationBarHidden else { return }
        guard let tabBarTopConstraint = tabBarTopConstraint else { return }

        if option.hidesTopViewOnSwipeType != .none {
            tabBarTopConstraint.constant = 0.0
            UIView.animate(withDuration: TimeInterval(UINavigationController.hideShowBarDuration)) {
                self.view.layoutIfNeeded()
            }
        }

        navigationController.setNavigationBarHidden(false, animated: true)
    }

    private func updateTabBarOrigin(hidden: Bool) {
        guard let tabBarTopConstraint = tabBarTopConstraint else { return }

        tabBarTopConstraint.constant = hidden ? -(20.0 + option.tabHeight) : 0.0
        UIView.animate(withDuration: TimeInterval(UINavigationController.hideShowBarDuration)) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UIPageViewControllerDataSource

extension TabPageViewController: UIPageViewControllerDataSource {
    fileprivate func nextViewController(_ viewController: UIViewController, isAfter: Bool) -> UIViewController? {
        guard var index = tabItems.map({ $0.viewController }).firstIndex(of: viewController) else {
            return nil
        }

        if isAfter {
            index += 1
        } else {
            index -= 1
        }

        if isInfinity {
            if index < 0 {
                index = tabItems.count - 1
            } else if index == tabItems.count {
                index = 0
            }
        }

        if index >= 0 && index < tabItems.count {
            return tabItems[index].viewController
        }
        return nil
    }

    func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nextViewController(viewController, isAfter: true)
    }

    func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nextViewController(viewController, isAfter: false)
    }
}

// MARK: - UIPageViewControllerDelegate

extension TabPageViewController: UIPageViewControllerDelegate {
//    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
//        shouldScrollCurrentBar = true
//        tabView.scrollToHorizontalCenter()
//
//        // Order to prevent the the hit repeatedly during animation
//        tabView.updateCollectionViewUserInteractionEnabled(false)
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//        if let currentIndex = currentIndex , currentIndex < tabItemsCount {
//            tabView.updateCurrentIndex(currentIndex, shouldScroll: false)
//            beforeIndex = currentIndex
//        }
//
//        tabView.updateCollectionViewUserInteractionEnabled(true)
//    }
}

// MARK: - UIScrollViewDelegate

extension TabPageViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.x == defaultContentOffsetX || !shouldScrollCurrentBar {
//            return
//        }
//
//        // (0..<tabItemsCount)
//        var index: Int
//        if scrollView.contentOffset.x > defaultContentOffsetX {
//            index = beforeIndex + 1
//        } else {
//            index = beforeIndex - 1
//        }
//
//        if index == tabItemsCount {
//            index = 0
//        } else if index < 0 {
//            index = tabItemsCount - 1
//        }
//
//        let scrollOffsetX = scrollView.contentOffset.x - view.frame.width
//        tabView.scrollCurrentBarView(index, contentOffsetX: scrollOffsetX)
//    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        tabView.updateCurrentIndex(beforeIndex, shouldScroll: true)
//    }
}
