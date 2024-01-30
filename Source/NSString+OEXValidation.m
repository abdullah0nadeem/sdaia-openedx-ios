//
//  NSString+OEXValidation.m
//  edXVideoLocker
//
//  Created by Akiva Leffert on 1/26/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

#import "NSString+OEXValidation.h"

@implementation NSString (OEXValidation)

- (BOOL)oex_isValidEmailAddress {
    // Regular expression to check the email format.
    NSString* emailReg = @".+@.+\\..+";

    NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailReg];
    return [emailTest evaluateWithObject:self];
}

- (BOOL)oex_isValidUsername  {
    NSString* usernameRegex = @"^[0-9a-zA-Z-_]{3,30}$";
    NSPredicate* usernameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", usernameRegex];
    return [usernameTest evaluateWithObject:self];
}

- (BOOL)oex_isEmpty {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0;
}

@end
