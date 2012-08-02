//
//  GraphView.m
//  Calculator
//
//  Created by Lee Hounshell on 7/14/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@implementation GraphView

@synthesize delegate = _delegate;
@synthesize origin = _origin;
@synthesize scale = _scale;


#define DEFAULT_SIZE 26

- (void)setup
{
    self.contentMode = UIViewContentModeRedraw;
    self.origin = CGPointMake(0, 0);
    self.scale = DEFAULT_SIZE;
}

- (void)awakeFromNib // storyboard initialization
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame // not called from storyboard
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setOrigin:(CGPoint)origin
{
    _origin = origin;
    [self setNeedsDisplay];
}

- (CGFloat)scale
{
    if (! _scale) {
        return DEFAULT_SIZE;
    }
    return _scale;
}

- (void)setScale:(CGFloat)scale
{
    _scale = scale;
    [self setNeedsDisplay]; // redraw to scale
}

- (void)pinchHandler:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged)
     || (gesture.state == UIGestureRecognizerStateEnded))
    {
        self.scale *= gesture.scale;
        gesture.scale = 1; // we don't want cumulative scale
    }
}

- (void)panHandler:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged)
        || (gesture.state == UIGestureRecognizerStateEnded))
    {
        CGPoint translate = [gesture translationInView:self];
        self.origin = CGPointMake(self.origin.x + translate.x, self.origin.y + translate.y);
        [gesture setTranslation:CGPointZero inView:self];
    }
}

- (void)tapHandler:(UIGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged)
        || (gesture.state == UIGestureRecognizerStateEnded))
    {
        self.origin = CGPointMake(0, 0);
        self.scale = DEFAULT_SIZE;
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint midPoint; // center of our bounds in our coordinate system
    midPoint.x = self.bounds.origin.x + self.bounds.size.width/2 + self.origin.x;
    midPoint.y = self.bounds.origin.y + self.bounds.size.height/2 + self.origin.y;
    
    CGFloat size = self.bounds.size.width / 2;
    if (self.bounds.size.height < self.bounds.size.width) {
        size = self.bounds.size.height / 2;
    }
    size *= self.scale; // scale is percentage of full view size
    
    CGContextSetLineWidth(context, 1.0);
    [[UIColor blackColor] setStroke];
    
    [AxesDrawer drawAxesInRect:self.bounds originAtPoint:midPoint scale:self.scale*self.contentScaleFactor];
    
    if (! [self.delegate isValidProgram]) {
        NSLog(@"GraphView: nothing to graph except the axes");
        return;
    }
    NSLog(@"GraphView: graphing the equation..");

    [[UIColor blueColor] setStroke];
    // loop through all X and invoke delegate calculateYResultForXValue to determine Y.  plot values.
    BOOL didInitialPoint = NO;
    for (CGFloat x = 0; x <= self.bounds.size.width; x++) {
        CGPoint thePoint;
        thePoint.x = x;
        CGPoint graphPoint;
        graphPoint.x = (thePoint.x - midPoint.x)/(self.scale * self.contentScaleFactor);
        graphPoint.y = ([self.delegate calculateYResultForXValue:graphPoint.x requestor:self]);
        //NSLog(@"graphpoint.x=%g graphpoint.y=%g", graphPoint.x, graphPoint.y);
        thePoint.y = midPoint.y - (graphPoint.y * self.scale * self.contentScaleFactor);
        double xPoint = thePoint.x;
        double yPoint = thePoint.y;
        // if we try and draw outside the bounds, the app can crash
        if (xPoint < (self.bounds.origin.x + self.bounds.size.width) && xPoint > 0 &&
            yPoint < (self.bounds.origin.y + self.bounds.size.height) && yPoint > 0) {
            if (! didInitialPoint) {
                CGContextMoveToPoint(context, xPoint, yPoint);
                didInitialPoint = YES;
            }
            else {
                CGContextAddLineToPoint(context, xPoint, yPoint);
            }
        }
        //else {
        //    NSLog(@"discard point: x=%g, y=%g", xPoint, yPoint);
        //}
    }
    
    CGContextStrokePath(context);
}

@end
