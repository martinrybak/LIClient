//
//  LIShare.m
//  LIClient
//
//  Created by Martin Rybak on 11/30/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import "LIShare.h"
#import "LIUser.h"

@implementation LIShare

- (id)init
{
	if (self = [super init])
	{
		self.visibility = [[LIVisibility alloc] init];
		self.content = [[LIContent alloc] init];
		self.source = [[LISource alloc] init];
		self.author = [[LIUser alloc] init];
	}
	return self;
}

@end
