//
//  LIProfileViewController.h
//  LIClient
//
//  Created by Martin Rybak on 11/29/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LIUser.h"

@class LIProfileViewController;

@protocol LIProfileViewControllerDelegate <NSObject>

- (void)linkedInProfileViewController:(LIProfileViewController*)viewController isBusy:(BOOL)busy;
- (void)linkedInProfileViewController:(LIProfileViewController*)viewController didFail:(NSString*)error;
- (void)linkedInProfileViewControllerDidFinish:(LIProfileViewController*)viewController;

@end

@interface LIProfileViewController : UIViewController

@property (strong, nonatomic) NSString* accessToken;
@property (weak, nonatomic) id<LIProfileViewControllerDelegate> delegate;

@end
