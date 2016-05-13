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

public protocol SGTabbedPagerDelegate {
    //func willShowViewController(page:Int) -> Void
    func didShowViewController(page:Int) -> Void
}

public class SGTabbedPager: UIViewController, UIScrollViewDelegate {
    
    public var datasource : SGTabbedPagerDatasource? = nil
    public var delegate : SGTabbedPagerDelegate? = nil
    
    private let tabHeight = CGFloat(44);
    private var titleScrollView, contentScrollView : UIScrollView!
    private var viewControllers = [UIViewController]()
    private var viewControllerCount : Int = 0
    private var tabButtons = [UIButton]()
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
    
    // MARK: View Controller state restauration
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
        titleScrollView = UIScrollView(frame: CGRectZero)
        titleScrollView.translatesAutoresizingMaskIntoConstraints = false
        titleScrollView.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]
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
        contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        contentScrollView.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]
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
        if titleScrollView != nil {
            titleScrollView.delegate = nil
            contentScrollView.delegate = nil
            coordinator.animateAlongsideTransition(nil, completion: {_ -> Void in
                self.titleScrollView.delegate = self
                self.contentScrollView.delegate = self
                self.switchPage(self.selectedIndex, animated: false)
            })
        }
    }
    
    // MARK: Public methods
    public func reloadData() {
        for vc in viewControllers {
            vc.willMoveToParentViewController(nil)
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
        }
        viewControllers.removeAll(keepCapacity: true)
        
        if let cc = datasource?.numberOfViewControllers() {
            self.viewControllerCount = cc
            for i in 0..<viewControllerCount {
                let vc = datasource!.viewController(i)
                
                addChildViewController(vc)
                let size = contentScrollView.frame.size
                vc.view.frame = CGRectMake(size.width * CGFloat(i), 0, size.width, size.height)
                contentScrollView.addSubview(vc.view)
                vc.didMoveToParentViewController(self)
                viewControllers.append(vc)
            }
            generateTabs()
            layout()
            
            // Sanity check for restored selectedIndex values
            selectedIndex = min(viewControllerCount-1, selectedIndex)
            if selectedIndex > 0 {// Happens for example in case of a restore
                switchPage(selectedIndex, animated: false)
            }
        }
    }
    
    public func switchPage(index :Int, animated : Bool) {
        let frame = CGRectMake(contentScrollView.frame.size.width * CGFloat(index), 0,
            contentScrollView.frame.size.width, contentScrollView.frame.size.height) ;
        if frame.origin.x < contentScrollView.contentSize.width {
            // It doesn't look good if the tab's jump back and then gets animated back
            // by the code inside 'scrollViewDidScroll', but we only need to
            // disable parallax if scrollViewDidEndScrollingAnimation is gonna be called afterwards
            enableParallex = !animated
            
            var point = tabButtons[index].frame.origin
            point.x -= (titleScrollView.bounds.size.width - tabButtons[index].frame.size.width)/2
            titleScrollView.setContentOffset(point, animated: animated)
            contentScrollView.scrollRectToVisible(frame, animated: animated)
        }
    }
    
    // MARK: Helpers methods
    /// Generate the fitting UILabel's
    private func generateTabs() {
        for label in self.tabButtons {
            label.removeFromSuperview()
        }
        self.tabButtons.removeAll(keepCapacity: true)
        
        let font = UIFont(name: "HelveticaNeue-Thin", size: 20)
        for i in 0..<self.viewControllerCount {
            let button = UIButton(type: .Custom)
            button.setTitle(self.datasource?.viewControllerTitle(i), forState: .Normal)
            button.setTitleColor(UIColor.blackColor(), forState: .Normal)
            button.titleLabel?.font = font
            button.titleLabel?.textAlignment = .Center
            button.sizeToFit()
            button.addTarget(self, action: #selector(SGTabbedPager.receivedButtonTab(_:)), forControlEvents: .TouchUpInside)
            self.tabButtons.append(button)
            self.titleScrollView.addSubview(button)
        }
    }
    
    /// Action method to move the pager in the right direction
    public func receivedButtonTab(sender :UIButton)  {
        if let i = tabButtons.indexOf(sender) {
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
        for i in 0..<self.viewControllerCount {
            let label = tabButtons[i]
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
    
    /// Repositions the indication marker below the tab
    func layoutTabIndicator() {
        let labelF = tabButtons[selectedIndex].frame
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
                // Don't animate unless we wan't the parallax effect
                UIView.animateWithDuration(enableParallex ? 0.3 : 0,
                    animations:layoutTabIndicator,
                    completion:{_ in
                        self.delegate?.didShowViewController(self.selectedIndex)
                })
            }
            
            var ignored : Double = 0.0
            page = scrollView.contentOffset.x / pageWidth;// Current page index with fractions
            let index = Int(page)
            if enableParallex && index + 1 < viewControllerCount {
                // We are using the difference from one label to the other to implement varying speeds
                // for our custom parallax effect, so every title is exactly centered if you are on a page
                let diff = tabButtons[index+1].frame.origin.x - tabButtons[index].frame.origin.x
                let centering1 = (titleScrollView.bounds.size.width - tabButtons[index].frame.size.width)/2
                let centering2 = (titleScrollView.bounds.size.width - tabButtons[index+1].frame.size.width)/2
                let frac = CGFloat(modf(Double(page), &ignored))// Only fraction part remains, Eg 3.4344 -> 0.4344
                let newXOff = tabButtons[index].frame.origin.x + diff * frac - centering1 * (1-frac) - centering2 * frac;
                titleScrollView.contentOffset = CGPointMake(fmax(0, newXOff), 0)
            }
        }
    }
    
    /// Since it looks better, we disable the parralel movement effect on the title scrollview
    /// before we do a scroll animation
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if scrollView == contentScrollView {
            enableParallex = true// Always enable after an animation
        }
    }
}