//
//  Foursquare.m
//  Objective4sq
//
//  Created by Barry Teoh on 12/25/10.
//  Copyright 2010 / 2011 Totally Awesome Development Ltd. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//  * Neither the name of the Perceptionz.Net nor the names of its contributors may
//    be used to endorse or promote products derived from this software without
//    specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
//  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "Foursquare.h"

#define kBaseURL @"https://api.foursquare.com/v2/"

// Endpoints supported
#define kUserTodoEndpoint @"users/self/todos"
#define kUserCheckinHistoryEndpoint @"users/self/checkins"
#define kVenueSearch @"venues/search"

// Access token store (for storing the user's key)
#define kAccessTokenKeyStore @"objective4sq.accesstoken"

@implementation Foursquare
@synthesize delegate;
@synthesize dictLastRequest;
@synthesize lastEndPoint;
@synthesize lastStatus;
@synthesize lastStatusReason;
@synthesize MyConsumerKey;
@synthesize MyConsumerSecret;

#pragma mark -
#pragma mark Initializer
-(id) initWithAccessToken:(NSString *)apitoken WithAccessSecret:(NSString *)apisecret {
#if _DEBUG
	NSLog(@"Foursquare->initWithAccessToken %@ %@", apitoken, apisecret);
#endif
	self.MyConsumerKey = apitoken;
	self.MyConsumerSecret = apisecret;
	
	return self;
}

