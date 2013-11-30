//
//  LICompany.h
//  LIClient
//
//  Created by Martin Rybak on 11/30/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LICompany : NSObject

@property (strong, nonatomic) NSString* companyId;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* type;
@property (strong, nonatomic) NSString* size;
@property (strong, nonatomic) NSString* industry;
@property (strong, nonatomic) NSString* ticker;

@end
