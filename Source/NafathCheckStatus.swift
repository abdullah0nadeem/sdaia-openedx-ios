//
//  NafathCheckStatus.swift
//  edX
//
//  Created by AbdullahNadeem on 27/12/2023.
//  Copyright © 2023 edX. All rights reserved.
//

import Foundation

public class NafathCheckStatus: NSObject {
    @objc public var value: String?
    @objc public var person: NafathPerosn?
    @objc public var error: String?
    
    @objc public init?(dict: NSDictionary?) {
        self.value = dict?["status"] as? String
        self.person = NafathPerosn(dict: dict?["person"] as? NSDictionary)
        if let errors = dict?["error"] as? [String] {
            self.error = errors.joined(separator: "\n")
        } else {
            self.error = dict?["error"] as? String
        }
    }
}

public class NafathPerosn: NSObject {
    @objc public var id: String?
    @objc public var id_version: String?
    @objc public var first_name_ar: String?
    @objc public var father_name_ar: String?
    @objc public var grand_name_ar: String?
    @objc public var family_name_ar: String?
    @objc public var first_name_en: String?
    @objc public var father_name_en: String?
    @objc public var grand_name_en: String?
    @objc public var family_name_en: String?
    @objc public var two_names_ar: String?
    @objc public var two_names_en: String?
    @objc public var full_name_ar: String?
    @objc public var full_name_en: String?
    @objc public var gender: String?
    @objc public var id_issue_date_g: String?
    public var id_issue_date_h: NSInteger?
    @objc public var id_expiry_date_g: String?
    public var id_expiry_date_h: NSInteger?
    @objc public var language: String?
    public var nationality: NSInteger?
    @objc public var nationality_ar: String?
    @objc public var nationality_en: String?
    @objc public var dob_g: String?
    public var dob_h: NSInteger?
    @objc public var card_issue_place_ar: String?
    @objc public var card_issue_place_en: String?
    @objc public var birth_place_ar: String?
    @objc public var title_desc_ar: String?
    @objc public var title_desc_en: String?
    
    @objc public init?(dict: NSDictionary?) {
        self.id = dict?["id"] as? String
        self.id_version = dict?["id_version"] as? String
        self.first_name_ar = dict?["first_name#ar"] as? String
        self.father_name_ar = dict?["father_name#ar"] as? String
        self.grand_name_ar = dict?["grand_name#ar"] as? String
        self.family_name_ar = dict?["family_name#ar"] as? String
        self.first_name_en = dict?["first_name#en"] as? String
        self.father_name_en = dict?["father_name#en"] as? String
        self.grand_name_en = dict?["grand_name#en"] as? String
        self.family_name_en = dict?["family_name#en"] as? String
        self.two_names_ar = dict?["two_names#ar"] as? String
        self.two_names_en = dict?["two_names#en"] as? String
        self.full_name_ar = dict?["full_name#ar"] as? String
        self.full_name_en = dict?["full_name#en"] as? String
        self.gender = dict?["gender"] as? String
        self.id_issue_date_g = dict?["id_issue_date#g"] as? String
        self.id_issue_date_h = dict?["id_issue_date#h"] as? NSInteger
        self.id_expiry_date_g = dict?["id_expiry_date#g"] as? String
        self.id_expiry_date_h = dict?["id_expiry_date#h"] as? NSInteger
        self.language = dict?["language"] as? String
        self.nationality = dict?["nationality"] as? NSInteger
        self.nationality_ar = dict?["nationality#ar"] as? String
        self.nationality_en = dict?["nationality#en"] as? String
        self.dob_g = dict?["dob#g"] as? String
        self.dob_h = dict?["dob#h"] as? NSInteger
        self.card_issue_place_ar = dict?["card_issue_place#ar"] as? String
        self.card_issue_place_en = dict?["card_issue_place#en"] as? String
        self.birth_place_ar = dict?["birth_place#ar"] as? String
        self.title_desc_ar = dict?["title_desc#ar"] as? String
        self.title_desc_en = dict?["title_desc#en"] as? String
    }
}
