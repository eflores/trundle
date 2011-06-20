//
//  CCouchDBView.m
//  CouchpadAdministrator
//
//  Created by Marty Schoch on 6/18/11.
//  Copyright 2011 Marty Schoch.
//

#import "CCouchDBView.h"


@implementation CCouchDBView

@synthesize totalRows;
@synthesize offset;
@synthesize rows;

- (id)initWithTotalRows:(NSInteger)inTotalRows offset:(NSInteger)inOffset rows:(NSArray *)inRows;
	{
	if ((self = [super init]) != NULL)
		{
        totalRows = inTotalRows;
        offset = inOffset;
        rows = inRows;
		}
	return(self);
	}

- (NSString *)description
    {
    return([NSString stringWithFormat:@"%@ (totalRows:%d offset:%d rows:%@ )", [super description], self.totalRows, self.offset, self.rows]);
    }

@end