#pragma mark -
#pragma mark OAuth Dance Methods
-(NSURL *) getOAuthURLWithRedirectHandler:(NSString *)redirectHandler {
	if (MyConsumerKey != nil && MyConsumerSecret != nil) {
		NSString *theURL = [NSString stringWithFormat:@"https://foursquare.com/oauth2/authenticate?client_id=%@&response_type=code&redirect_uri=%@&display=touch",
							MyConsumerKey,
							[redirectHandler stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]							
							];
#if _DEBUG
		NSLog(@"Foursquare->getOAuthURLWithRedirectHandler %@ => %@", redirectHandler, theURL);
#endif
		return [NSURL URLWithString:theURL];
	} else {
#if _DEBUG
		NSLog(@"Foursquare->getOAuthURLWithRedirectHandler %@ => NIL (POTENTIAL ERROR)", redirectHandler);
#endif		
		return nil;
	}

}
-(void) getAccessCodeWithRedirectHandler:(NSString *)redirectHandler WithCode:(NSString *)theCode {
	if (MyConsumerKey != nil && MyConsumerSecret != nil) {
		lastEndPoint = [NSString stringWithString:@"access_token"];
		NSString *theURLString = [NSString stringWithFormat:@"https://foursquare.com/oauth2/access_token?client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&code=%@",
							MyConsumerKey,
							MyConsumerSecret,
							[redirectHandler stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
							[theCode stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
							];
#if _DEBUG
		NSLog(@"Foursquare->getAccessCodeWithRedirectHandler %@ %@ => %@ (Start Async Request)", redirectHandler, theCode, theURLString);
#endif
		NSURL *theURL = [NSURL URLWithString:theURLString];
		ASIHTTPRequest *theReq = [ASIHTTPRequest requestWithURL:theURL];
		[theReq setDelegate:self];
		[theReq startAsynchronous];
		background_job = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
		[self.delegate FoursquareStartRequest]; // Start the show		
		
	}
}

#pragma mark -
#pragma mark Async Methods
-(void) showNearestVenuesByLocation:(CLLocation *)myloc WithSearchTerm:(NSString *)term {
	lastEndPoint = [NSString stringWithString:kVenueSearch];
	NSString *lat_long = [NSString stringWithFormat:@"%2.6f,%2.6f",
						  myloc.coordinate.latitude,
						  myloc.coordinate.longitude];
	NSString *urlString = [NSString stringWithFormat:@"%@%@?oauth_token=%@&ll=%@",
						   kBaseURL,
						   kVenueSearch,
						   [self getStoredAccessToken],
						   lat_long
						   ];
	if (term != nil) {
		urlString = [urlString stringByAppendingFormat:@"&query=%@", [term stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	}
	urlString = [urlString stringByAppendingFormat:@"&intent=checkin"];
#if _DEBUG
	NSLog(@"---");
	NSLog(@"Foursquare->showNearestVenuesByLocation: %@ %@", [myloc description], term);
	NSLog(@"URL: %@", urlString);
	NSLog(@"---");	
#endif	
	NSURL *theURL = [NSURL URLWithString:urlString];
	ASIHTTPRequest *theReq = [ASIHTTPRequest requestWithURL:theURL];
	[theReq setTimeOutSeconds:60];
	[theReq setDelegate:self];
	[theReq startAsynchronous];
	background_job = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
	[self.delegate FoursquareStartRequest]; // Start the show		
}

-(void) showTodosByLocation:(CLLocation *)myloc {
	lastEndPoint = [NSString stringWithString:kUserTodoEndpoint];
	NSString *lat_long = [NSString stringWithFormat:@"%2.6f,%2.6f",
						  myloc.coordinate.latitude,
						  myloc.coordinate.longitude];
	NSString *urlString = [NSString stringWithFormat:@"%@%@?oauth_token=%@&ll=%@",
						   kBaseURL,
						   kUserTodoEndpoint,
						   [self getStoredAccessToken],
						   lat_long
						   ];
#if _DEBUG
	NSLog(@"---");
	NSLog(@"Foursquare->showTodosByLocation: %@", [myloc description]);
	NSLog(@"URL: %@", urlString);
	NSLog(@"---");	
#endif
	NSURL *theURL = [NSURL URLWithString:urlString];
	ASIHTTPRequest *theReq = [ASIHTTPRequest requestWithURL:theURL];
	[theReq setTimeOutSeconds:60];
	[theReq setDelegate:self];
	[theReq startAsynchronous];
	background_job = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
	[self.delegate FoursquareStartRequest]; // Start the show	
}
-(void) grabVenueListWithStartDate:(NSDate *)startDate WithEndDate:(NSDate *)endDate {
	lastEndPoint = [NSString stringWithString:kUserCheckinHistoryEndpoint];
	NSString *urlString = [NSString stringWithFormat:@"%@%@?oauth_token=%@",
						   kBaseURL,
						   kUserCheckinHistoryEndpoint,
						   [self getStoredAccessToken]
						   ];
	if (startDate != nil) {
		urlString = [urlString stringByAppendingFormat:@"&afterTimestamp=%d", 
					 (NSInteger )[startDate timeIntervalSince1970]
					 ];
	}
	if (endDate != nil) {
		urlString = [urlString stringByAppendingFormat:@"&beforeTimestamp=%d",
					 (NSInteger )[endDate timeIntervalSince1970]
					 ];
	}
#if _DEBUG
	NSLog(@"---");
	NSLog(@"Foursquare->grabVenueListWithStartDate: %@ %@", [startDate description], [endDate description]);
	NSLog(@"URL: %@", urlString);
	NSLog(@"---");	
#endif
	
	NSURL *theURL = [NSURL URLWithString:urlString];
	ASIHTTPRequest *theReq = [ASIHTTPRequest requestWithURL:theURL];
	[theReq setTimeOutSeconds:60];
	[theReq setDelegate:self];
	[theReq startAsynchronous];
	
	background_job = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
	[self.delegate FoursquareStartRequest]; // Start the show
}

#pragma mark -
#pragma mark Set Access Token
-(void) setAccessTokenWithString:(NSString *)the_token {
#if _DEBUG
	NSLog(@"Foursquare->setAccessTokenWithString %@", the_token);
#endif
	[[NSUserDefaults standardUserDefaults] setObject:the_token forKey:kAccessTokenKeyStore];
}

#pragma mark -
#pragma mark Get Access Token
-(NSString *) getStoredAccessToken {
#if _DEBUG
	NSLog(@"Foursquare->getStoredAccessToken");
#endif
	NSString *the_token = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKeyStore];
	if (the_token != nil) {
		return the_token;
	} else {
		return @"";
	}
}

#pragma mark -
#pragma mark AsyncCallback
- (void)requestFinished:(ASIHTTPRequest *)request
{
	// End background job
	[[UIApplication sharedApplication] endBackgroundTask:background_job];
	
	// Use when fetching text data
	NSString *responseString = [request responseString];
	[self.delegate FoursquareFinishedRequest];
	@try {
		SBJsonParser *parser = [SBJsonParser new];
		dictLastRequest = (NSDictionary *)[parser objectWithString:responseString];
		lastStatus = [NSString stringWithString:@"success_ok"];
		lastStatusReason = [NSString stringWithString:@"All good"];
#if _DEBUG && _ILOVESPAM
		NSLog(@"JSONized response\n---\n%@\n---\n", [dictLastRequest description]);
#endif
#if _DEBUG
		NSLog(@"Status: %@\n Full Status: %@\n", lastStatus, lastStatusReason);
#endif
		if ([lastEndPoint isEqualToString:@"access_token"]) {
			NSString *access_token = [dictLastRequest objectForKey:@"access_token"];
			if (access_token != nil) {
				[self setAccessTokenWithString:access_token]; // Set the Access Token
				[self.delegate FoursquareFinishedRequest];
			} else {
				lastStatus = [NSString stringWithString:@"error"];
				lastStatusReason = [NSString stringWithString:[dictLastRequest objectForKey:@"error"]];
				[self.delegate FoursquareRequestError];
			}

		} else {
			[self.delegate FoursquareFinishedRequest];
		}
	}
	@catch (NSException * e) {
#if _DEBUG
		NSLog(@"JSON PARSE ERROR\n----\n%@\n-----\n", responseString);
#endif
		lastStatus = [NSString stringWithString:@"success_err"];
		lastStatusReason = [NSString stringWithString:@"Not a valid JSON string"];
		[self.delegate FoursquareRequestError];
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	// End background job
	
	[[UIApplication sharedApplication] endBackgroundTask:background_job];
	NSError *error = [request error];
#if _DEBUG
	NSLog(@"requestFailed called. Error=%@", [error description]);
#endif
	lastStatus = [NSString stringWithString:@"error"];
	lastStatusReason = [NSString stringWithString:[error description]];
	[self.delegate FoursquareRequestError];
}

-(void) dealloc {
#if _DEBUG
	NSLog(@"Foursquare->dealloc");
#endif
	[MyConsumerKey release];
	[MyConsumerSecret release];
	[lastStatus release];
	[lastStatusReason release];
	[dictLastRequest release];
	[lastEndPoint release];
	[super dealloc];
}
@end
