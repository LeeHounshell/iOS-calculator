//
//  GraphView.h
//  Calculator
//
//  Created by Lee Hounshell on 7/14/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@protocol GraphViewDelegate 
- (double)calculateYResultForXValue:(CGFloat)x requestor:(GraphView *)graphView;
@end

@interface GraphView : UIView

- (void)pinchHandler:(UIPinchGestureRecognizer *)gesture;

@property (nonatomic, weak) id <GraphViewDelegate> delegate;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGFloat scale;

@end
