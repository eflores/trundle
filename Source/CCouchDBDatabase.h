//
//  CCouchDBDatabase.h
//  CouchTest
//
//  Created by Jonathan Wight on 02/16/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CouchDBClientTypes.h"

@class CCouchDBServer;
@class CCouchDBDocument;
@class CURLOperation;
@class CCouchDBDesignDocument;

@interface CCouchDBDatabase : NSObject {
	CCouchDBServer *server;
	NSString *name;
	NSString *encodedName;
	NSURL *URL;
	NSCache *cachedDocuments;
	NSMutableDictionary *designDocuments;
}

@property (readonly, assign) CCouchDBServer *server;
@property (readonly, copy) NSString *name;
@property (readonly, copy) NSString *encodedName;
@property (readonly, copy) NSURL *URL;

- (id)initWithServer:(CCouchDBServer *)inServer name:(NSString *)inName;

- (CCouchDBDesignDocument *)designDocumentNamed:(NSString *)inName;

- (CURLOperation *)operationToCreateDocument:(NSDictionary *)inDocument successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;
- (CURLOperation *)operationToCreateDocument:(NSDictionary *)inDocument identifier:(NSString *)inIdentifier successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;

- (CURLOperation *)operationToFetchAllDocumentsWithSuccessHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;
- (CURLOperation *)operationToFetchDocumentForIdentifier:(NSString *)inIdentifier successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;
- (CURLOperation *)operationToFetchDocument:(CCouchDBDocument *)inDocument successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;

- (CURLOperation *)operationToUpdateDocument:(CCouchDBDocument *)inDocument successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;

- (CURLOperation *)operationToDeleteDocument:(CCouchDBDocument *)inDocument successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;

- (CURLOperation *)operationForChanges:(NSDictionary *)inOptions successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;

- (CURLOperation *)operationToBulkCreateDocuments:(id)inDocuments successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;

@end
