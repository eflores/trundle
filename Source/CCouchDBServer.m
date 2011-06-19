//
//  CCouchDBServer.m
//  CouchTest
//
//  Created by Jonathan Wight on 02/16/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CCouchDBServer.h"

#import "Asserts.h"

#import "CCouchDBSession.h"
#import "CCouchDBDatabase.h"
#import "CouchDBClientConstants.h"
#import "CCouchDBURLOperation.h"
#import "NSData_Base64Extensions.h"
	
@interface CCouchDBServer ()
@property (readonly, retain) NSMutableDictionary *databasesByName;
@end

#pragma mark -

@implementation CCouchDBServer

@synthesize session;
@synthesize URL;
@synthesize URLCredential;
@synthesize databasesByName;

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
	{
	if ([key isEqualToString:@"databases"])
		return([NSSet setWithObjects:@"databasesByName", NULL]);
	else
		{
		return(NULL);
		}
	}

- (id)init
	{
	if ((self = [self initWithSession:NULL URL:[NSURL URLWithString:@"http://localhost:5984/"]]) != NULL)
		{
		}
	return(self);
	}

- (id)initWithSession:(CCouchDBSession *)inSession URL:(NSURL *)inURL;
	{
	if ((self = [super init]) != NULL)
		{
		session = inSession;
		URL = inURL;
		}
	return(self);
	}


#pragma mark -

- (NSString *)description
	{
	return([NSString stringWithFormat:@"%@ (%@)", [super description], self.URL]);
	}

#pragma mark -

- (CCouchDBSession *)session
	{
	if (session == NULL)
		{
		session = [[CCouchDBSession alloc] init];
		}
	return(session);
	}

- (NSSet *)databases
	{
	return([NSSet setWithArray:[self.databasesByName allValues]]);
	}

- (NSMutableDictionary *)databasesByName
	{
	@synchronized(self)
		{
		if (databasesByName == NULL)
			{
			databasesByName = [[NSMutableDictionary alloc] init];
			}
		return(databasesByName);
		}
	}

- (CCouchDBDatabase *)databaseNamed:(NSString *)inName
	{
	CCouchDBDatabase *theDatabase = [self.databasesByName objectForKey:inName];
	if (theDatabase == NULL)
		{
		theDatabase = [[CCouchDBDatabase alloc] initWithServer:self name:inName];
		[self.databasesByName setObject:theDatabase forKey:inName];
		}
	return(theDatabase);
	}
	
- (NSMutableURLRequest *)requestWithURL:(NSURL *)inURL;
	{
	NSMutableURLRequest *theRequest = [self.session requestWithURL:inURL];
	
	if (self.URLCredential)
		{
		if ([inURL.scheme isEqualToString:@"http"] == YES)
			{
			LogOnce_(LoggingLevel_WARNING, @"Using basic auth over non-https connections is a bad idea.");
			}
		
		NSString *theValue = [NSString stringWithFormat:@"%@:%@", self.URLCredential.user, self.URLCredential.password];
		NSData *theData = [theValue dataUsingEncoding:NSUTF8StringEncoding];
		theValue = [theData asBase64EncodedString:0];
		theValue = [NSString stringWithFormat:@"Basic %@", theValue];
		[theRequest setValue:theValue forHTTPHeaderField:@"Authorization"];
		}
	return(theRequest);
	}

#pragma mark -

- (CURLOperation *)operationToCreateDatabaseNamed:(NSString *)inName withSuccessHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;
	{
	CCouchDBDatabase *theRemoteDatabase = [[CCouchDBDatabase alloc] initWithServer:self name:inName];
	NSURL *theURL = [self.URL URLByAppendingPathComponent:theRemoteDatabase.encodedName];
	NSMutableURLRequest *theRequest = [self requestWithURL:theURL];
	theRequest.HTTPMethod = @"PUT";
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];
	CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
	theOperation.successHandler = ^(id inParameter) {
		[self willChangeValueForKey:@"databasesByName"];
		[self.databasesByName setObject:theRemoteDatabase forKey:inName];
		[self didChangeValueForKey:@"databasesByName"];

		if (inSuccessHandler)
			inSuccessHandler(theRemoteDatabase);
		};
	theOperation.failureHandler = inFailureHandler;
	return(theOperation);
	}

- (CURLOperation *)operationToFetchDatabasesWithSuccessHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler
	{
	NSURL *theURL = [self.URL URLByAppendingPathComponent:@"_all_dbs"];
	NSMutableURLRequest *theRequest = [self requestWithURL:theURL];
	theRequest.HTTPMethod = @"GET";
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];
    __block CCouchDBServer *_self = self;
	CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
	theOperation.successHandler = ^(id inParameter) {
		[_self willChangeValueForKey:@"databases"];
		for (NSString *theName in inParameter)
			{
			if ([_self.databasesByName objectForKey:theName] == NULL)
				{
				CCouchDBDatabase *theDatabase = [[CCouchDBDatabase alloc] initWithServer:_self name:theName];
				[_self willChangeValueForKey:@"databasesByName"];
				[_self.databasesByName setObject:theDatabase forKey:theName];
				[_self didChangeValueForKey:@"databasesByName"];
				}
			}
		[_self didChangeValueForKey:@"databases"];

		if (inSuccessHandler)
			inSuccessHandler([_self.databasesByName allValues]);

        _self = NULL;
		};
	theOperation.failureHandler = inFailureHandler;

	return(theOperation);
	}

- (CURLOperation *)operationToFetchDatabaseNamed:(NSString *)inName withSuccessHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;
	{
	CCouchDBDatabase *theRemoteDatabase = [[CCouchDBDatabase alloc] initWithServer:self name:inName];
	NSURL *theURL = [self.URL URLByAppendingPathComponent:theRemoteDatabase.encodedName];
	NSMutableURLRequest *theRequest = [self requestWithURL:theURL];
	theRequest.HTTPMethod = @"GET";
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];
    __block CCouchDBServer *_self = self;
	CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
	theOperation.successHandler = ^(id inParameter) {
		[_self willChangeValueForKey:@"databasesByName"];
		[_self.databasesByName setObject:theRemoteDatabase forKey:inName];
		[_self didChangeValueForKey:@"databasesByName"];

		if (inSuccessHandler)
			inSuccessHandler(theRemoteDatabase);

        _self = NULL;
		};
	theOperation.failureHandler = inFailureHandler;
	return(theOperation);
	}

- (CURLOperation *)operationToDeleteDatabase:(CCouchDBDatabase *)inDatabase withSuccessHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;
	{
	NSURL *theURL = [self.URL URLByAppendingPathComponent:inDatabase.encodedName];
	NSMutableURLRequest *theRequest = [self requestWithURL:theURL];
	theRequest.HTTPMethod = @"DELETE";
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];
    __block CCouchDBServer *_self = self;
	CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
	theOperation.successHandler = ^(id inParameter) {
		[_self willChangeValueForKey:@"databasesByName"];
		[_self.databasesByName removeObjectForKey:inDatabase.name];
		[_self didChangeValueForKey:@"databasesByName"];

		if (inSuccessHandler)
			inSuccessHandler(inDatabase);

        _self = NULL;
		};
	theOperation.failureHandler = inFailureHandler;
	return(theOperation);
	}

@end
