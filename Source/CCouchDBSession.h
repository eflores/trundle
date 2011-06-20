//
//  CCouchDBSession.h
//  TouchMetricsTest
//
//  Created by Jonathan Wight on 08/21/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CouchDBClientTypes.h"

@class CJSONSerializer;
@class CJSONDeserializer;

@interface CCouchDBSession : NSObject {

}

@property (readwrite, nonatomic, retain) NSOperationQueue *operationQueue;
@property (readwrite, nonatomic, assign) Class URLOperationClass;
@property (readwrite, nonatomic, retain) CJSONSerializer *serializer;
@property (readwrite, nonatomic, retain) CJSONDeserializer *deserializer;
@property (readwrite, nonatomic, retain) NSURLCredential *URLCredential;
@property (readwrite, nonatomic, copy) CouchDBFailureHandler defaultFailureHandler;

+ (CCouchDBSession *)defaultSession;

- (NSMutableURLRequest *)requestWithURL:(NSURL *)inURL;
- (id)URLOperationWithRequest:(NSURLRequest *)inURLRequest;

@end
