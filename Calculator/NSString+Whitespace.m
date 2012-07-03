//
//  NSString+Whitespace.m
//  Calculator
//
//  Created by Lee Hounshell on 7/2/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import "NSString+Whitespace.h"

@implementation NSString (Whitespace)

- (NSString *)stringByCompressingWhitespaceTo:(NSString *)seperator
{
    NSArray *comps = [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSMutableArray *nonemptyComps = [[NSMutableArray alloc] init];
    
    // only copy non-empty entries
    for (NSString *oneComp in comps)
    {
        if (![oneComp isEqualToString:@""])
        {
            [nonemptyComps addObject:oneComp];
        }
        
    }
    
    return [nonemptyComps componentsJoinedByString:seperator];
}

@end

