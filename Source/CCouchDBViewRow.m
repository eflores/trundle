//
//  CCouchDBViewRow.m
//  CouchpadAdministrator
//
//  Created by Marty Schoch on 6/18/11.
//  Copyright 2011 Marty Schoch.
//

#import "CCouchDBViewRow.h"

@implementation CCouchDBViewRow

@synthesize key;
@synthesize value;
@synthesize document;

- (id)initWithKey:(id)inKey value:(id)inValue document:(CCouchDBDocument *)inDocument;
	{
	if ((self = [super init]) != NULL)
		{
        key = inKey;
        value = inValue;
        document = inDocument;
		}
	return(self);
	}

- (NSString *)description
    {
    return([NSString stringWithFormat:@"%@ (key:%@ value:%@ doc:%@ )", [super description], self.key, self.value, self.document]);
    }

@end
