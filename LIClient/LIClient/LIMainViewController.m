//
//  LIMainViewController.m
//  LIClient
//
//  Created by Martin Rybak on 11/29/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import "LIMainViewController.h"
#import "LIProfileViewController.h"
#import "LIViewController.h"
#import "MBProgressHUD.h"
#import "NSString+CJStringValidator.h"
#import "GSKeychain.h"

LIPermission const LIMainViewControllerDefaultPermissions = LIPermissionBasicProfile|LIPermissionEmailAddress;
LIUserField const LIMainViewControllerDefaultUserFields = LIUserFieldId|LIUserFieldFirstName|LIUserFieldLastName|LIUserFieldEmail|LIUserFieldHeadline|LIUserFieldPhotoUrl;

@interface LIMainViewController ()

@property (strong, nonatomic) LIUser* user;

@end

@implementation LIMainViewController

#pragma mark - UIViewController

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showLinkedInLogin"])
	{
		LIViewController* liViewController = [segue destinationViewController];
				
		#warning Replace values with your own
		liViewController.apiKey = @"ENTER YOUR LINKEDIN API KEY";
		liViewController.secretKey = @"ENTER YOUR LINKEDIN SECRET KEY";
		liViewController.state = @"ENTER A RANDOM STRING";
		
		liViewController.delegate = self;
		liViewController.permissions = LIMainViewControllerDefaultPermissions;
		liViewController.userFields = LIMainViewControllerDefaultUserFields;
	}
    if ([[segue identifier] isEqualToString:@"showLinkedInProfile"])
	{
		LIProfileViewController* liProfileViewController = [segue destinationViewController];
		liProfileViewController.user = self.user;
	}
}

- (IBAction)login:(id)sender
{
	NSString* accessToken = [[GSKeychain systemKeychain] secretForKey:@"accessToken"];
	if (!accessToken)
		return [self performSegueWithIdentifier:@"showLinkedInLogin" sender:self];
	
	LIClient* client = [[LIClient alloc] initWithAccessToken:accessToken];
	[client fetchCurrentUser:LIMainViewControllerDefaultUserFields success:^(LIUser* user) {
		self.user = user;
		[self performSegueWithIdentifier:@"showLinkedInProfile" sender:self];
	} failure:^(NSError* error) {
		[self error:error];
	}];
}

#pragma mark - LIViewControllerDelegate

- (void)linkedInViewControllerIsBusy:(BOOL)busy
{
	UIWindow* window = [[[UIApplication sharedApplication] windows] lastObject];
	if (busy)
		[MBProgressHUD showHUDAddedTo:window animated:YES];
	else
		[MBProgressHUD hideHUDForView:window animated:YES];
}

- (void)linkedInViewControllerDidFail:(NSError*)error
{
	[self dismissViewControllerAnimated:YES completion:nil];
	[self error:error];
}

- (void)linkedInViewControllerDidLogin:(LIUser*)user accessToken:(NSString *)accessToken expiration:(NSDate*)expiration
{
	//Save the accessToken to the secure iOS keychain so that you can query the LinkedIn API using only LIClient in the future
	[[GSKeychain systemKeychain] setSecret:accessToken forKey:@"accessToken"];
	
	self.user = user;
	[self dismissViewControllerAnimated:YES completion:^{
		[self performSegueWithIdentifier:@"showLinkedInProfile" sender:self];
	}];
}

- (void)linkedInViewControllerDidCancel:(LIViewController*)viewController
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)error:(NSError*)error
{
	[[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

@end
