//
//  SegmentControllerView.swift
//  edX
//
//  Created by AbdullahNadeem on 08/12/2023.
//  Copyright © 2023 edX. All rights reserved.
//

import UIKit

@objc enum Segment: Int, CaseIterable {
    case nafath
    case edx
}

@objc enum SegmentState: Int, CaseIterable {
    case selected
    case normal
}

@objc protocol SegmentControllerDelegate: AnyObject {
    func segmentControllerView(_ segmentControllerView: SegmentControllerView, didSelectSegmentAt segment: Segment)
    func segmentControllerView(_ segmentControllerView: SegmentControllerView, titleForSegment segment: Segment) -> String
    func fontForTitle() -> UIFont
    func paddingForSegment() -> CGFloat
    func titleColor(for state: SegmentState) -> UIColor
    func dividerColor(for state: SegmentState) -> UIColor
}

class SegmentControllerView: UIView {
    
    @objc lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isUserInteractionEnabled = true
        collectionView.register(UINib(nibName: SegmentControllerCell.identifier, bundle: nil), forCellWithReuseIdentifier: SegmentControllerCell.identifier)
        collectionView.accessibilityIdentifier = "SegmentControllerDelegate:collection-view"
        return collectionView
    }()
    
    private lazy var dividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = OEXStyles.shared().neutralBase()
        return view
    }()
    
    @objc weak var delegate: SegmentControllerDelegate?
    
    private var cellSelected: [Bool] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commanInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commanInit()
    }
    
    func commanInit() {
        addSubview(dividerView)
        addSubview(collectionView)
        setupUI()
        initSelectedStates()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        collectionView.backgroundColor = .clear
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        dividerView.snp.makeConstraints { make in
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.bottom.equalTo(self)
            make.height.equalTo(2.0)
        }
    }
    
    private func initSelectedStates() {
        Segment.allCases.forEach { _ in
            cellSelected.append(false)
        }
        cellSelected[0] = true
    }
}

extension SegmentControllerView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if !OEXConfig.shared().isEDXEnabled {
            return Segment.allCases.filter { $0 != .edx }.count
        }
        return Segment.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SegmentControllerCell.identifier, for: indexPath) as! SegmentControllerCell
        
        guard let delegate = delegate else {
            return UICollectionViewCell()
        }
        
        let segment: Segment = Segment(rawValue: indexPath.section) ?? .nafath
        let title: String = delegate.segmentControllerView(self, titleForSegment: segment)
        let font: UIFont = delegate.fontForTitle()
        let isSelected: Bool = cellSelected[indexPath.section]
        let titleColor: UIColor = delegate.titleColor(for: isSelected ? .selected : .normal)
        let dividerColor: UIColor = delegate.dividerColor(for: isSelected ? .selected : .normal)
        
        cell.configure(title: title, titleColor: titleColor, dividerColor: dividerColor, titleFont: font, isSelected: isSelected, index: indexPath.section) { [weak self] in
            self?.reloadCollectionView(indexPath, didSelectSegmentAt: segment)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = delegate?.paddingForSegment() ?? 8.0
        let segment: Segment = Segment(rawValue: indexPath.section) ?? .nafath
        let title = delegate?.segmentControllerView(self, titleForSegment: segment) ?? ""
        let font = delegate?.fontForTitle() ?? OEXStyles.shared().regularFont(ofSize: 14)
        return CGSize(width: SegmentControllerCell.width(title: title, font: font, padding: 38.0) - padding, height: collectionView.frame.size.height - padding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let padding = delegate?.paddingForSegment() ?? 8.0
        return UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
    
    private func reloadCollectionView(_ indexPath: IndexPath, didSelectSegmentAt segment: Segment) {
        guard !self.cellSelected[indexPath.section] else { return }
        self.cellSelected = self.cellSelected.map { _ in false}
        self.cellSelected[indexPath.section] = true
        collectionView.reloadData()
        delegate?.segmentControllerView(self, didSelectSegmentAt: segment)
    }
}
