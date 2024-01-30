//
//  SegmentControllerCell.swift
//  edX
//
//  Created by AbdullahNadeem on 08/12/2023.
//  Copyright © 2023 edX. All rights reserved.
//

import UIKit

class SegmentControllerCell: UICollectionViewCell {

    static let identifier: String = "SegmentControllerCell"
    
    @IBOutlet weak var segmentButton: UIButton!
    @IBOutlet weak var dividerView: UIView!
    
    private var segmentTapAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dividerView.accessibilityIdentifier = "SegmentControllerCell:divider-view"
    }
    
    func configure(title: String, titleColor: UIColor, dividerColor: UIColor, titleFont: UIFont, isSelected: Bool, index: Int, segmentTapAction: @escaping (() -> Void)) {
        segmentButton.setTitle(title, for: .normal)
        segmentButton.titleLabel?.font = titleFont
        segmentButton.tintColor = titleColor
        segmentButton.titleLabel?.textColor = titleColor
        dividerView.backgroundColor = dividerColor
        self.segmentTapAction = segmentTapAction
        segmentButton.accessibilityIdentifier = "SegmentControllerCell:segment-button-\(index)"
    }
    
    class func width(title: String, font: UIFont, padding: CGFloat) -> CGFloat {
        if title.isEmpty { return 0.0 }
        
        let string = title as NSString
        let width = string.size(withAttributes: [NSAttributedString.Key.font: font]).width
        return width + padding
    }
    
    @IBAction func didSegmentTapped(_ sender: UIButton) {
        self.segmentTapAction?()
    }
}
