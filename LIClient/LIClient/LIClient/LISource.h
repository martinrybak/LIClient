//
//  LISource.h
//  LIClient
//
//  Created by Martin Rybak on 11/30/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LIServiceProvider.h"

@interface LISource : NSObject

@property (strong, nonatomic) LIServiceProvider* serviceProvider;

@end
