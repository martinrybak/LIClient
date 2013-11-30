//
//  LIPosition.m
//  LIClient
//
//  Created by Martin Rybak on 11/30/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import "LIPosition.h"

@implementation LIPosition

- (id)init
{
	if (self = [super init])
	{
		self.company = [[LICompany alloc] init];
		self.startDate = [[LIDate alloc] init];
		self.endDate = [[LIDate alloc] init];
	}
	return self;
}

@end
