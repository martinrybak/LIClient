//
//  LIProfileViewController.m
//  LIClient
//
//  Created by Martin Rybak on 11/29/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import "LIProfileViewController.h"
#import "LIClient.h"
#import "UIImageView+WebCache.h"

@interface LIProfileViewController ()

@property (strong, nonatomic) LIClient* client;
@property (strong, nonatomic) IBOutlet UIImageView* photo;
@property (weak, nonatomic) IBOutlet UILabel* name;
@property (weak, nonatomic) IBOutlet UILabel* headline;

@end

@implementation LIProfileViewController

- (void) viewDidLoad
{
	[self.delegate linkedInProfileViewController:self isBusy:YES];
	self.client = [[LIClient alloc] initWithAccessToken:self.accessToken];
	[self.client fetchCurrentUser:
		LIUserFieldId			|
		LIUserFieldEmail		|
		LIUserFieldFirstName	|
		LIUserFieldLastName		|
		LIUserFieldHeadline		|
		LIUserFieldPhotoUrl		|
		LIUserFieldPhoneNumbers |
		LIUserFieldLocation		|
		LIUserFieldIndustry		|
		LIUserFieldDistance		|
		LIUserFieldRelationToViewer |
		LIUserFieldNumRecommenders |
		LIUserFieldCurrentShare	|
		LIUserFieldNumConnections |
		LIUserFieldNumConnectionsCapped |
		LIUserFieldSummary		|
		LIUserFieldSpecialties  |
		LIUserFieldPositions	|
		LIUserFieldSiteStandardProfileRequest |
		LIUserFieldPublicProfileUrl
	success:^(LIUser* user) {
		[self.delegate linkedInProfileViewController:self isBusy:NO];
		self.name.text = user.name;
		self.headline.text = user.headline;
		[self.photo setImageWithURL:[NSURL URLWithString:user.photoUrl]];
	} failure:^(NSError* error) {
		[self.delegate linkedInProfileViewController:self isBusy:NO];
		[self.delegate linkedInProfileViewController:self didFail:[error localizedDescription]];
	}];
}

- (IBAction)done:(id)sender
{
	[self.delegate linkedInProfileViewControllerDidFinish:self];
}

@end
