//
//  uzysRadialProgressActivityIndicator.m
//  UzysRadialProgressActivityIndicator
//
//  Created by Uzysjung on 13. 10. 22..
//  Copyright (c) 2013년 Uzysjung. All rights reserved.
//

#import "UzysRadialProgressActivityIndicator.h"
#import "UIScrollView+UzysCircularProgressPullToRefresh.h"
#define DEGREES_TO_RADIANS(x) (x)/180.0*M_PI
#define RADIANS_TO_DEGREES(x) (x)/M_PI*180.0

#define cDefaultFloatComparisonEpsilon    0.001
#define cEqualFloats(f1, f2, epsilon)    ( fabs( (f1) - (f2) ) < epsilon )
#define cNotEqualFloats(f1, f2, epsilon)    ( !cEqualFloats(f1, f2, epsilon) )


#define PulltoRefreshThreshold 60.0
#define StartPosition 5.0
@interface UzysRadialProgressActivityIndicatorBackgroundLayer : CALayer

@property (nonatomic,assign) CGFloat outlineWidth;
- (id)initWithBorderWidth:(CGFloat)width;

@end
@implementation UzysRadialProgressActivityIndicatorBackgroundLayer
- (id)init
{
    self = [super init];
    if(self) {
        self.outlineWidth=2.0f;
        self.contentsScale = [UIScreen mainScreen].scale;
        [self setNeedsDisplay];
    }
    return self;
}
- (id)initWithBorderWidth:(CGFloat)width
{
    self = [super init];
    if(self) {
        self.outlineWidth=width;
        self.contentsScale = [UIScreen mainScreen].scale;
        [self setNeedsDisplay];
    }
    return self;
}
- (void)drawInContext:(CGContextRef)ctx
{
    //Draw white circle
    CGContextSetFillColor(ctx, CGColorGetComponents([UIColor colorWithWhite:1.0 alpha:0.8].CGColor));
    CGContextFillEllipseInRect(ctx,CGRectInset(self.bounds, self.outlineWidth, self.outlineWidth));

    //Draw circle outline
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:1.0 alpha:0.9].CGColor);
    CGContextSetLineWidth(ctx, self.outlineWidth);
    CGContextStrokeEllipseInRect(ctx, CGRectInset(self.bounds, self.outlineWidth , self.outlineWidth ));
}
- (void)setOutlineWidth:(CGFloat)outlineWidth
{
    _outlineWidth = outlineWidth;
    [self setNeedsDisplay];
}
@end

/*-----------------------------------------------------------------*/
@interface UzysRadialProgressActivityIndicator()
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;  //Loading Indicator
@property (nonatomic, strong) UzysRadialProgressActivityIndicatorBackgroundLayer *backgroundLayer;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CALayer *imageLayer;
@property (nonatomic, assign) double progress;

@end
@implementation UzysRadialProgressActivityIndicator

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 42, 42)];
    if(self) {
        [self _commonInit];
    }
    return self;
}
- (id)initWithImage:(UIImage *)image
{
    self = [super initWithFrame:CGRectMake(0, 0, 42, 42)];
    if(self) {
        self.imageIcon =image;
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit
{
    self.borderColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    self.borderWidth = 2.0f;
    self.contentMode = UIViewContentModeRedraw;
    self.state = UZYSPullToRefreshStateNone;
    self.backgroundColor = [UIColor clearColor];
    self.progressThreshold = PulltoRefreshThreshold;
    //init actitvity indicator
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicatorView.hidesWhenStopped = YES;
    _activityIndicatorView.frame = self.bounds;
    [self addSubview:_activityIndicatorView];
    
    //init background layer
    UzysRadialProgressActivityIndicatorBackgroundLayer *backgroundLayer = [[UzysRadialProgressActivityIndicatorBackgroundLayer alloc] initWithBorderWidth:self.borderWidth];
    backgroundLayer.frame = self.bounds;
    [self.layer addSublayer:backgroundLayer];
    self.backgroundLayer = backgroundLayer;
    
    if(!self.imageIcon)
        self.imageIcon = [UIImage imageNamed:@"coffee"];
    
    //init icon layer
    CALayer *imageLayer = [CALayer layer];
    imageLayer.contentsScale = [UIScreen mainScreen].scale;
    imageLayer.frame = CGRectInset(self.bounds, self.borderWidth, self.borderWidth);
    imageLayer.contents = (id)self.imageIcon.CGImage;
    imageLayer.contentsGravity = kCAGravityResizeAspect;
    [self.layer addSublayer:imageLayer];
    self.imageLayer = imageLayer;
    self.imageLayer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS(180),0,0,1);

    //init arc draw layer
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.frame = self.bounds;
    shapeLayer.fillColor = nil;
    shapeLayer.strokeColor = self.borderColor.CGColor;
    shapeLayer.strokeEnd = 0;
    shapeLayer.shadowColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    shapeLayer.shadowOpacity = 0.7;
    shapeLayer.shadowRadius = 20;
    shapeLayer.contentsScale = [UIScreen mainScreen].scale;
    shapeLayer.lineWidth = self.borderWidth;
    shapeLayer.lineCap = kCALineCapRound;
    
    [self.layer addSublayer:shapeLayer];
    self.shapeLayer = shapeLayer;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.shapeLayer.frame = self.bounds;
    [self updatePath];

}
- (void)updatePath {
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:center radius:(self.bounds.size.width/2 - self.borderWidth)  startAngle:M_PI - DEGREES_TO_RADIANS(-90) endAngle:M_PI -DEGREES_TO_RADIANS(360-90) clockwise:NO];

    self.shapeLayer.path = bezierPath.CGPath;
}

