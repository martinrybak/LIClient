//
//  LILocation.h
//  LIClient
//
//  Created by Martin Rybak on 11/30/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LICountry.h"

@interface LILocation : NSObject

@property (copy, nonatomic) NSString* name;
@property (strong, nonatomic) LICountry* country;

@end
