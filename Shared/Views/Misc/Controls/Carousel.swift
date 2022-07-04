//
//  Carousel.swift
//  Go London
//
//  Created by Tom Knighton on 04/07/2022.
//

import UIKit
import SwiftUI
import GoLondonSDK

public struct SnapCarouselView: UIViewRepresentable {
    
    @State var items: [StopPointAnnotation]
    @State var itemWidth: CGFloat
    @Binding var selectedIndex: Int?
    
    @State private var selectedIndexCache: Int?
    @State private var isDragging: Bool = false
    @State private var hasScrolledToFirstIndex: Bool = false
        
    public class Coordinator: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
        
        let parent: SnapCarouselView
        
        init(_ parent: SnapCarouselView) {
            self.parent = parent
        }
        
        public func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        
        public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.parent.items.count
        }
        
        public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stopPointDetailView", for: indexPath)
            
            let item = self.parent.items[indexPath.row]
            
            cell.contentConfiguration = UIHostingConfiguration {
                VStack { } // Needed to fix re-use bug
            }
            cell.contentConfiguration = UIHostingConfiguration {
                StopPointDetailView(stopPoint: item.stopPoint)
            }
            
            if let selectedIndex = self.parent.selectedIndex, self.parent.hasScrolledToFirstIndex == false {
                collectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
                self.parent.hasScrolledToFirstIndex = true
            }
            
            return cell
        }
        
        
        public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            self.parent.isDragging = true
        }
        public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let pageSide = self.parent.itemWidth
            let offset = scrollView.contentOffset.x
            self.parent.selectedIndexCache = Int(floor((offset - pageSide / 2) / pageSide) + 1)
            self.parent.selectedIndex = Int(floor((offset - pageSide / 2) / pageSide) + 1)
            self.parent.isDragging = false
        }
        
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIView(context: Context) -> UICollectionView {
        let layout = UPCarouselFlowLayout()
        layout.itemSize = CGSize(width: self.itemWidth, height: 200)
        layout.scrollDirection = .horizontal
        layout.spacingMode = .overlap(visibleOffset: 20)
        layout.sideItemAlpha = 1
        layout.sideItemScale = 0.8
        let upView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        upView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "stopPointDetailView")
        
        upView.delegate = context.coordinator
        upView.dataSource = context.coordinator
        upView.backgroundColor = .clear
        
        return upView
    }
    
    public func updateUIView(_ uiView: UICollectionView, context: Context) {
        
        if self.selectedIndexCache != self.selectedIndex,
           !isDragging,
            let selectedIndex {
            DispatchQueue.main.async {
                uiView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
                self.selectedIndexCache = self.selectedIndex
            }
        }
    }
}

public enum UPCarouselFlowLayoutSpacingMode {
    case fixed(spacing: CGFloat)
    case overlap(visibleOffset: CGFloat)
}


open class UPCarouselFlowLayout: UICollectionViewFlowLayout {
    
    fileprivate struct LayoutState {
        var size: CGSize
        var direction: UICollectionView.ScrollDirection
        func isEqual(_ otherState: LayoutState) -> Bool {
            return self.size.equalTo(otherState.size) && self.direction == otherState.direction
        }
    }
    
    @IBInspectable open var sideItemScale: CGFloat = 0.6
    @IBInspectable open var sideItemAlpha: CGFloat = 0.6
    @IBInspectable open var sideItemShift: CGFloat = 0.0
    open var spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: 40)
    
    fileprivate var state = LayoutState(size: CGSize.zero, direction: .horizontal)
    
    
    override open func prepare() {
        super.prepare()
        let currentState = LayoutState(size: self.collectionView!.bounds.size, direction: self.scrollDirection)
        
        if !self.state.isEqual(currentState) {
            self.setupCollectionView()
            self.updateLayout()
            self.state = currentState
        }
    }
    
    fileprivate func setupCollectionView() {
        guard let collectionView = self.collectionView else { return }
        if collectionView.decelerationRate != UIScrollView.DecelerationRate.fast {
            collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        }
    }
    
    fileprivate func updateLayout() {
        guard let collectionView = self.collectionView else { return }
        
        let collectionSize = collectionView.bounds.size
        let isHorizontal = (self.scrollDirection == .horizontal)
        
        let yInset = (collectionSize.height - self.itemSize.height) / 2
        let xInset = (collectionSize.width - self.itemSize.width) / 2
        self.sectionInset = UIEdgeInsets.init(top: yInset, left: xInset, bottom: yInset, right: xInset)
        
        let side = isHorizontal ? self.itemSize.width : self.itemSize.height
        let scaledItemOffset =  (side - side*self.sideItemScale) / 2
        switch self.spacingMode {
        case .fixed(let spacing):
            self.minimumLineSpacing = spacing - scaledItemOffset
        case .overlap(let visibleOffset):
            let fullSizeSideItemOverlap = visibleOffset + scaledItemOffset
            let inset = isHorizontal ? xInset : yInset
            self.minimumLineSpacing = inset - fullSizeSideItemOverlap
        }
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributes = super.layoutAttributesForElements(in: rect),
            let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes]
            else { return nil }
        return attributes.map({ self.transformLayoutAttributes($0) })
    }
    
    fileprivate func transformLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let collectionView = self.collectionView else { return attributes }
        let isHorizontal = (self.scrollDirection == .horizontal)
        
        let collectionCenter = isHorizontal ? collectionView.frame.size.width/2 : collectionView.frame.size.height/2
        let offset = isHorizontal ? collectionView.contentOffset.x : collectionView.contentOffset.y
        let normalizedCenter = (isHorizontal ? attributes.center.x : attributes.center.y) - offset
        
        let maxDistance = (isHorizontal ? self.itemSize.width : self.itemSize.height) + self.minimumLineSpacing
        let distance = min(abs(collectionCenter - normalizedCenter), maxDistance)
        let ratio = (maxDistance - distance)/maxDistance
        
        let alpha = ratio * (1 - self.sideItemAlpha) + self.sideItemAlpha
        let scale = ratio * (1 - self.sideItemScale) + self.sideItemScale
        let shift = (1 - ratio) * self.sideItemShift
        attributes.alpha = alpha
        attributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
        attributes.zIndex = Int(alpha * 10)
        
        if isHorizontal {
            attributes.center.y = attributes.center.y + shift
        } else {
            attributes.center.x = attributes.center.x + shift
        }
        
        return attributes
    }
    
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView , !collectionView.isPagingEnabled,
            let layoutAttributes = self.layoutAttributesForElements(in: collectionView.bounds)
            else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset) }
        
        let isHorizontal = (self.scrollDirection == .horizontal)
        
        let midSide = (isHorizontal ? collectionView.bounds.size.width : collectionView.bounds.size.height) / 2
        let proposedContentOffsetCenterOrigin = (isHorizontal ? proposedContentOffset.x : proposedContentOffset.y) + midSide
        
        var targetContentOffset: CGPoint
        if isHorizontal {
            let closest = layoutAttributes.sorted { abs($0.center.x - proposedContentOffsetCenterOrigin) < abs($1.center.x - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
            targetContentOffset = CGPoint(x: floor(closest.center.x - midSide), y: proposedContentOffset.y)
        }
        else {
            let closest = layoutAttributes.sorted { abs($0.center.y - proposedContentOffsetCenterOrigin) < abs($1.center.y - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
            targetContentOffset = CGPoint(x: proposedContentOffset.x, y: floor(closest.center.y - midSide))
        }
        
        return targetContentOffset
    }
}

