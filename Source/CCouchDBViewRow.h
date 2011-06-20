//
//  CCouchDBViewRow.h
//  CouchpadAdministrator
//
//  Created by Marty Schoch on 6/18/11.
//  Copyright 2011 Marty Schoch.
//

#import <Foundation/Foundation.h>

@class CCouchDBDocument;

@interface CCouchDBViewRow : NSObject {
    
}

@property (readonly, nonatomic, retain) id key;
@property (readonly, nonatomic, retain) id value;
@property (readonly, nonatomic, retain) CCouchDBDocument *document;

- (id)initWithKey:(id)inKey value:(id)inValue document:(CCouchDBDocument *)inDocument;

@end
