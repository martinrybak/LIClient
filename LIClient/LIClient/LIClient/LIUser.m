//
//  LIUser.m
//  LIClient
//
//  Created by Martin Rybak on 11/27/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import "LIUser.h"

@implementation LIUser

- (id)init
{
	if (self = [super init])
	{
		self.location = [[LILocation alloc] init];
	}
	return self;
}

- (NSString*)name
{
	return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

@end
