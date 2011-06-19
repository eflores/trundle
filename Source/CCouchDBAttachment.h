//
//  CCouchDBAttachment.h
//  CouchTest
//
//  Created by Jonathan Wight on 02/23/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCouchDBDocument;

@interface CCouchDBAttachment : NSObject {
}

@property (readwrite, nonatomic, weak) CCouchDBDocument *document;
@property (readwrite, nonatomic, retain) NSString *identifier;
@property (readwrite, nonatomic, retain) NSString *contentType;
@property (readwrite, nonatomic, retain) NSData *data;

- (id)initWithIdentifier:(NSString *)inIdentifier contentType:(NSString *)inContentType data:(NSData *)inData;

@end
