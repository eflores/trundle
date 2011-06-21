//
//  CCouchDBDatabase.m
//  CouchTest
//
//  Created by Jonathan Wight on 02/16/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CCouchDBDatabase.h"

#import "CCouchDBSession.h"
#import "CCouchDBServer.h"
#import "CFilteringJSONSerializer.h"
#import "CouchDBClientConstants.h"
#import "CCouchDBDocument.h"
#import "CCouchDBURLOperation.h"
#import "NSURL_Extensions.h"
#import "CCouchDBChangeSet.h"
#import "CCouchDBDesignDocument.h"
#import "CCouchDBView.h"
#import "CCouchDBViewRow.h"
#import "CCouchDBSession.h"

@interface CCouchDBDatabase ()
@property (readonly, retain) NSMutableDictionary *designDocuments;

@end

@implementation CCouchDBDatabase

@synthesize session;
@synthesize server;
@synthesize name;
@synthesize encodedName;
@synthesize URL;
@synthesize designDocuments;

- (id)initWithServer:(CCouchDBServer *)inServer name:(NSString *)inName
	{
	if ((self = [self init]) != NULL)
		{
		server = inServer;
		name = [inName copy];
		}
	return(self);
	}
	
- (id)initWithURL:(NSURL *)inURL;
	{
	if ((self = [self init]) != NULL)
		{
		name = [inURL lastPathComponent];
        URL = inURL;
		}
	return(self);
	}

#pragma mark -

- (CCouchDBSession *)session
	{
	if (session == NULL)
        {
        session = self.server.session;
        if (session == NULL)
            {
            session = [CCouchDBSession defaultSession];
            }
        }
	return(session);
	}

#pragma mark -

- (NSString *)encodedName
	{
	@synchronized(self)
		{
		if (encodedName == NULL)
			{
			encodedName = (NSString *)objc_retainedObject(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)objc_unretainedPointer(self.name), NULL, CFSTR("/"), kCFStringEncodingUTF8));
			}
		return(encodedName);
		}
	}

- (NSURL *)URL
	{
	@synchronized(self)
		{
		if (URL == NULL)
			{
			URL = [self.server.URL URLByAppendingPathComponent:self.encodedName];
			}
		return(URL);
		}
	}

#pragma mark -

- (CCouchDBDesignDocument *)designDocumentNamed:(NSString *)inName;
	{
	CCouchDBDesignDocument *theDesignDocument = [self.designDocuments objectForKey:inName];
	if (theDesignDocument == NULL)
		{
		theDesignDocument = [[CCouchDBDesignDocument alloc] initWithDatabase:self identifier:inName];
		[self.designDocuments setObject:theDesignDocument forKey:inName];
		}
	return(theDesignDocument);	
	}

- (CURLOperation *)operationToCreateDocument:(NSDictionary *)inDocument successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler
	{
    inFailureHandler = inFailureHandler ?: self.session.defaultFailureHandler;
    
	NSMutableURLRequest *theRequest = [self.session requestWithURL:self.URL];
	theRequest.HTTPMethod = @"POST";
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];

	NSData *theData = [self.session.serializer serializeDictionary:inDocument error:NULL];
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Content-Type"];
	[theRequest setHTTPBody:theData];

    __block CCouchDBDatabase *_self = self;
	CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
    __block CCouchDBURLOperation *_theOperation = theOperation;
	theOperation.successHandler = ^(id inParameter) {
		if (_theOperation.error)
			{
			if (inFailureHandler)
				inFailureHandler(_theOperation.error);
			return;
			}

		if ([[inParameter objectForKey:@"ok"] boolValue] == NO)
			{
			NSError *theError = [NSError errorWithDomain:kCouchErrorDomain code:-3 userInfo:NULL];
			if (inFailureHandler)
				inFailureHandler(theError);
			return;
			}

		NSString *theIdentifier = [inParameter objectForKey:@"id"];
		NSString *theRevision = [inParameter objectForKey:@"rev"];

		CCouchDBDocument *theDocument = [[CCouchDBDocument alloc] initWithDatabase:_self identifier:theIdentifier revision:theRevision];
		[theDocument populateWithJSON:inDocument];

		if (inSuccessHandler)
			inSuccessHandler(theDocument);
            
        _self = NULL;
        _theOperation = NULL;
		};
	theOperation.failureHandler = inFailureHandler;

	return(theOperation);
	}