#pragma mark - ScrollViewInset
- (void)setupScrollViewContentInsetForLoadingIndicator:(actionHandler)handler animation:(BOOL)animation
{
    
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    float idealOffset = self.originalTopInset + self.bounds.size.height + 20.0;
    currentInsets.top = idealOffset;
    
    [self setScrollViewContentInset:currentInsets handler:handler animation:animation];
}
- (void)resetScrollViewContentInset:(actionHandler)handler animation:(BOOL)animation
{
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = self.originalTopInset;
    [self setScrollViewContentInset:currentInsets handler:handler animation:animation];
}
- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset handler:(actionHandler)handler animation:(BOOL)animation
{
    //NSLog(@"offset %f",self.scrollView.contentOffset.y);
    if(animation)
    {
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.scrollView.contentInset = contentInset;
                             if(self.state == UZYSPullToRefreshStateLoading && self.scrollView.contentOffset.y <10) {
                                 self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, -1*contentInset.top);
                             }
                         }
                         completion:^(BOOL finished) {
                             if(handler)
                                 handler();
                         }];
    }
    else
    {
        self.scrollView.contentInset = contentInset;
        if(self.state == UZYSPullToRefreshStateLoading && self.scrollView.contentOffset.y <10) {
            self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, -1*contentInset.top);
        }
        
        if(handler)
            handler();
    }
}

#pragma mark - property
- (void)setProgress:(double)progress
{
    static double prevProgress;
    
    if(progress > 1.0)
    {
        progress = 1.0;
    }
    
//    self.alpha = 1.0 * progress;

    if (progress >= 0 && progress <=1.0) {
        //rotation Animation
        CABasicAnimation *animationImage = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animationImage.fromValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(180-180*prevProgress)];
        animationImage.toValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(180-180*progress)];
        animationImage.duration = 0.15;
        animationImage.removedOnCompletion = NO;
        animationImage.fillMode = kCAFillModeForwards;
        [self.imageLayer addAnimation:animationImage forKey:@"animation"];
        
        // SizingAnimation
        CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        theAnimation.duration=0.15;
        theAnimation.removedOnCompletion = NO;
        theAnimation.fromValue = [NSNumber numberWithFloat:1.0*prevProgress];
        theAnimation.toValue = [NSNumber numberWithFloat:1.0*progress];
        theAnimation.fillMode = kCAFillModeForwards;
        [self.imageLayer addAnimation:theAnimation forKey:@"animationScale"];
        [self.backgroundLayer addAnimation:theAnimation forKey:@"animation"];
        [self.shapeLayer addAnimation:theAnimation forKey:@"animationScale"];
        
        
        //strokeAnimation
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.fromValue = [NSNumber numberWithFloat:((CAShapeLayer *)self.shapeLayer.presentationLayer).strokeEnd];
        animation.toValue = [NSNumber numberWithFloat:progress];
        animation.duration = 0.35 + 0.25*(fabs([animation.fromValue doubleValue] - [animation.toValue doubleValue]));
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//        [self.shapeLayer removeAllAnimations];
        [self.shapeLayer addAnimation:animation forKey:@"animation"];
        
    }
    _progress = progress;
    prevProgress = progress;
}
-(void)setLayerOpacity:(CGFloat)opacity
{
    self.imageLayer.opacity = opacity;
    self.backgroundLayer.opacity = opacity;
    self.shapeLayer.opacity = opacity;
}
-(void)setLayerHidden:(BOOL)hidden
{
    self.imageLayer.hidden = hidden;
    self.shapeLayer.hidden = hidden;
    self.backgroundLayer.hidden = hidden;
}
-(void)setCenter:(CGPoint)center
{
    [super setCenter:center];
}
- (void)setProgressThreshold:(CGFloat)progressThreshold
{
    _progressThreshold = progressThreshold;
    self.frame = CGRectMake(self.frame.origin.x, self.progressThreshold, self.frame.size.width, self.frame.size.height);
}
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"contentOffset"])
    {
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    }
    else if([keyPath isEqualToString:@"contentSize"])
    {
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
    else if([keyPath isEqualToString:@"frame"])
    {
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}
- (void)scrollViewDidScroll:(CGPoint)contentOffset
{
    static double prevProgress;
    CGFloat yOffset = contentOffset.y;
    self.progress = ((yOffset+ self.originalTopInset + StartPosition)/-self.progressThreshold);
    self.center = CGPointMake(self.center.x, (contentOffset.y+ self.originalTopInset)/2);
    
    switch (_state) {
        case UZYSPullToRefreshStateStopped: //finish
            break;
        case UZYSPullToRefreshStateNone: //detect action
        {
            if(self.scrollView.isDragging && yOffset <0 )
            {
                self.state = UZYSPullToRefreshStateTriggering;
            }
        }
        case UZYSPullToRefreshStateTriggering: //progress
        {
            if(self.progress >= 1.0)
                self.state = UZYSPullToRefreshStateTriggered;
        }
            break;
        case UZYSPullToRefreshStateTriggered: //fire actionhandler
            if(self.scrollView.dragging == NO && prevProgress > 0.99)
            {
                [self actionTriggeredState];
            }
            break;
        case UZYSPullToRefreshStateLoading: //wait until stopIndicatorAnimation
            break;
        case UZYSPullToRefreshStateCanFinish:
            if(self.progress < 0.01 + ((CGFloat)StartPosition/-self.progressThreshold) && self.progress > -0.01 +((CGFloat)StartPosition/-self.progressThreshold))
            {
                self.state = UZYSPullToRefreshStateNone;
            }

            break;
        default:
            break;
    }
    prevProgress = self.progress;
    
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview && newSuperview == nil) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (scrollView.showPullToRefresh) {
            if (self.isObserving) {
                [scrollView removeObserver:self forKeyPath:@"contentOffset"];
                [scrollView removeObserver:self forKeyPath:@"contentSize"];
                [scrollView removeObserver:self forKeyPath:@"frame"];
                self.isObserving = NO;
            }
        }
    }
}


