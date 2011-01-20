Objective Foursquare
====================
What is it?
---------------------

Objective Foursquare is my own libraries for interfacing with the 
Foursquare API.

This is currently an *alpha release* and assumes you already have an oauth access token from
a previous "Oauth Dance".

Future releases will also fetch a token, and contain more functionality.

External Dependancies
---------------------

Here are the libraries used by this Class

* ASIHTTPRequest (Drop into the project)
* json-framework (Drop into the project)
* CoreLocation (Apple Official)

TODO List
---------------------

* Add Initial steps to grab OAuth Token
* Add more endpoints :)


How to use
---------------------
**Initializing the object and setting the delegate**

    // Put this in @interface
    Foursquare *foursq;

    // Put this in the @implementation block somewhere
    foursq = [[Foursquare alloc] initWithAccessToken:@"YOURTOKEN" WithAccessSecret:@"YOURSECRET"];
    if ([[foursq getStoredAccessToken] length] == 0) {
	    NSURL *oauth_url = [foursq getOAuthURLWithRedirectHandler:@"yourapphandler://verify"];
    	// You will need to present UIWebView or something for the user
	}
	
    [foursq setDelegate:self]; // Set up a delegate
	
	// This code should be handled by the handler
	// This is an async request. On success it will set the access token
	[foursq getAccessCodeWithRedirectHandler:@"Needstomatch" WithCode:@"whateverthecodeis"];

    // Lets grab all the Foursquare for my account
    // and also assume I'm somewhere in Sydney, Australia
    CLLocation *test_loc = [[CLLocation alloc] initWithLatitude:-33.8378599 longitude:151.20788];
    [foursq showTodosByLocation:test_loc];
    [test_loc release];
	
**Implementing the delegate**

There are 3 main methods which you will need to implement.

    -(void) FoursquareStartRequest;
    -(void) FoursquareFinishedRequest; 
    -(void) FoursquareRequestError;

Each method (Except for the error one in some circumstances) will write to the following instance variables:

    NSDictionary *dictLastRequest; // The raw request serialized from the JSON response

All methods will write to the following:

    NSString *lastEndPoint; // Last endpoint called
    NSString *LastStatus; // last status (either: success_ok or success_err)
    NSString *LastStatusReason; // Last status reason (Plain english reason of why the request failed)

Compiler preprocessor directives
---------------------

**_DEBUG** This will turn on all the NSLog statements

**_ILOVESPAM** This will print the complete response returned from the service (Serialized as a dictionary)

