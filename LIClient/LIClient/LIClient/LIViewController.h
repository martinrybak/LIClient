//
//  UPLinkedInViewController.h
//  Updated
//
//  Created by Martin Rybak on 11/25/13.
//  Copyright (c) 2013 Updated. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LIClient.h"

typedef enum {
	LIPermissionBasicProfile	= 1 << 0,
	LIPermissionFullProfile		= 1 << 1,
    LIPermissionEmailAddress	= 1 << 2,
	LIPermissionNetwork			= 1 << 3,
	LIPermissionContactInfo		= 1 << 4,
	LIPermissionNetworkUpdates	= 1 << 5,
	LIPermissionCompanyAdmin	= 1 << 6,
	LIPermissionGroups			= 1 << 7,
	LIPermissionMessages		= 1 << 8
} LIPermission;

@class LIViewController;

@protocol LIViewControllerDelegate <NSObject>

- (void)linkedInViewControllerIsBusy:(BOOL)busy;
- (void)linkedInViewControllerDidFail:(NSError*)error;
- (void)linkedInViewControllerDidLogin:(LIUser*)user accessToken:(NSString*)accessToken expiration:(NSDate*)expiration;
- (void)linkedInViewControllerDidCancel:(LIViewController*)viewController;

@end

@interface LIViewController : UIViewController <UIWebViewDelegate>

@property (copy, nonatomic) NSString* apiKey;
@property (copy, nonatomic) NSString* secretKey;
@property (copy, nonatomic) NSString* state;
@property (assign, nonatomic) LIPermission permissions;
@property (assign, nonatomic) LIUserField userFields;
@property (weak, nonatomic) id<LIViewControllerDelegate> delegate;
@property (strong, nonatomic) LIClient* client;
@property (strong, nonatomic) IBOutlet UIWebView* webView;
- (id)initWithAPIKey:(NSString*)apiKey secretKey:(NSString*)secretKey state:(NSString*)state permissions:(LIPermission)permissions userFields:(LIUserField)userFields;
+ (BOOL)isNilOrEmpty:(NSString *)input;

@end
