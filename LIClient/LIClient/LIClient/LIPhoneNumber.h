//
//  LIPhoneNumber.h
//  LIClient
//
//  Created by Martin Rybak on 11/30/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	LIPhoneNumberTypeHome		= 1 << 0,
	LIPhoneNumberTypeWork		= 1 << 1,
    LIPhoneNumberTypeMobile		= 1 << 2
} LIPhoneNumberType;

@interface LIPhoneNumber : NSObject

@property (assign, nonatomic) LIPhoneNumberType type;
@property (copy, nonatomic) NSString* number;

@end