- (CURLOperation *)operationToCreateDocument:(NSDictionary *)inDocument identifier:(NSString *)inIdentifier successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler
	{
    inFailureHandler = inFailureHandler ?: self.session.defaultFailureHandler;

	NSURL *theURL = [[self.URL absoluteURL] URLByAppendingPathComponent:inIdentifier];
	NSMutableURLRequest *theRequest = [self.session requestWithURL:theURL];
	theRequest.HTTPMethod = @"PUT";
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];

	NSData *theData = [self.session.serializer serializeDictionary:inDocument error:NULL];
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Content-Type"];
	[theRequest setHTTPBody:theData];

    __block CCouchDBDatabase *_self = self;
	CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
	theOperation.successHandler = ^(id inParameter) {
		if ([[inParameter objectForKey:@"ok"] boolValue] == NO)
			{
			NSError *theError = [NSError errorWithDomain:kCouchErrorDomain code:-3 userInfo:NULL];
			if (inFailureHandler)
				inFailureHandler(theError);
			}
        else
            {
            NSString *theRevision = [inParameter objectForKey:@"rev"];

            CCouchDBDocument *theDocument = [[CCouchDBDocument alloc] initWithDatabase:_self identifier:inIdentifier revision:theRevision];
            [theDocument populateWithJSON:inDocument];

            if (inSuccessHandler)
                inSuccessHandler(theDocument);
            }

        _self = NULL;
		};
	theOperation.failureHandler = inFailureHandler;
	return(theOperation);
	}

#pragma mark -

- (CURLOperation *)operationToFetchAllDocumentsWithOptions:(NSDictionary *)inOptions withSuccessHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler
	{
	return([self operationToBulkFetchDocuments:NULL options:inOptions successHandler:inSuccessHandler failureHandler:inFailureHandler]);
	}

- (CURLOperation *)operationToFetchDocumentForIdentifier:(NSString *)inIdentifier options:(NSDictionary *)inOptions successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler
	{
    inFailureHandler = inFailureHandler ?: self.session.defaultFailureHandler;

	NSURL *theURL = [self.URL URLByAppendingPathComponent:inIdentifier];
	NSMutableURLRequest *theRequest = [self.session requestWithURL:theURL];
	theRequest.HTTPMethod = @"GET";
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];
    __block CCouchDBDatabase *_self = self;
	CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
	theOperation.successHandler = ^(id inParameter) {
		CCouchDBDocument *theDocument = [[CCouchDBDocument alloc] initWithDatabase:_self];

		[theDocument populateWithJSON:inParameter];

		if (inSuccessHandler)
			inSuccessHandler(theDocument);

        _self = NULL;
		};
	theOperation.failureHandler = inFailureHandler;

	return(theOperation);
	}

- (CURLOperation *)operationToFetchDocument:(CCouchDBDocument *)inDocument options:(NSDictionary *)inOptions successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler
	{
    inFailureHandler = inFailureHandler ?: self.session.defaultFailureHandler;

	// TODO -- this only fetches the latest document (i.e. _rev is ignored). What if we don't want the latest document?
	NSURL *theURL = inDocument.URL;
	NSMutableURLRequest *theRequest = [self.session requestWithURL:theURL];
	theRequest.HTTPMethod = @"GET";
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];
	CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
	theOperation.successHandler = ^(id inParameter) {
		[inDocument populateWithJSON:inParameter];

		if (inSuccessHandler)
			inSuccessHandler(inDocument);
		};
	theOperation.failureHandler = inFailureHandler;

	return(theOperation);
	}

#pragma mark -

