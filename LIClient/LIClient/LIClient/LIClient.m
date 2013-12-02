//
//  UPLinkedInStore.m
//  Updated
//
//  Created by Martin Rybak on 11/27/13.
//  Copyright (c) 2013 Updated. All rights reserved.
//

#import "LIClient.h"
#import "NSString+Helpers.h"
#import "DDXML.h"
#import "LIUser.h"
#import "LIPhoneNumber.h"
#import "LICountry.h"
#import "LILocation.h"
#import "LIPosition.h"

NSString* const UPLinkedCurrentUserInfoUrl = @"https://api.linkedin.com/v1/people/~:(id,email-address,first-name,last-name,headline,picture-url,phone-numbers)?oauth2_access_token=%@";
NSString* const UPLinkedUserInfoUrl = @"https://api.linkedin.com/v1/people/~:(%@)?oauth2_access_token=%@";

@implementation LIClient

#pragma mark - Public

- (id)initWithAccessToken:(NSString*)accessToken
{
	if (self = [super init])
	{
		self.accessToken = accessToken;
	}
	return self;
}

- (void)fetchCurrentUser:(LIUserField)fields success:(void (^)(LIUser* user))success failure:(void (^)(NSError* error))failure
{
	[self fetchCurrentUserInfo:self.accessToken fields:fields success:^(NSString* xml) {
		[self parseUserInfo:xml success:^(LIUser* user) {
			if (success)
				success(user);
		} failure:^(NSError* error) {
			if (failure)
				failure(error);
		}];
	} failure:^(NSError* error) {
		if (failure)
			failure(error);
	}];
}

#pragma mark - Private

- (NSString*)currentUserInfoUrl:(NSString*)accessToken fields:(LIUserField)fields
{
	return [NSString stringWithFormat:UPLinkedUserInfoUrl, [self formatFields:fields], accessToken];
}

-(void)fetchCurrentUserInfo:(NSString*)accessToken fields:(LIUserField)fields success:(void (^)(NSString* xml))success failure:(void (^)(NSError* error))failure
{
    NSString* url = [self currentUserInfoUrl:accessToken fields:fields];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError)
	 {
		 if (connectionError)
			 if (failure)
				 return failure(connectionError);
		 
		 NSString* xml = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		 NSLog(@"%@", xml);
		 if (success)
			 success(xml);
	 }];
}

