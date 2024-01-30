//
//  NafathAuthentication.m
//  edX
//
//  Created by AbdullahNadeem on 27/12/2023.
//  Copyright © 2023 edX. All rights reserved.
//

#import "NafathAuthentication.h"

static NSString* const NafathTransactionID = @"trans_id";
static NSString* const NafathRandom = @"random";
static NSString* const NafathError = @"error";

@implementation NafathAuthentication

- (id)copyWithZone:(NSZone*)zone {
    id copy = [[NafathAuthentication alloc] initWithTransID:self.transId
                                                     random:self.random
                                                      error:self.error];
    return copy;
}

- (id)initWithTransID:(NSString*)transId
                random:(NSString*)random
                error:(NSString*)error {
    if((self = [super init])) {
        _transId = [transId copy];
        _random = [random copy];
        _error = [error copy];
    }

    return self;
}

- (NafathAuthentication *)initWithAuthenticationDetails:(NSDictionary *)dict {
    self = [super init];
    if(self) {
        _transId = [dict objectForKey:NafathTransactionID];
        _random = [dict objectForKey:NafathRandom];
        _error = [dict objectForKey:NafathError];
    }

    return self;
}

@end
