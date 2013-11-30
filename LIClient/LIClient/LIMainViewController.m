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

NSString* const LIAccessTokenKey = @"LIAccessTokenKey";

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
		liViewController.delegate = self;
		liViewController.apiKey = @"ENTER YOUR LINKEDIN API KEY";
		liViewController.secretKey = @"ENTER YOUR LINKEDIN SECRET KEY";
		liViewController.state = @"ENTER A RANDOM STRING";
		liViewController.permissions = LIPermissionBasicProfile | LIPermissionFullProfile | LIPermissionContactInfo | LIPermissionEmailAddress | LIPermissionMessages | LIPermissionNetwork;
    }
    if ([[segue identifier] isEqualToString:@"showLinkedInProfile"])
	{
		LIProfileViewController* liProfileViewController = [segue destinationViewController];
		liProfileViewController.accessToken = [[GSKeychain systemKeychain] secretForKey:LIAccessTokenKey];
		liProfileViewController.delegate = self;
	}
}

- (IBAction)linkedInLogin:(id)sender
{
	NSString* accessToken = [[GSKeychain systemKeychain] secretForKey:LIAccessTokenKey];
	if ([LIViewController isNilOrEmpty:accessToken])
		[self performSegueWithIdentifier:@"showLinkedInLogin" sender:self];
	else
		[self performSegueWithIdentifier:@"showLinkedInProfile" sender:self];
}

#pragma mark - LIViewControllerDelegate

- (void)linkedInViewController:(LIViewController*)viewController isBusy:(BOOL)busy
{
	[self busy:busy];
}

- (void)linkedInViewController:(LIViewController*)viewController didFail:(NSString*)error
{
	[self error:error];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)linkedInViewController:(LIViewController*)viewController didSucceed:(NSString*)accessToken expiration:(NSDate*)expiration
{
	[[GSKeychain systemKeychain] setSecret:accessToken forKey:LIAccessTokenKey];
	[self dismissViewControllerAnimated:YES completion:^{
		[self performSegueWithIdentifier:@"showLinkedInProfile" sender:self];
	}];
}

- (void)linkedInViewControllerDidCancel:(LIViewController*)viewController
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - LIProfileViewControllerDelegate

- (void)linkedInProfileViewController:(LIProfileViewController*)viewController didFail:(NSString*)error
{
	[self error:error];
}

- (void)linkedInProfileViewController:(LIProfileViewController*)viewController isBusy:(BOOL)busy
{
	[self busy:busy];
}

- (void)linkedInProfileViewControllerDidFinish:(LIProfileViewController*)viewController
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

- (void)busy:(BOOL)busy
{
	UIWindow* window = [[[UIApplication sharedApplication] windows] lastObject];
	if (busy)
		[MBProgressHUD showHUDAddedTo:window animated:YES];
	else
		[MBProgressHUD hideHUDForView:window animated:YES];
}

- (void)error:(NSString*)error
{
	[[[UIAlertView alloc] initWithTitle:@"Error" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

@end
