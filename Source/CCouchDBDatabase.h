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
@class CCouchDBSession;

@interface CCouchDBDatabase : NSObject {
}

@property (readonly, retain) CCouchDBSession *session;
@property (readonly, weak) CCouchDBServer *server;
@property (readonly, copy) NSString *name;
@property (readonly, copy) NSString *encodedName;
@property (readonly, copy) NSURL *URL;

- (id)initWithServer:(CCouchDBServer *)inServer name:(NSString *)inName;
- (id)initWithURL:(NSURL *)inURL;

- (CCouchDBDesignDocument *)designDocumentNamed:(NSString *)inName;

- (CURLOperation *)operationToCreateDocument:(NSDictionary *)inDocument successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;
- (CURLOperation *)operationToCreateDocument:(NSDictionary *)inDocument identifier:(NSString *)inIdentifier successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;

- (CURLOperation *)operationToFetchAllDocumentsWithOptions:(NSDictionary *)inOptions withSuccessHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;
- (CURLOperation *)operationToFetchDocumentForIdentifier:(NSString *)inIdentifier options:(NSDictionary *)inOptions successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;
- (CURLOperation *)operationToFetchDocument:(CCouchDBDocument *)inDocument options:(NSDictionary *)inOptions successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;

- (CURLOperation *)operationToUpdateDocument:(CCouchDBDocument *)inDocument successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;

- (CURLOperation *)operationToDeleteDocumentForIdentifier:(NSString *)inIdentifier revision:(NSString *)inRevision successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;
- (CURLOperation *)operationToDeleteDocument:(CCouchDBDocument *)inDocument successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;

- (CURLOperation *)operationToFetchChanges:(NSDictionary *)inOptions successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;

- (CURLOperation *)operationToBulkCreateDocuments:(id)inDocuments successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;
- (CURLOperation *)operationToBulkFetchDocuments:(NSArray *)inDocuments options:(NSDictionary *)inOptions successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;

@end
