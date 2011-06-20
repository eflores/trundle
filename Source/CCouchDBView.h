//
//  CCouchDBView.h
//  CouchpadAdministrator
//
//  Created by Marty Schoch on 6/18/11.
//  Copyright 2011 Marty Schoch.
//

#import <Foundation/Foundation.h>


@interface CCouchDBView : NSObject {
    
}

@property (readonly, nonatomic, assign) NSInteger totalRows;
@property (readonly, nonatomic, assign) NSInteger offset;
@property (readonly, nonatomic, retain) NSArray *rows;

- (id)initWithTotalRows:(NSInteger)inTotalRows offset:(NSInteger)inOffset rows:(NSArray *)inRows;

@end
