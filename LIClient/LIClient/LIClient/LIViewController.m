//
//  UPLinkedInViewController.m
//  Updated
//
//  Created by Martin Rybak on 11/25/13.
//  Copyright (c) 2013 Updated. All rights reserved.
//

#import "LIViewController.h"
#import "NSString+CJStringValidator.h"
#import "NSString+Helpers.h"

NSString* const LIViewControllerAuthorizeUrl = @"https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=%@&scope=%@&state=%@&redirect_uri=%@";
NSString* const LIViewControllerAccessTokenUrl = @"https://www.linkedin.com/uas/oauth2/accessToken?grant_type=authorization_code&code=%@&redirect_uri=%@&client_id=%@&client_secret=%@";
NSString* const LIViewControllerRedirectUrl = @"http://linkedin/redirect/";
NSTimeInterval const LIViewControllerConnectionTimeout = 5.0;

@interface LIViewController ()

@property (strong, nonatomic) NSTimer* timer;

@end

@implementation LIViewController

+ (BOOL)isNilOrEmpty:(NSString *)input {
    return !(input && input.length);
}

#pragma mark - Public

- (id)initWithAPIKey:(NSString*)apiKey secretKey:(NSString*)secretKey state:(NSString*)state permissions:(LIPermission)permissions
{
	if (self = [super init])
	{
		self.apiKey = apiKey;
        self.secretKey = secretKey;
		self.state = state;
		self.permissions = permissions;
	}
	return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
	self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
	self.webView.alpha = 0;
	self.webView.delegate = self;
	self.view.backgroundColor = [UIColor lightGrayColor];
	[self.view addSubview:self.webView];
	
	if ([LIViewController isNilOrEmpty:self.apiKey])
		[NSException raise:@"apiKey must be set" format:nil];
	if ([LIViewController isNilOrEmpty:self.secretKey])
		[NSException raise:@"secretKey must be set" format:nil];
	if ([LIViewController isNilOrEmpty:self.state])
		[NSException raise:@"state must be set" format:nil];
	if (self.permissions == 0)
		[NSException raise:@"permission must be set" format:nil];

	[self.delegate linkedInViewController:self isBusy:YES];
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self authorizeUrl:self.permissions]]]];
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

#pragma mark UIWebViewDelegate protocol

- (void)webViewDidStartLoad:(UIWebView*)webView
{
	self.timer = [NSTimer scheduledTimerWithTimeInterval:LIViewControllerConnectionTimeout target:self selector:@selector(timeout) userInfo:nil repeats:NO];
}

- (void)webViewDidFinishLoad:(UIWebView*)webView
{
	if (!webView.loading)
	{
		[self.timer invalidate];
		[self.delegate linkedInViewController:self isBusy:NO];
		[UIView animateWithDuration:0.3 animations:^{
			self.webView.alpha = 1;
		} completion:nil];
	}
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%@", [[request URL] absoluteString]);
	NSDictionary* queryString = [self URLQueryParameters:[request URL]];
	
	//Check for cross-site request forgery
	if (queryString[@"state"] && ![queryString[@"state"] isEqualToString:self.state])
	{
		[self.timer invalidate];
		[self error:@"A cross-site request forgery was detected."];
		return NO;
	}
	
	//Check for error
	if (queryString[@"error"])
    {
		[self.timer invalidate];
		NSString* error = queryString[@"error"];
		if ([error isEqualToString:@"access_denied"])
			[self.delegate linkedInViewControllerDidCancel:self];
		else
			[self error:[queryString[@"error"] URLDecode]];

        return NO;
    }
    
	// Request access token request code
	if (queryString[@"code"])
    {
		[self.timer invalidate];
		[self.delegate linkedInViewController:self isBusy:YES];
		[self fetchAccessToken:queryString[@"code"] success:^(NSString* accessToken, NSDate* expiration) {
			[self.delegate linkedInViewController:self isBusy:NO];
			[self.delegate linkedInViewController:self didSucceed:accessToken expiration:expiration];
		} failure:^(NSError* error) {
			[self error:[error localizedDescription]];
		}];
		return NO;
    }

	return YES;
}

