//
//  LISource.m
//  LIClient
//
//  Created by Martin Rybak on 11/30/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import "LISource.h"

@implementation LISource

- (id)init
{
	if (self = [super init])
	{
		self.serviceProvider = [[LIServiceProvider alloc] init];
	}
	return self;
}

@end
