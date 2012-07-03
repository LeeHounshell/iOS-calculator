//
//  NSString+Whitespace.h
//  Calculator
//
//  Created by Lee Hounshell on 7/2/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Whitespace)

// Note: a category implementation does not have ivars in { }

- (NSString *)stringByCompressingWhitespaceTo:(NSString *)seperator;

@end
