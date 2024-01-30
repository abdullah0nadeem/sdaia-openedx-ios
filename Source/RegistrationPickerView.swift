//
//  RegistrationPickerView.swift
//  edX
//
//  Created by AbdullahNadeem on 13/12/2023.
//  Copyright © 2023 edX. All rights reserved.
//

import UIKit

fileprivate let titleTextStyle = OEXMutableTextStyle(weight: .normal, size: .base, color: OEXStyles.shared().neutralBlackT())

@objc public class PickerItem: NSObject {
    @objc let key: String
    @objc let value: String
    
    @objc init(key: String, value: String) {
        self.key = key
        self.value = value
    }
    
    var identifier: String {
        return String(describing: Self.self)
    }
}

@objc public final class NafathRegion: PickerItem {
    @objc static var items: [NafathRegion] {
        return [
            .init(key: "", value: ""),
            .init(key: "RD", value: Strings.Nafath.Region.riyadh),
            .init(key: "ER", value: Strings.Nafath.Region.eastern),
            .init(key: "AI", value: Strings.Nafath.Region.asir),
            .init(key: "JA", value: Strings.Nafath.Region.jazan),
            .init(key: "MN", value: Strings.Nafath.Region.medina),
            .init(key: "AS", value: Strings.Nafath.Region.alqassim),
            .init(key: "TU", value: Strings.Nafath.Region.tabuk),
            .init(key: "HI", value: Strings.Nafath.Region.hail),
            .init(key: "NA", value: Strings.Nafath.Region.najran),
            .init(key: "AW", value: Strings.Nafath.Region.aljawaf),
            .init(key: "AA", value: Strings.Nafath.Region.albahah),
            .init(key: "NB", value: Strings.Nafath.Region.northernBorders),
        ]
    }
}

@objc public final class EducationLevel: PickerItem {
    @objc static var items: [EducationLevel] {
        return [
            .init(key: "", value: ""),
            .init(key: "MS", value: Strings.Nafath.Education.Level.middle),
            .init(key: "HS", value: Strings.Nafath.Education.Level.high),
            .init(key: "DM", value: Strings.Nafath.Education.Level.diploma),
            .init(key: "BS", value: Strings.Nafath.Education.Level.bachelor),
            .init(key: "MR", value: Strings.Nafath.Education.Level.master),
            .init(key: "PH", value: Strings.Nafath.Education.Level.phd),
        ]
    }
}

@objc public final class EmploymentStatus: PickerItem {
    @objc static var items: [EmploymentStatus] {
        return [
            .init(key: "", value: ""),
            .init(key: "PU", value: Strings.Nafath.EmploymentLevel.publicIndustry),
            .init(key: "PR", value: Strings.Nafath.EmploymentLevel.privateIndustry),
            .init(key: "JS", value: Strings.Nafath.EmploymentLevel.jobSeeker),
            .init(key: "ST", value: Strings.Nafath.EmploymentLevel.student),
        ]
    }
}

@objc public final class EnglishLanguageLevel: PickerItem {
    @objc static var items: [EnglishLanguageLevel] {
        return [
            .init(key: "", value: ""),
            .init(key: "0", value: Strings.Nafath.English.LanguageLevel.zero),
            .init(key: "1", value: Strings.Nafath.English.LanguageLevel.one),
            .init(key: "2", value: Strings.Nafath.English.LanguageLevel.two),
            .init(key: "3", value: Strings.Nafath.English.LanguageLevel.three),
            .init(key: "4", value: Strings.Nafath.English.LanguageLevel.four),
            .init(key: "5", value: Strings.Nafath.English.LanguageLevel.five),
            .init(key: "6", value: Strings.Nafath.English.LanguageLevel.six),
            .init(key: "7", value: Strings.Nafath.English.LanguageLevel.seven),
            .init(key: "8", value: Strings.Nafath.English.LanguageLevel.eight),
            .init(key: "9", value: Strings.Nafath.English.LanguageLevel.nine),
            .init(key: "10", value: Strings.Nafath.English.LanguageLevel.ten),
        ]
    }
}

