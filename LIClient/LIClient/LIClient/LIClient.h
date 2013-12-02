//
//  LIClient.h
//  LIClient
//
//  Created by Martin Rybak on 11/27/13.
//  Copyright (c) 2013 Updated. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LIUser.h"

typedef enum {
	LIUserFieldId					= 1 << 0,
	LIUserFieldEmail				= 1 << 1,
	LIUserFieldFirstName			= 1 << 2,
    LIUserFieldLastName				= 1 << 3,
	LIUserFieldHeadline				= 1 << 4,
	LIUserFieldPhotoUrl				= 1 << 5,
	LIUserFieldPhoneNumbers			= 1 << 6,
	LIUserFieldLocation				= 1 << 7,
	LIUserFieldIndustry				= 1 << 8,
	LIUserFieldDistance				= 1 << 9,
	LIUserFieldRelationToViewer		= 1 << 10,
	LIUserFieldNumRecommenders		= 1 << 11,
	LIUserFieldCurrentShare			= 1 << 12,
	LIUserFieldNumConnections		= 1 << 12,
	LIUserFieldNumConnectionsCapped = 1 << 13,
	LIUserFieldSummary				= 1 << 14,
	LIUserFieldSpecialties			= 1 << 15,
	LIUserFieldPositions			= 1 << 16,
	LIUserFieldSiteStandardProfileRequest = 1 << 17,
	LIUserFieldPublicProfileUrl		= 1 << 18
} LIUserField;

@interface LIClient : NSObject

@property (copy, nonatomic) NSString* accessToken;
- (id)initWithAccessToken:(NSString*)accessToken;
- (void)fetchCurrentUser:(LIUserField)fields success:(void (^)(LIUser* user))success failure:(void (^)(NSError* error))failure;
- (void)fetchPhoto:(NSString*)url success:(void (^)(UIImage* photo))success failure:(void (^)(NSError* error))failure;

@end
