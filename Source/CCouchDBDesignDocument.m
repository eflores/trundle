//
//  CCouchDBDesignDocument.m
//  AnythingBucket
//
//  Created by Jonathan Wight on 10/21/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CCouchDBDesignDocument.h"

#import "NSURL_Extensions.h"

#import "CCouchDBDatabase.h"
#import "CCouchDBDocument.h"
#import "CCouchDBServer.h"
#import "CCouchDBSession.h"
#import "CCouchDBURLOperation.h"
#import "CouchDBClientConstants.h"
#import "CCouchDBView.h"
#import "CCouchDBViewRow.h"

@interface CCouchDBDesignDocument ()
@property (readonly, nonatomic, retain) CCouchDBSession *session;
@end

#pragma mark -

@implementation CCouchDBDesignDocument

@synthesize database;
@synthesize identifier;

- (id)initWithDatabase:(CCouchDBDatabase *)inDatabase identifier:(NSString *)inIdentifier
    {
    if ((self = [super init]) != NULL)
        {
        database = inDatabase;
        identifier = inIdentifier;
        }
    return(self);
    }

#pragma mark -

- (NSURL *)URL
    {
    return([self.database.URL URLByAppendingPathComponent:[NSString stringWithFormat:@"_design/%@", self.identifier]]);
    }

- (CCouchDBServer *)server
    {
    return(self.database.server);
    }

- (CCouchDBSession *)session
    {
    return(self.database.server.session);
    }

#pragma mark -

- (CURLOperation *)operationToFetchViewNamed:(NSString *)inName options:(NSDictionary *)inOptions withSuccessHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler
	{
    NSURL *theURL = [self.URL URLByAppendingPathComponent:[NSString stringWithFormat:@"_view/%@", inName]];

    if (inOptions.count > 0)
        {
        theURL = [NSURL URLWithRoot:theURL queryDictionary:inOptions];
        }

    NSMutableURLRequest *theRequest = [self.session requestWithURL:theURL];
    theRequest.HTTPMethod = @"GET";
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];
    CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
    theOperation.successHandler = ^(id inParameter) {
		NSMutableArray *theViewRows = [NSMutableArray array];
		for (NSDictionary *theRow in [inParameter objectForKey:@"rows"])
            {
            id key = [theRow objectForKey:@"key"];
            id value = [theRow objectForKey:@"value"];
			NSDictionary *doc = [theRow objectForKey:@"doc"];
            CCouchDBDocument *theDocument = NULL;
			if (doc)
                {
				theDocument = [[CCouchDBDocument alloc] initWithDatabase:database];
				[theDocument populateWithJSON:doc];
                }
			else
                {
				NSString *theIdentifier = [theRow objectForKey:@"id"];
				theDocument = [[CCouchDBDocument alloc] initWithDatabase:database identifier:theIdentifier];
                }
            CCouchDBViewRow *viewRow = [[CCouchDBViewRow alloc] initWithKey:key value:value document:theDocument];
            [theViewRows addObject:viewRow];
            }
        
        NSInteger theTotalRows = [[inParameter objectForKey:@"total_rows"] integerValue];
        NSInteger theOffset = [[inParameter objectForKey:@"offset"] integerValue];        
        CCouchDBView *theView = [[CCouchDBView alloc] initWithTotalRows:theTotalRows offset:theOffset rows:theViewRows];

        if (inSuccessHandler)
			inSuccessHandler(theView);
    };
    theOperation.failureHandler = inFailureHandler;

	return(theOperation);
	}

@end