#pragma mark - Private

- (NSString*)authorizeUrl:(LIPermission)permissions
{
	return [NSString stringWithFormat:LIViewControllerAuthorizeUrl, self.apiKey, [self formatPermissions:permissions], self.state, [LIViewControllerRedirectUrl URLEncode]];
}

- (NSString*)accessTokenUrl:(NSString*)code
{
	return [NSString stringWithFormat:LIViewControllerAccessTokenUrl, code, [LIViewControllerRedirectUrl URLEncode], self.apiKey, self.secretKey];
}

- (NSString*)formatPermissions:(LIPermission)permissions
{
	NSMutableArray* array = [[NSMutableArray alloc] init];
	
	if((permissions & LIPermissionBasicProfile) == LIPermissionBasicProfile)
		[array addObject:@"r_basicprofile"];
	if((permissions & LIPermissionFullProfile) == LIPermissionFullProfile)
		[array addObject:@"r_fullprofile"];
	if((permissions & LIPermissionEmailAddress) == LIPermissionEmailAddress)
		[array addObject:@"r_emailaddress"];
	if((permissions & LIPermissionNetwork) == LIPermissionNetwork)
		[array addObject:@"r_network"];
	if((permissions & LIPermissionContactInfo) == LIPermissionContactInfo)
		[array addObject:@"r_contactinfo"];
	if((permissions & LIPermissionNetworkUpdates) == LIPermissionNetworkUpdates)
		[array addObject:@"rw_nus"];
	if((permissions & LIPermissionCompanyAdmin) == LIPermissionCompanyAdmin)
		[array addObject:@"rw_company_admin"];
	if((permissions & LIPermissionGroups) == LIPermissionGroups)
		[array addObject:@"rw_groups"];
	if((permissions & LIPermissionMessages) == LIPermissionMessages)
		[array addObject:@"w_messages"];
	
	return [[array componentsJoinedByString:@" "] URLEncode];
}

- (NSDictionary*)URLQueryParameters:(NSURL*)URL
{
    NSString *queryString = [URL query];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray *parameters = [queryString componentsSeparatedByString:@"&"];
    for (NSString *parameter in parameters)
    {
        NSArray *parts = [parameter componentsSeparatedByString:@"="];
        NSString *key = [[parts objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if ([parts count] > 1)
        {
            id value = [[parts objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [result setObject:value forKey:key];
        }
    }
    return result;
}

- (void)fetchAccessToken:(NSString*)code success:(void (^)(NSString* accessToken, NSDate* expiration))success failure:(void (^)(NSError* error))failure
{
    NSString* url = [self accessTokenUrl:code];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        if (connectionError)
			if (failure)
				failure(connectionError);
		
        NSString* responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([responseString contains:@"access_token"] && [responseString contains:@"expires_in"])
        {
            NSError* error;
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (error)
				if (failure)
					failure(error);
			
            NSString* accessToken = [json valueForKey:@"access_token"];
			NSString* durationString = [NSString stringWithFormat:@"%@", [json valueForKey:@"expires_in"]];
			NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
			NSNumber* duration = [numberFormatter numberFromString:durationString];
			NSDate* expiration = [NSDate dateWithTimeInterval:[duration longValue] sinceDate:[NSDate date]];
			if (success)
				success(accessToken, expiration);
        }
    }];
}

- (void)timeout
{
	[self.delegate linkedInViewController:self isBusy:NO];
	[self.delegate linkedInViewController:self didFail:@"Could not connect to LinkedIn"];
}

- (void)error:(NSString*)error
{
	[self.delegate linkedInViewController:self isBusy:NO];
	[self.delegate linkedInViewController:self didFail:error];
}

@end
