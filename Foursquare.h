//
//  Foursquare.h
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

//
// Dependancies:
// - ASIHTTPRequest (https://github.com/pokeb/asi-http-request/)
// - json-framework
// - CoreLocation

// Preprocessor Macros
// _DEBUG (Turns on debug)
// _ILOVESPAM (Makes debugging more verbose. So we can actually see the response)

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ASIHTTPRequest.h"
#import "JSON.h"

// This class will require 3 callbacks
@protocol Foursquare <NSObject>
@required
-(void) FoursquareStartRequest;
-(void) FoursquareFinishedRequest;
-(void) FoursquareRequestError;
@end

@interface Foursquare : NSObject <ASIHTTPRequestDelegate> {
	id <Foursquare> delegate;
	NSDictionary *dictLastRequest;
	NSString *lastEndPoint;
	NSString *LastStatus;
	NSString *LastStatusReason;
	
	NSString *MyConsumerKey;
	NSString *MyConsumerSecret;
	UIBackgroundTaskIdentifier background_job;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSDictionary *dictLastRequest;
@property (nonatomic, retain) NSString *lastEndPoint;
@property (nonatomic, retain) NSString *lastStatus;
@property (nonatomic, retain) NSString *lastStatusReason;
@property (nonatomic, retain) NSString *MyConsumerKey;
@property (nonatomic, retain) NSString *MyConsumerSecret;

// Initialize this object with this function
-(id) initWithAccessToken:(NSString *)apitoken WithAccessSecret:(NSString *)apisecret;
// Open This URL in a UIWebView
-(NSURL *) getOAuthURLWithRedirectHandler:(NSString *)redirectHandler;
// Foursquare will present a code, you need to use it to get an access_token
-(void) getAccessCodeWithRedirectHandler:(NSString *)redirectHandler WithCode:(NSString *)theCode;

-(void) showNearestVenuesByLocation:(CLLocation *)myloc WithSearchTerm:(NSString *)term;
-(void) showTodosByLocation:(CLLocation *)myloc;
-(void) grabVenueListWithStartDate:(NSDate *)startDate WithEndDate:(NSDate *)endDate;
-(void) setAccessTokenWithString:(NSString *)the_token;
-(NSString *) getStoredAccessToken;

@end
