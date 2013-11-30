//
//  LIContent.h
//  LIClient
//
//  Created by Martin Rybak on 11/30/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LIContent : NSObject

@property (nonatomic, strong) NSString* submittedUrl;
@property (nonatomic, strong) NSString* resolvedUrl;
@property (nonatomic, strong) NSString* shortenedUrl;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* description;
@property (nonatomic, strong) NSString* submittedImageUrl;
@property (nonatomic, strong) NSString* thumbnailUrl;
@property (nonatomic, strong) NSString* eyebrowUrl;

@end
