//
//  ScribbleView.m
//  ScribblingPad
//
//  Created by Raghav Sai Cheedalla on 7/18/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import "ScribbleView.h"

@implementation ScribbleView
{
    UIBezierPath *path;
    CGPoint pts[5]; // we now need to keep track of the four points of a Bezier segment and the first control point of the next segment
    uint ctr;
    BOOL erase;
    BOOL tap;
    CGPoint touchPoint;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self initialSetup];
    }
    return self;
    
}
- (void)initialSetup
{
    [self setMultipleTouchEnabled:NO];
    path = [UIBezierPath bezierPath];
    [path setLineWidth:2.0];
    
}

- (void)drawRect:(CGRect)rect
{
    [incrementalImage drawInRect:rect];
    if(!incrementalImage)
    {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, YES, 0.0);
        if(self.imageToBeDisplayed)
            [self.imageToBeDisplayed drawInRect:self.bounds];
        else
            [[UIImage imageNamed:@"white.jpg"] drawInRect:self.bounds];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
        [[UIColor colorWithPatternImage:image] setFill];
        [rectpath fill];
    }
    if (erase)
    {
        [[UIColor whiteColor] setStroke];
        [path setLineCapStyle:kCGLineCapRound];
        [path setLineWidth:20];
    }
    else
    {
        [[UIColor blackColor] setStroke];
        [path setLineWidth:2.0];
    }
    [path stroke];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    ctr = 0;
    UITouch *touch = [touches anyObject];
    pts[0] = [touch locationInView:self];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    ctr++;
    pts[ctr] = p;
    
    if (ctr == 4)
    {
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
        
        [path moveToPoint:pts[0]];
        [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
        
        [self setNeedsDisplay];
        // replace points and get ready to handle the next segment
        pts[0] = pts[3];
        pts[1] = pts[4];
        ctr = 1;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if(touch.tapCount == 1)
    {
        touchPoint = [touch locationInView:self];
        tap = YES;
        if(!erase)
            [self drawDot:touchPoint];
    }
    [self drawBitmap];
    [self setNeedsDisplay];
    [path removeAllPoints];
    ctr = 0;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)drawBitmap
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, YES, 0.0);
    
    if (!incrementalImage) // first time; paint background white
    {
        if(self.imageToBeDisplayed)
            [self.imageToBeDisplayed drawInRect:self.bounds];
        else
            [[UIImage imageNamed:@"white.jpg"] drawInRect:self.bounds];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
        [[UIColor colorWithPatternImage:image] setFill];
        [rectpath fill];
    }
    [incrementalImage drawAtPoint:CGPointZero];
    if (erase)
    {
        if(tap)
        {
            [self drawDotErase:touchPoint];
            tap = NO;
        }
        [[UIColor whiteColor] setStroke];
    }
    else
        [[UIColor blackColor] setStroke];
    [path stroke];
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}


- (void)drawDotErase:(CGPoint)point
{
    CGRect rect = CGRectMake(touchPoint.x, touchPoint.y, 2 * 10, 2 * 10);
    path = [UIBezierPath bezierPathWithOvalInRect:rect];
    [[UIColor whiteColor] setFill];
    [path fill];
}

- (void)drawDot:(CGPoint)point
{
    CGRect rect = CGRectMake(touchPoint.x, touchPoint.y, 1, 1);
    path = [UIBezierPath bezierPathWithOvalInRect:rect];
}

- (void)clearView
{
    path   = nil;  //Set current path nil
    incrementalImage = nil;
    [self initialSetup];
    [self setNeedsDisplay];
}

- (void)activateErase
{
    if(!erase)
        erase = YES;
    else
        erase = NO;
}

@end
