//
//  LIPosition.h
//  LIClient
//
//  Created by Martin Rybak on 11/30/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LICompany.h"
#import "LIDate.h"

@interface LIPosition : NSObject

@property (strong, nonatomic) NSString* positionId;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* summary;
@property (strong, nonatomic) LIDate* startDate;
@property (strong, nonatomic) LIDate* endDate;
@property (assign, nonatomic) BOOL isCurrent;
@property (strong, nonatomic) LICompany* company;

@end
