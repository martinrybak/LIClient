//
//  LILocation.m
//  LIClient
//
//  Created by Martin Rybak on 11/30/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import "LILocation.h"

@implementation LILocation

- (id)init
{
	if (self = [super init])
	{
		self.country = [[LICountry alloc] init];
	}
	return self;
}

@end