- (CURLOperation *)operationToUpdateDocument:(CCouchDBDocument *)inDocument successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler
	{
    inFailureHandler = inFailureHandler ?: self.session.defaultFailureHandler;

	NSURL *theURL = inDocument.URL;
	NSMutableURLRequest *theRequest = [self.session requestWithURL:theURL];
	theRequest.HTTPMethod = @"PUT";
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];
	NSData *theData = [self.session.serializer serializeDictionary:inDocument.content error:NULL];
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Content-Type"];
	[theRequest setHTTPBody:theData];

	CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
	theOperation.successHandler = ^(id inParameter) {
		[inDocument populateWithJSON:inParameter];

		if (inSuccessHandler)
			inSuccessHandler(inDocument);
		};
	theOperation.failureHandler = inFailureHandler;

	return(theOperation);
	}

- (CURLOperation *)operationToDeleteDocumentForIdentifier:(NSString *)inIdentifier revision:(NSString *)inRevision successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler
    {
    inFailureHandler = inFailureHandler ?: self.session.defaultFailureHandler;

	NSURL *theURL = [self.URL URLByAppendingPathComponent:inIdentifier];
//    theURL = [theURL URLByAppendingPathComponent:[NSString stringWithFormat:@"?rev=%@", inRevision]];

    theURL = [NSURL URLWithRoot:theURL query:[NSString stringWithFormat:@"rev=%@", inRevision]];
    
    NSLog(@"%@", theURL);

//    [inDocument.URL URLByAppendingPathComponent:[NSString stringWithFormat:@"?rev=%@", inDocument.revision]];
    NSMutableURLRequest *theRequest = [self.session requestWithURL:theURL];
    theRequest.HTTPMethod = @"DELETE";
    [theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];
    CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
    theOperation.successHandler = ^(id inParameter) {
        if (inSuccessHandler)
            inSuccessHandler(inIdentifier);
        };
    theOperation.failureHandler = inFailureHandler;

    return(theOperation);
    }

- (CURLOperation *)operationToDeleteDocument:(CCouchDBDocument *)inDocument successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler
	{
    inFailureHandler = inFailureHandler ?: self.session.defaultFailureHandler;

    NSMutableString *urlString = [[NSMutableString alloc] init];
    [urlString appendString: [inDocument.URL absoluteString]];
    [urlString appendFormat:@"?rev=%@", inDocument.revision];

    NSURL *theURL = [NSURL URLWithString:urlString];

    [inDocument.URL URLByAppendingPathComponent:[NSString stringWithFormat:@"?rev=%@", inDocument.revision]];
    NSMutableURLRequest *theRequest = [self.session requestWithURL:theURL];
    theRequest.HTTPMethod = @"DELETE";
    [theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];
    CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
    theOperation.successHandler = ^(id inParameter) {
        if (inSuccessHandler)
            inSuccessHandler(inDocument);
        };
    theOperation.failureHandler = inFailureHandler;

    return(theOperation);
	}

- (CURLOperation *)operationToFetchChanges:(NSDictionary *)inOptions successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler
    {
    inFailureHandler = inFailureHandler ?: self.session.defaultFailureHandler;

    NSURL *theURL = [self.URL URLByAppendingPathComponent:@"_changes"];
	if (inOptions)
		{
		theURL = [NSURL URLWithRoot:theURL queryDictionary:inOptions];
		}
    NSMutableURLRequest *theRequest = [self.session requestWithURL:theURL];
    theRequest.HTTPMethod = @"GET";
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];

    __block CCouchDBDatabase *_self = self;
    CCouchDBURLOperation *theOperation = [[CCouchDBURLOperation alloc] initWithSession:self.session request:theRequest];
    theOperation.successHandler = ^(id inParameter) {
		CCouchDBChangeSet *theChangeSet = [[CCouchDBChangeSet alloc] initWithDatabase:_self JSON:inParameter];

        if (inSuccessHandler)
            inSuccessHandler(theChangeSet);

        _self = NULL;
        };
    theOperation.failureHandler = inFailureHandler;

    return(theOperation);
    }

