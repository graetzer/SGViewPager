//
//  SGTabbedPager.swift
//  SGViewPager
//
//  Copyright (c) 2012-2015 Simon Grätzer
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

public protocol SGTabbedPagerDatasource {
    func numberOfViewControllers() -> Int
    func viewController(page:Int) -> UIViewController
    func viewControllerTitle(page:Int) -> String
}

public class SGTabbedPager: UIViewController, UIScrollViewDelegate {
    private let tabHeight = CGFloat(44);
    public var datasource : SGTabbedPagerDatasource? = nil
    private var titleScrollView, contentScrollView : UIScrollView!
    private var viewControllers = [UIViewController]()
    private var viewControllerCount : Int = 0
    private var tabLabels = [UIButton]()
    private var bottomLine, tabIndicator : UIView!
    private var selectedIndex : Int = 0
    private var enableParallex = true
    
    public var selectedViewController : UIViewController {
        get {
            return viewControllers[selectedIndex]
        }
    }
    public var tabColor : UIColor = UIColor(red: 0, green: 0.329, blue: 0.624, alpha: 1) {
        didSet {
            if bottomLine != nil {
                bottomLine.backgroundColor = tabColor
            }
            if tabIndicator != nil {
                tabIndicator.backgroundColor = tabColor
            }
        }
    }
    
    /// Encode and decode the state
    public override func encodeRestorableStateWithCoder(coder: NSCoder) {
        super.encodeRestorableStateWithCoder(coder)
        coder.encodeInteger(selectedIndex, forKey: "selectedIndex")
    }
    
    public override func decodeRestorableStateWithCoder(coder: NSCoder) {
        super.decodeRestorableStateWithCoder(coder)
        selectedIndex = coder.decodeIntegerForKey("selectedIndex")
    }
    
    public override func loadView() {
        super.loadView()
        let size = self.view.bounds.size
        titleScrollView = UIScrollView(frame: CGRectZero)
        titleScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        titleScrollView.autoresizingMask = .FlexibleWidth | .FlexibleBottomMargin
        titleScrollView.backgroundColor = UIColor.whiteColor()
        titleScrollView.canCancelContentTouches = false
        titleScrollView.showsHorizontalScrollIndicator = false
        titleScrollView.bounces = false
        titleScrollView.delegate = self
        self.view.addSubview(titleScrollView)
        
        bottomLine = UIView(frame: CGRectZero)
        bottomLine.backgroundColor = tabColor
        titleScrollView.addSubview(bottomLine)
        tabIndicator = UIView(frame: CGRectZero)
        tabIndicator.backgroundColor = tabColor
        titleScrollView.addSubview(tabIndicator)
        
        contentScrollView = UIScrollView(frame: CGRectZero)
        contentScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentScrollView.autoresizingMask = .FlexibleWidth | .FlexibleBottomMargin
        contentScrollView.backgroundColor = UIColor.whiteColor()
        contentScrollView.delaysContentTouches = false
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.pagingEnabled = true
        contentScrollView.scrollEnabled = true
        contentScrollView.delegate = self
        self.view.addSubview(contentScrollView)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
    }
    
    public override func viewWillLayoutSubviews() {
        self.layout()
    }
    
