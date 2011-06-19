//
//  CCouchDBURLOperation.h
//  CouchTest
//
//  Created by Jonathan Wight on 04/14/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CURLOperation.h"

#import "CouchDBClientTypes.h"

@class CCouchDBSession;

@interface CCouchDBURLOperation : CURLOperation {
}

@property (readwrite, nonatomic, retain) id JSON;
@property (readwrite, nonatomic, copy) CouchDBSuccessHandler successHandler;
@property (readwrite, nonatomic, copy) CouchDBFailureHandler failureHandler;

- (id)initWithSession:(CCouchDBSession *)inSession request:(NSURLRequest *)inRequest;

@end
