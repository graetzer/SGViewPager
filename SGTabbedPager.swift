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
    private var tabLabels = [UILabel]()
    private var bottomLine, tabIndicator : UIView!
    private var selectedIndex : Int = 0
    
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
    
    public override func loadView() {
        super.loadView()
        let size = self.view.bounds.size
        titleScrollView = UIScrollView(frame: CGRectZero)
        titleScrollView.autoresizingMask = .FlexibleWidth | .FlexibleBottomMargin
        titleScrollView.backgroundColor = UIColor.whiteColor()
        titleScrollView.canCancelContentTouches = false
        titleScrollView.showsHorizontalScrollIndicator = false
        titleScrollView.bounces = false
        titleScrollView.delegate = self
        titleScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(titleScrollView)
        
        bottomLine = UIView(frame: CGRectZero)
        bottomLine.backgroundColor = tabColor
        titleScrollView.addSubview(bottomLine)
        tabIndicator = UIView(frame: CGRectZero)
        tabIndicator.backgroundColor = tabColor
        titleScrollView.addSubview(tabIndicator)
        
        contentScrollView = UIScrollView(frame: CGRectZero)
        contentScrollView.autoresizingMask = .FlexibleWidth | .FlexibleBottomMargin
        contentScrollView.backgroundColor = UIColor.whiteColor()
        contentScrollView.delaysContentTouches = false
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.pagingEnabled = true
        contentScrollView.delegate = self
        contentScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(contentScrollView)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.layout()
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
    }
    
    public func switchPage(animated : Bool) {
        let frame = CGRectMake(contentScrollView.frame.size.width * CGFloat(selectedIndex), 0,
            contentScrollView.frame.size.width, contentScrollView.frame.size.height) ;
        if frame.origin.x < contentScrollView.contentSize.width {
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
            let label = UILabel(frame: CGRectZero)
            label.text = self.datasource?.viewControllerTitle(i)
            label.font = font
            label.textAlignment = .Center
            label.sizeToFit()
            titleScrollView.addSubview(label)
            tabLabels.append(label)
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
                UIView.animateWithDuration(0.3, animations: layoutTabIndicator)
            }
            
            var ignored : Double = 0.0
            page = scrollView.contentOffset.x / pageWidth;
            let index = Int(page)
            if index + 1 < viewControllerCount {
                let diff = tabLabels[index+1].frame.origin.x - tabLabels[index].frame.origin.x
                let centering = (titleScrollView.frame.size.width - tabLabels[index].frame.size.width)/2
                let centering2 = (titleScrollView.frame.size.width - tabLabels[index+1].frame.size.width)/2
                let frac = CGFloat(modf(Double(page), &ignored))
                let newXOff = tabLabels[index].frame.origin.x + diff * frac - centering * (1-frac) - centering2 * frac;
                titleScrollView.contentOffset = CGPointMake(newXOff, 0)
            }
        }
    }
}

extension Int {
    var f: CGFloat { return CGFloat(self) }
}

extension Float {
    var f: CGFloat { return CGFloat(self) }
}

extension Double {
    var f: CGFloat { return CGFloat(self) }
}


