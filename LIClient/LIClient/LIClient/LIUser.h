//
//  LIUser.h
//  LIClient
//
//  Created by Martin Rybak on 11/27/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LILocation.h"
#import "LIShare.h"

@interface LIUser : NSObject

@property (nonatomic, strong) NSString* memberId;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;
@property (nonatomic, strong) NSString* headline;
@property (nonatomic, strong) NSArray* phoneNumbers;
@property (nonatomic, strong) NSString* photoUrl;
@property (nonatomic, strong) LILocation* location;
@property (nonatomic, strong) NSString* industry;
@property (nonatomic, assign) NSInteger distance;
@property (nonatomic, assign) NSInteger relationToViewer;
@property (nonatomic, assign) NSInteger numRecommenders;
@property (nonatomic, strong) LIShare* currentShare;
@property (nonatomic, assign) NSInteger numConnections;
@property (nonatomic, assign) BOOL numConnectionsCapped;
@property (nonatomic, strong) NSString* summary;
@property (nonatomic, strong) NSString* specialties;
@property (nonatomic, strong) NSArray* positions;
@property (nonatomic, strong) NSString* siteStandardProfileRequest;
@property (nonatomic, strong) NSString* publicProfileUrl;

- (NSString*)name;

@end