-(void)actionStopState
{
    self.state = UZYSPullToRefreshStateCanFinish;
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.activityIndicatorView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        self.activityIndicatorView.transform = CGAffineTransformIdentity;
        [self.activityIndicatorView stopAnimating];
        [self resetScrollViewContentInset:^{
            [self setLayerHidden:NO];
            [self setLayerOpacity:1.0];
        } animation:YES];

    }];
}
-(void)actionTriggeredState
{
    self.state = UZYSPullToRefreshStateLoading;
    
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self setLayerOpacity:0.0];
    } completion:^(BOOL finished) {
        [self setLayerHidden:YES];
    }];

    [self.activityIndicatorView startAnimating];
    [self setupScrollViewContentInsetForLoadingIndicator:nil animation:YES];
    if(self.pullToRefreshHandler)
        self.pullToRefreshHandler();
}

#pragma mark - public method
- (void)orientationChange:(UIDeviceOrientation)orientation {
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if((NSInteger)deviceOrientation !=(NSInteger)statusBarOrientation){
        return;
    }
    
    if(UIDeviceOrientationIsLandscape(orientation))
    {
        if(cNotEqualFloats( self.landscapeTopInset , 0.0 , cDefaultFloatComparisonEpsilon))
            self.originalTopInset = self.landscapeTopInset;
    }
    else
    {
        if(cNotEqualFloats( self.portraitTopInset , 0.0 , cDefaultFloatComparisonEpsilon))
            self.originalTopInset = self.portraitTopInset;
    }
    [self setSize:_imageIcon.size];
//    self.frame = CGRectMake((self.scrollView.bounds.size.width - self.bounds.size.width)/2, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height);
    if(self.state == UZYSPullToRefreshStateLoading)
    {
        [self setupScrollViewContentInsetForLoadingIndicator:^{
        } animation:NO];
    }
    else
    {
        [self resetScrollViewContentInset:^{
        } animation:NO];
    }
    self.alpha = 1.0f;
    
    
}

- (void)stopIndicatorAnimation
{
    [self actionStopState];
}
- (void)manuallyTriggered
{
    [self setLayerOpacity:0.0];

    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = self.originalTopInset + self.bounds.size.height + 20.0;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, -currentInsets.top);
    } completion:^(BOOL finished) {
        [self actionTriggeredState];
    }];
}
- (void)setSize:(CGSize) size
{
    CGRect rect = CGRectMake((self.scrollView.bounds.size.width - size.width)/2,
                             -size.height, size.width, size.height);

    self.frame=rect;
    self.shapeLayer.frame = self.bounds;
    self.activityIndicatorView.frame = self.bounds;
    self.imageLayer.frame = CGRectInset(self.bounds, self.borderWidth, self.borderWidth);
    
    self.backgroundLayer.frame = self.bounds;
    [self.backgroundLayer setNeedsDisplay];
}
- (void)setImageIcon:(UIImage *)imageIcon
{
    _imageIcon = imageIcon;
    _imageLayer.contents = (id)_imageIcon.CGImage;
    [self setSize:_imageIcon.size];
}
- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    
    _backgroundLayer.outlineWidth = _borderWidth;
    [_backgroundLayer setNeedsDisplay];
    
    _shapeLayer.lineWidth = _borderWidth;
    _imageLayer.frame = CGRectInset(self.bounds, self.borderWidth, self.borderWidth);

}
- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    _shapeLayer.strokeColor = _borderColor.CGColor;
}
@end