//
//  GraphView.m
//  Calculator
//
//  Created by Lee Hounshell on 7/14/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import "GraphView.h"

@implementation GraphView

@synthesize delegate = _delegate;
@synthesize origin = _origin;
@synthesize scale = _scale;


#define DEFAULT_SIZE 0.90

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
    NSLog(@"pinchHandler gesture=%@", gesture);
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
        NSLog(@"panHandler translate.x=%g translate.y=%g", translate.x, translate.y);
		self.origin = CGPointMake(self.origin.x + translate.x, self.origin.y + translate.y);
		[gesture setTranslation:CGPointZero inView:self];
    }
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    // graph (X, Y)
    
    CGPoint midPoint; // center of our bounds in our coordinate system
    midPoint.x = self.bounds.origin.x + self.bounds.size.width/2 + self.origin.x;
    midPoint.y = self.bounds.origin.y + self.bounds.size.height/2 + self.origin.y;
    
    CGFloat size = self.bounds.size.width / 2;
    if (self.bounds.size.height < self.bounds.size.width) size = self.bounds.size.height / 2;
    size *= self.scale; // scale is percentage of full view size
    
    CGContextSetLineWidth(context, 5.0);
    [[UIColor blueColor] setStroke];
    
    [self drawCircleAtPoint:midPoint withRadius:size inContext:context]; // head
    
#define EYE_H 0.35
#define EYE_V 0.35
#define EYE_RADIUS 0.10
    
    CGPoint eyePoint;
    eyePoint.x = midPoint.x - size * EYE_H;
    eyePoint.y = midPoint.y - size * EYE_V;
    
    [self drawCircleAtPoint:eyePoint withRadius:size * EYE_RADIUS inContext:context]; // left eye
    eyePoint.x += size * EYE_H * 2;
    [self drawCircleAtPoint:eyePoint withRadius:size * EYE_RADIUS inContext:context]; // right eye
    
#define MOUTH_H 0.45
#define MOUTH_V 0.40
#define MOUTH_SMILE 0.25
    
    CGPoint mouthStart;
    mouthStart.x = midPoint.x - MOUTH_H * size;
    mouthStart.y = midPoint.y + MOUTH_V * size;
    CGPoint mouthEnd = mouthStart;
    mouthEnd.x += MOUTH_H * size * 2;
    CGPoint mouthCP1 = mouthStart;
    mouthCP1.x += MOUTH_H * size * 2/3;
    CGPoint mouthCP2 = mouthEnd;
    mouthCP2.x -= MOUTH_H * size * 2/3;
    
    float smile = 1.0; // this should be delegated! it's our View's data!
    
    CGFloat smileOffset = MOUTH_SMILE * size * smile;
    mouthCP1.y += smileOffset;
    mouthCP2.y += smileOffset;
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, mouthStart.x, mouthStart.y);
    CGContextAddCurveToPoint(context, mouthCP1.x, mouthCP2.y, mouthCP2.x, mouthCP2.y, mouthEnd.x, mouthEnd.y); // bezier curve
    CGContextStrokePath(context);
}

- (void)drawCircleAtPoint:(CGPoint)p withRadius:(CGFloat)radius inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    CGContextBeginPath(context);
    CGContextAddArc(context, p.x, p.y, radius, 0, 2*M_PI, YES); // 360 degree (0 to 2pi) arc
    CGContextStrokePath(context);
    UIGraphicsPopContext();
}

@end
