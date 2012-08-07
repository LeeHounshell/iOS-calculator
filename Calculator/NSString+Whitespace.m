//
//  NSString+Whitespace.m
//  Calculator
//
//  Created by Lee Hounshell on 7/2/12.
//  Copyright (c) 2012 Harlie All rights reserved.
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

- (NSString *)stripParensFromEnds
{
    NSString *result = self;
    if ([result length] >= 3
     && '(' == [result characterAtIndex:0]
     && ')' == [result characterAtIndex:[result length] - 1]) {
        result = [result substringWithRange:NSMakeRange(1, [result length] - 2)];
    }
    return result;
}

@end

