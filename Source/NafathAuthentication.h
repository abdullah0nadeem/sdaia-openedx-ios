//
//  NafathAuthentication.h
//  edX
//
//  Created by AbdullahNadeem on 27/12/2023.
//  Copyright © 2023 edX. All rights reserved.
//

#ifndef NafathAuthentication_h
#define NafathAuthentication_h

@interface NafathAuthentication : NSObject <NSCopying>

- (NafathAuthentication* _Nullable)initWithAuthenticationDetails:(NSDictionary* _Nonnull)dict;

@property(nonatomic, copy, nullable) NSString* error;
@property(nonatomic, copy, nullable) NSString* transId;
@property(nonatomic, copy, nullable) NSString* random;

@end

#endif /* NafathAuthentication_h */