@objc public final class WorkExperienceLevel: PickerItem {
    @objc static var items: [WorkExperienceLevel] {
        return [
            .init(key: "", value: ""),
            .init(key: "JL", value: Strings.Nafath.Work.ExperiencLevel.junior),
            .init(key: "ML", value: Strings.Nafath.Work.ExperiencLevel.middle),
            .init(key: "SL", value: Strings.Nafath.Work.ExperiencLevel.senior),
            .init(key: "EL", value: Strings.Nafath.Work.ExperiencLevel.expert),
        ]
    }
}

@objc public final class Gender: PickerItem {
    @objc static var items: [Gender] {
        return [
            .init(key: "m", value: Strings.nafathRegisterationMale),
            .init(key: "f", value: Strings.nafathRegisterationFemale),
        ]
    }
    
    @objc static var male: Gender {
        return .init(key: "m", value: Strings.nafathRegisterationMale)
    }
    
    @objc static var female: Gender {
        return .init(key: "f", value: Strings.nafathRegisterationFemale)
    }
}

@IBDesignable
@objc class RegistrationPickerView: UIView {
    
    //MARK: - Properties
    @objc public var items: [PickerItem] = [] {
        didSet {
            pickerView.reloadAllComponents()
            pickerTextField.accessibilityIdentifier = "RegistrationPickerView:\(items.first?.identifier.lowercased() ?? "")-picker-text-field"
        }
    }
    
    @objc private(set) var isSelected: Bool = false
    
    //MARK: - Clousers
    @objc public var didSelectItem: ((PickerItem) -> Void)?
    @objc public var didDoneTapped: (() -> Void)?
    
    //MARK: - Computed Properties
    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = titleTextStyle.attributedString(withText: title)
        return label
    }()
    
    @objc public lazy var pickerTextField: LogistrationTextField = {
        let textField = LogistrationTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = OEXFonts.sharedInstance.font(for: .Regular, size: 12, dynamicTypeSupported: true)
        textField.inputView = pickerView
        textField.inputAccessoryView = pickerToolBar
        textField.delegate = self
        return textField
    }()
    
    private lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    private lazy var pickerToolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = OEXColors.sharedInstance.color(forIdentifier: .secondaryBaseColor)
        toolBar.sizeToFit()
        toolBar.isUserInteractionEnabled = true
        toolBar.setItems([doneButton], animated: false)
        return toolBar
    }()
    
    private lazy var doneButton: UIBarButtonItem = {
       let button = UIBarButtonItem()
        button.title = Strings.doneTitle
        button.style = .done
        button.tintColor = OEXColors.sharedInstance.color(forIdentifier: .secondaryBaseColor)
        button.target = self
        button.action = #selector(didPickerDoneTapped(_:))
        return button
    }()
    
    //MARK: - @IBInspectable properties
    @IBInspectable
    @objc public var title: String = "Label" {
        didSet {
            titleLabel.attributedText = titleTextStyle.attributedString(withText: title)
        }
    }
    
    //MARK: - Initilization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commanInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commanInit()
    }
    
    //MARK: - View setup
    func commanInit() {
        addSubview(titleLabel)
        addSubview(pickerTextField)
        setupUI()
    }
    
    private func setupUI() {
        self.backgroundColor = .clear
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
        }
        
        pickerTextField.snp.makeConstraints { make in
            make.leading.equalTo(self)
            make.trailing.equalTo(self).offset(8.0)
            make.bottom.equalTo(self)
            make.top.equalTo(titleLabel.snp.bottom).offset(8.0)
            make.height.equalTo(40.0)
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    //MARK: - Configuration
    @objc public func configure(
        _ items: [PickerItem],
        didSelectItem: @escaping ((PickerItem) -> Void)
    ) {
        self.items = items
        self.didSelectItem = didSelectItem
    }
    
    //MARK: - Actions
    @objc func didPickerDoneTapped(_ sender: Any) {
        pickerTextField.resignFirstResponder()
        didDoneTapped?()
    }
}

extension RegistrationPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row].value
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let item = items[row]
        pickerTextField.text = item.value
        isSelected = !item.value.isEmpty
        didSelectItem?(item)
    }
}

extension RegistrationPickerView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        pickerView.reloadAllComponents()
    }
}