- (void)parseUserInfo:(NSString*)xml success:(void (^)(LIUser* user))success failure:(void (^)(NSError* error))failure
{
	NSOperationQueue* callbackQueue = [NSOperationQueue currentQueue];
	NSOperationQueue* workerQueue = [[NSOperationQueue alloc] init];
	
	//Perform XML parsing on worker thread
	[workerQueue addOperationWithBlock:^{
		NSError* error;
		DDXMLDocument* doc = [[DDXMLDocument alloc] initWithData:[xml dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
		if (error)
		{
			if (failure)
			{
				return [callbackQueue addOperationWithBlock:^{
					failure(error);
				}];
			}
		}
		
		NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
		
		//Parse phone numbers
		NSMutableArray* phoneNumbers = [[NSMutableArray alloc] init];
		for (DDXMLNode* node in [doc nodesForXPath:@"/person/phone-numbers/phone-number" error:&error])
		{
			LIPhoneNumber* phoneNumber = [[LIPhoneNumber alloc] init];
			phoneNumber.type = [self convertToPhoneNumberType:[[[node nodesForXPath:@"phone-type" error:&error] firstObject] stringValue]];
			phoneNumber.number = [[[node nodesForXPath:@"phone-number" error:&error] firstObject] stringValue];
			[phoneNumbers addObject:phoneNumber];
		}
		
		//Parse current share
		LIShare* currentShare = [[LIShare alloc] init];
		currentShare.shareId = [[[doc nodesForXPath:@"/person/current-share/id" error:&error] firstObject] stringValue];
		currentShare.timeStamp = [self convertToDate:[[[doc nodesForXPath:@"/person/current-share/timestamp" error:&error] firstObject] stringValue]];
		currentShare.visibility.code =  [[[doc nodesForXPath:@"/person/current-share/visibility/code" error:&error] firstObject] stringValue];
		currentShare.comment = [[[doc nodesForXPath:@"/person/current-share/comment" error:&error] firstObject] stringValue];
		currentShare.content.submittedUrl = [[[doc nodesForXPath:@"/person/current-share/content/submitted-url" error:&error] firstObject] stringValue];
		currentShare.content.resolvedUrl = [[[doc nodesForXPath:@"/person/current-share/content/resolved-url" error:&error] firstObject] stringValue];
		currentShare.content.shortenedUrl = [[[doc nodesForXPath:@"/person/current-share/content/shortened-url" error:&error] firstObject] stringValue];
		currentShare.content.title = [[[doc nodesForXPath:@"/person/current-share/content/title" error:&error] firstObject] stringValue];
		currentShare.content.description = [[[doc nodesForXPath:@"/person/current-share/content/description" error:&error] firstObject] stringValue];
		currentShare.content.submittedImageUrl = [[[doc nodesForXPath:@"/person/current-share/content/submitted-image-url" error:&error] firstObject] stringValue];
		currentShare.content.thumbnailUrl = [[[doc nodesForXPath:@"/person/current-share/content/thumbnail-url" error:&error] firstObject] stringValue];
		currentShare.content.eyebrowUrl = [[[doc nodesForXPath:@"/person/current-share/content/eyebrow-url" error:&error] firstObject] stringValue];
		currentShare.source.serviceProvider.name = [[[doc nodesForXPath:@"/person/current-share/source/service-provider/name" error:&error] firstObject] stringValue];
		currentShare.author.memberId = [[[doc nodesForXPath:@"/person/current-share/author/id" error:&error] firstObject] stringValue];
		currentShare.author.firstName = [[[doc nodesForXPath:@"/person/current-share/author/first-name" error:&error] firstObject] stringValue];
		currentShare.author.lastName = [[[doc nodesForXPath:@"/person/current-share/author/last-name" error:&error] firstObject] stringValue];
		
		//Parse positions
		NSMutableArray* positions = [[NSMutableArray alloc] init];
		NSArray* positionsArray = [doc nodesForXPath:@"/person/positions/position" error:&error];
		for (DDXMLNode* node in positionsArray)
		{
			LIPosition* position = [[LIPosition alloc] init];
			position.positionId = [[[node nodesForXPath:@"id" error:&error] firstObject] stringValue];
			position.title = [[[node nodesForXPath:@"title" error:&error] firstObject] stringValue];
			position.summary = [[[node nodesForXPath:@"summary" error:&error] firstObject] stringValue];
			position.startDate.year = [[numberFormatter numberFromString:[[[node nodesForXPath:@"start-date/year" error:&error] firstObject] stringValue]] integerValue];
			position.startDate.month = [[numberFormatter numberFromString:[[[node nodesForXPath:@"start-date/month" error:&error] firstObject] stringValue]] integerValue];
			position.endDate.year = [[numberFormatter numberFromString:[[[node nodesForXPath:@"end-date/year" error:&error] firstObject] stringValue]] integerValue];
			position.endDate.month = [[numberFormatter numberFromString:[[[node nodesForXPath:@"end-date/month" error:&error] firstObject] stringValue]] integerValue];
			position.isCurrent = [self convertToBool:[[[node nodesForXPath:@"is-current" error:&error] firstObject] stringValue]];
			position.company.name = [[[node nodesForXPath:@"company/name" error:&error] firstObject] stringValue];
			position.company.industry = [[[node nodesForXPath:@"company/industry" error:&error] firstObject] stringValue];
			[positions addObject:position];
		}
		
		//Parse root user object
		LIUser* user = [[LIUser alloc] init];
		user.memberId = [[[doc nodesForXPath:@"/person/id" error:&error] firstObject] stringValue];
		user.email = [[[doc nodesForXPath:@"/person/email-address" error:&error] firstObject] stringValue];
		user.firstName = [[[doc nodesForXPath:@"/person/first-name" error:&error] firstObject] stringValue];
		user.lastName = [[[doc nodesForXPath:@"/person/last-name" error:&error] firstObject] stringValue];
		user.headline = [[[doc nodesForXPath:@"/person/headline" error:&error] firstObject] stringValue];
		user.photoUrl = [[[doc nodesForXPath:@"/person/picture-url" error:&error] firstObject] stringValue];
		user.location.name = [[[doc nodesForXPath:@"/person/location/name" error:&error] firstObject] stringValue];
		user.location.country.code = [[[doc nodesForXPath:@"/person/location/country/code" error:&error] firstObject] stringValue];
		user.industry = [[[doc nodesForXPath:@"/person/industry" error:&error] firstObject] stringValue];
		user.distance = [[numberFormatter numberFromString:[[[doc nodesForXPath:@"/person/distance" error:&error] firstObject] stringValue]] integerValue];
		user.relationToViewer = [[numberFormatter numberFromString:[[[doc nodesForXPath:@"/person/relation-to-viewer/distance" error:&error] firstObject] stringValue]] integerValue];
		user.numRecommenders = [[numberFormatter numberFromString:[[[doc nodesForXPath:@"/person/num-recommenders" error:&error] firstObject] stringValue]] integerValue];
		user.numConnections = [[numberFormatter numberFromString:[[[doc nodesForXPath:@"/person/num-connections" error:&error] firstObject] stringValue]] integerValue];
		user.numConnectionsCapped = [self convertToBool:[[numberFormatter numberFromString:[[[doc nodesForXPath:@"/person/num-connections" error:&error] firstObject] stringValue]] stringValue]];
		user.summary = [[[doc nodesForXPath:@"/person/summary" error:&error] firstObject] stringValue];
		user.specialties = [[[doc nodesForXPath:@"/person/specialties" error:&error] firstObject] stringValue];
		user.siteStandardProfileRequest = [[[doc nodesForXPath:@"/person/site-standard-profile-request" error:&error] firstObject] stringValue];
		user.publicProfileUrl = [[[doc nodesForXPath:@"/person/public-profile-url" error:&error] firstObject] stringValue];
		user.currentShare = currentShare;
		user.phoneNumbers = [phoneNumbers copy];
		user.positions = positions;
		
		if (error)
		{
			if (failure)
			{
				return [callbackQueue addOperationWithBlock:^{
					failure(error);
				}];
			}
		}
		
		if (success)
		{
			[callbackQueue addOperationWithBlock:^{
				success(user);
			}];
		}
	}];
}

- (NSString*)formatFields:(LIUserField)fields
{
	NSMutableArray* array = [[NSMutableArray alloc] init];
	
	if((fields & LIUserFieldId) == LIUserFieldId)
		[array addObject:@"id"];
	if((fields & LIUserFieldEmail) == LIUserFieldEmail)
		[array addObject:@"email-address"];
	if((fields & LIUserFieldFirstName) == LIUserFieldFirstName)
		[array addObject:@"first-name"];
	if((fields & LIUserFieldLastName) == LIUserFieldLastName)
		[array addObject:@"last-name"];
	if((fields & LIUserFieldHeadline) == LIUserFieldHeadline)
		[array addObject:@"headline"];
	if((fields & LIUserFieldPhotoUrl) == LIUserFieldPhotoUrl)
		[array addObject:@"picture-url"];
	if((fields & LIUserFieldPhoneNumbers) == LIUserFieldPhoneNumbers)
		[array addObject:@"phone-numbers"];
	if((fields & LIUserFieldLocation) == LIUserFieldLocation)
		[array addObject:@"location"];
	if((fields & LIUserFieldIndustry) == LIUserFieldIndustry)
		[array addObject:@"industry"];
	if((fields & LIUserFieldDistance) == LIUserFieldDistance)
		[array addObject:@"distance"];
	if((fields & LIUserFieldRelationToViewer) == LIUserFieldRelationToViewer)
		[array addObject:@"relation-to-viewer"];
	if((fields & LIUserFieldNumRecommenders) == LIUserFieldNumRecommenders)
		[array addObject:@"num-recommenders"];
	if((fields & LIUserFieldCurrentShare) == LIUserFieldCurrentShare)
		[array addObject:@"current-share"];
	if((fields & LIUserFieldNumConnections) == LIUserFieldNumConnections)
		[array addObject:@"num-connections"];
	if((fields & LIUserFieldNumConnectionsCapped) == LIUserFieldNumConnectionsCapped)
		[array addObject:@"num-connections-capped"];
	if((fields & LIUserFieldSummary) == LIUserFieldSummary)
		[array addObject:@"summary"];
	if((fields & LIUserFieldSpecialties) == LIUserFieldSpecialties)
		[array addObject:@"specialties"];
	if((fields & LIUserFieldPositions) == LIUserFieldPositions)
		[array addObject:@"positions"];
	if((fields & LIUserFieldSiteStandardProfileRequest) == LIUserFieldSiteStandardProfileRequest)
		[array addObject:@"site-standard-profile-request"];
	if((fields & LIUserFieldPublicProfileUrl) == LIUserFieldPublicProfileUrl)
		[array addObject:@"public-profile-url"];
	
	return [array componentsJoinedByString:@","];
}

- (LIPhoneNumberType)convertToPhoneNumberType:(NSString*)input
{
	if ([input isEqualToString:@"home"])
		return LIPhoneNumberTypeHome;
	if ([input isEqualToString:@"work"])
		return LIPhoneNumberTypeWork;
	if ([input isEqualToString:@"mobile"])
		return LIPhoneNumberTypeMobile;
	return 0;
}

- (BOOL)convertToBool:(NSString*)input
{
	if ([input isEqualToString:@"true"])
		return YES;
	return NO;
}

- (NSDate*)convertToDate:(NSString*)input
{
	NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
	NSTimeInterval seconds = [[numberFormatter numberFromString:input] doubleValue] / 1000.0;
	return [NSDate dateWithTimeIntervalSince1970:seconds];
}

- (void)fetchPhoto:(NSString*)url success:(void (^)(UIImage* photo))success failure:(void (^)(NSError* error))failure
{
	NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError)
	 {
		 if (connectionError)
			 if (failure)
				 return failure(connectionError);
		 
		 UIImage* photo = [[UIImage alloc] initWithData:data];
		 if (success)
			 success(photo);
	 }];
}

@end
