//
//  TermsAndPolicyView.swift
//  edX
//
//  Created by AbdullahNadeem on 14/12/2023.
//  Copyright © 2023 edX. All rights reserved.
//

import UIKit

@objc protocol TermsAndPolicyTextViewDelegate: AnyObject {
    func termsAndPolicyTextView(_ textView: TermsAndPolicyTextView, didSelect url: URL)
}

public class TermsAndPolicyTextView: UITextView {
    
    @objc weak var policyDelegate: TermsAndPolicyTextViewDelegate?
    
    @objc func setup(for config: OEXConfig?) {
        let style = OEXMutableTextStyle(weight: .normal, size: .xxxSmall, color: OEXStyles.shared().neutralXDark())
        style.lineBreakMode = .byWordWrapping
        style.alignment = isRTL ? .right : .left
        let termsAndPolicyText = Strings.nafathRegisterationTermsAndConditionPolicy(sdaiaTermsName: Strings.sdaiaTermsName)
        var attributedString = style.attributedString(withText: termsAndPolicyText)
        if let privacyPolicyUrl = config?.agreementURLsConfig.privacyPolicyURL {
            attributedString = attributedString.addLink(on: termsAndPolicyText, value: privacyPolicyUrl)
        }
        tintColor = OEXStyles.shared().primaryDarkColor()
        attributedText = attributedString
        semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
        isUserInteractionEnabled = true
        isScrollEnabled = false
        isEditable = false
        delegate = self
    }
    
    private var isRTL: Bool {
        return UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft;
    }
}

extension TermsAndPolicyTextView: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        policyDelegate?.termsAndPolicyTextView(self, didSelect: URL)
        return false
    }
}