- (CURLOperation *)operationToBulkCreateDocuments:(id)inDocuments successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler
    {
    inFailureHandler = inFailureHandler ?: self.session.defaultFailureHandler;

    NSURL *theURL = [self.URL URLByAppendingPathComponent:@"_bulk_docs"];
    NSMutableURLRequest *theRequest = [self.session requestWithURL:theURL];
    theRequest.HTTPMethod = @"POST";
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];

    NSDictionary *theBody = [NSDictionary dictionaryWithObjectsAndKeys:
        inDocuments, @"docs",
        NULL];

    NSData *theData = [self.session.serializer serializeDictionary:theBody error:NULL];
    [theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Content-Type"];
    [theRequest setHTTPBody:theData];

    CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
    __block CCouchDBURLOperation *_theOperation = theOperation;
    theOperation.successHandler = ^(id inParameter) {
        if (_theOperation.error)
            {
            if (inFailureHandler)
                inFailureHandler(_theOperation.error);
            }
        else
            {
//        if ([[inParameter objectForKey:@"ok"] boolValue] == NO)
//            {
//            NSError *theError = [NSError errorWithDomain:kCouchErrorDomain code:-3 userInfo:NULL];
//            if (inFailureHandler)
//                inFailureHandler(theError);
//            return;
//            }

            if (inSuccessHandler)
                inSuccessHandler(_theOperation.JSON);
            }

        _theOperation = NULL;
        };

    return(theOperation);
    }
	
- (CURLOperation *)operationToBulkFetchDocuments:(NSArray *)inDocuments options:(NSDictionary *)inOptions successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;
	{
    inFailureHandler = inFailureHandler ?: self.session.defaultFailureHandler;

	NSURL *theURL = [self.URL URLByAppendingPathComponent:@"_all_docs"];
	
	if (inOptions == NULL)
		{
		inOptions = [NSDictionary dictionaryWithObject:@"true" forKey:@"include_docs"];
		}
	
	if (inOptions.count > 0)
		{
		theURL = [NSURL URLWithRoot:theURL queryDictionary:inOptions];
		}

	NSMutableURLRequest *theRequest = [self.session requestWithURL:theURL];
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];

	if (inDocuments.count == 0)
		{
		theRequest.HTTPMethod = @"GET";
		}
	else
		{
		theRequest.HTTPMethod = @"POST";
		
		NSDictionary *theBodyDictionary = [NSDictionary dictionaryWithObject:inDocuments forKey:@"keys"];
		NSError *theError = NULL;
		NSData *theData = [self.session.serializer serializeDictionary:theBodyDictionary error:&theError];
		if (theData == NULL)
			{
			if (inFailureHandler)
				{
				inFailureHandler(theError);
				}
			return(NULL);
			}
		[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Content-Type"];
		[theRequest setHTTPBody:theData];
		}
	
    __block CCouchDBDatabase *_self = self;
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
				theDocument = [[CCouchDBDocument alloc] initWithDatabase:_self];
				[theDocument populateWithJSON:doc];
				}
			else
				{
				NSString *theIdentifier = [theRow objectForKey:@"id"];

				theDocument = [[CCouchDBDocument alloc] initWithDatabase:_self identifier:theIdentifier];
				theDocument.revision = [theRow valueForKeyPath:@"value.rev"];
				}

            CCouchDBViewRow *viewRow = [[CCouchDBViewRow alloc] initWithKey:key value:value document:theDocument];

            [theViewRows addObject:viewRow];
			}

        NSInteger theTotalRows = [[inParameter objectForKey:@"total_rows"] integerValue];
        NSInteger theOffset = [[inParameter objectForKey:@"offset"] integerValue];        
        CCouchDBView *theView = [[CCouchDBView alloc] initWithTotalRows:theTotalRows offset:theOffset rows:theViewRows];
		if (inSuccessHandler)
			inSuccessHandler(theView);

        _self = NULL;
		};
	theOperation.failureHandler = inFailureHandler;

	return(theOperation);
	}

@end
