//
//  LIShare.h
//  LIClient
//
//  Created by Martin Rybak on 11/30/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LIVisibility.h"
#import "LIContent.h"
#import "LISource.h"

@class LIUser;

@interface LIShare : NSObject

@property (strong, nonatomic) NSString* shareId;
@property (strong, nonatomic) NSDate* timeStamp;
@property (strong, nonatomic) LIVisibility* visibility;
@property (strong, nonatomic) NSString* comment;
@property (strong, nonatomic) LIContent* content;
@property (strong, nonatomic) LISource* source;
@property (strong, nonatomic) LIUser* author;

@end
