//
//  GraphView.h
//  Calculator
//
//  Created by Lee Hounshell on 7/14/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphView : UIView

- (void)pinchHandler:(UIPinchGestureRecognizer *)gesture;

@property (nonatomic) CGFloat scale;

@end
