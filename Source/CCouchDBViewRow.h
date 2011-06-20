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

@property (nonatomic, retain) id key;
@property (nonatomic, retain) id value;
@property (nonatomic, retain) CCouchDBDocument *doc;

@end