    public override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        titleScrollView.delegate = nil
        contentScrollView.delegate = nil
        coordinator.animateAlongsideTransition(nil, completion: {_ -> Void in
            self.titleScrollView.delegate = self
            self.contentScrollView.delegate = self
            self.switchPage(self.selectedIndex, animated: false)
        })
    }
    
    public func reloadData() {
        for vc in viewControllers {
            vc.willMoveToParentViewController(nil)
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
        }
        viewControllers.removeAll(keepCapacity: true)
        
        viewControllerCount = self.datasource!.numberOfViewControllers()
        for var i = 0; i < viewControllerCount; i++ {
            let vc = self.datasource!.viewController(i)
            
            addChildViewController(vc)
            let size = contentScrollView.frame.size
            vc.view.frame = CGRectMake(size.width * CGFloat(i), 0, size.width, size.height)
            contentScrollView.addSubview(vc.view)
            vc.didMoveToParentViewController(self)
            viewControllers.append(vc)
        }
        generateTabs()
        layout()
        
        selectedIndex = min(viewControllerCount-1, selectedIndex)//Sanity check
        if selectedIndex > 0 {// Happens for example in case of a restore
            switchPage(selectedIndex, animated: false)
        }
    }
    
    public func switchPage(index :Int, animated : Bool) {
        let frame = CGRectMake(contentScrollView.frame.size.width * CGFloat(index), 0,
            contentScrollView.frame.size.width, contentScrollView.frame.size.height) ;
        if frame.origin.x < contentScrollView.contentSize.width {
            enableParallex = false
            // It doesn't look good if the tab's jumo back and then gets animated back
            var point = tabLabels[index].frame.origin
            point.x -= (titleScrollView.bounds.size.width - tabLabels[index].frame.size.width)/2
            titleScrollView.setContentOffset(point, animated: true)
            contentScrollView.scrollRectToVisible(frame, animated: animated)
        }
    }
    
    // MARK: Helpers
    
    private func generateTabs() {
        for label in tabLabels {
            label.removeFromSuperview()
        }
        tabLabels.removeAll(keepCapacity: true)
        
        let font = UIFont(name: "HelveticaNeue-Thin", size: 20)
        for var i = 0; i < self.viewControllerCount; i++ {
            let button = UIButton.buttonWithType(.Custom) as! UIButton
            button.setTitle(self.datasource?.viewControllerTitle(i), forState: .Normal)
            button.setTitleColor(UIColor.blackColor(), forState: .Normal)
            button.titleLabel?.font = font
            button.titleLabel?.textAlignment = .Center
            button.sizeToFit()
            button.addTarget(self, action: "receivedButtonTab:", forControlEvents: .TouchUpInside)
            titleScrollView.addSubview(button)
            tabLabels.append(button)
        }
    }
    
    public func receivedButtonTab(sender :UIButton)  {
        if let i = find(tabLabels, sender) {
            switchPage(i, animated:true)
        }
    }
    
    private func layout() {
        var size = self.view.bounds.size
        titleScrollView.frame = CGRectMake(0, 0, size.width, tabHeight)
        contentScrollView.frame = CGRectMake(0, tabHeight,
            self.view.bounds.size.width, self.view.bounds.size.height - tabHeight)
        
        var currentX : CGFloat = 0
        size = contentScrollView.frame.size
        for var i = 0; i < self.viewControllerCount; i++ {
            let label = tabLabels[i]
            if i == 0 {
                currentX += (size.width - label.frame.size.width)/2
            }
            label.frame = CGRectMake(currentX, 0.0, label.frame.size.width, tabHeight)
            if i == viewControllerCount-1 {
                currentX += (size.width - label.frame.size.width)/2 + label.frame.size.width
            } else {
                currentX += label.frame.size.width + 30
            }
            let vc = viewControllers[i]
            vc.view.frame = CGRectMake(size.width * CGFloat(i), 0, size.width, size.height)
        }
        titleScrollView.contentSize = CGSizeMake(currentX, tabHeight)
        contentScrollView.contentSize = CGSizeMake(size.width * CGFloat(viewControllerCount), size.height)
        bottomLine.frame = CGRectMake(0, tabHeight-1, titleScrollView.contentSize.width, 1)
        layoutTabIndicator()
    }
    
    /// Position the marker below the tab
    func layoutTabIndicator() {
        let labelF = tabLabels[selectedIndex].frame
        tabIndicator.frame = CGRectMake(labelF.origin.x, labelF.size.height-4, labelF.size.width, 4)
    }
    
    // MARK: UIScrollViewDelegate
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == contentScrollView {
            let pageWidth = scrollView.frame.size.width;
            var page = (scrollView.contentOffset.x - pageWidth / 2) / pageWidth + 1;
            let next = Int(floor(page))
            if next != selectedIndex {
                selectedIndex = next
                UIView.animateWithDuration(0.3, animations:layoutTabIndicator)
            }
            
            var ignored : Double = 0.0
            page = scrollView.contentOffset.x / pageWidth;// Current page index with fractions
            let index = Int(page)
            if index + 1 < viewControllerCount && enableParallex {
                // We are using the difference from one label to the other to implement varying speeds
                // for our custom parallax effect, so every title is exactly centered if you are on a page
                let diff = tabLabels[index+1].frame.origin.x - tabLabels[index].frame.origin.x
                let centering1 = (titleScrollView.bounds.size.width - tabLabels[index].frame.size.width)/2
                let centering2 = (titleScrollView.bounds.size.width - tabLabels[index+1].frame.size.width)/2
                let frac = CGFloat(modf(Double(page), &ignored))// Only fraction part remains, Eg 3.4344 -> 0.4344
                let newXOff = tabLabels[index].frame.origin.x + diff * frac - centering1 * (1-frac) - centering2 * frac;
                titleScrollView.contentOffset = CGPointMake(fmax(0, newXOff), 0)
            }
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if scrollView == contentScrollView {
            enableParallex = true// Always enable after an animation
        }
    }
}