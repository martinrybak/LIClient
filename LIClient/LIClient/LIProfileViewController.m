//
//  LIProfileViewController.m
//  LIClient
//
//  Created by Martin Rybak on 11/29/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import "LIProfileViewController.h"
#import "UIImageView+WebCache.h"

@interface LIProfileViewController ()

@property (strong, nonatomic) IBOutlet UIImageView* photo;
@property (weak, nonatomic) IBOutlet UILabel* name;
@property (weak, nonatomic) IBOutlet UILabel* headline;

@end

@implementation LIProfileViewController

- (void) viewDidLoad
{
	[super viewDidLoad];
	self.name.text = self.user.name;
	self.headline.text = self.user.headline;
	[self.photo setImageWithURL:[NSURL URLWithString:self.user.photoUrl]];
}

@end
