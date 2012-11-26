//
//  UITextView+Lined.m
//  LinedTextViewDemo
//
//  Created by yebw on 12-11-26.
//  Copyright (c) 2012年 yebw. All rights reserved.
//

#import "MFUnderlinedTextView.h"

@interface MFUnderlinesView : UIView

@property(nonatomic, retain) UIColor    *underlineColor;
@property(nonatomic, retain) UIFont     *textFont;

@end

@implementation MFUnderlinesView

@synthesize underlineColor;
@synthesize textFont;

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    if (self.underlineColor == nil)
    {
        self.underlineColor = [UIColor colorWithRed:182.f/256.f green:166.f/256.f blue:150.f/256.f alpha:1.f];
    }

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetStrokeColorWithColor(context, self.underlineColor.CGColor);
    CGContextSetLineWidth(context, 1.0f);
    CGContextBeginPath(context);
    
    NSUInteger numberOfLines = self.bounds.size.height / textFont.leading;

    //Set the line offset from the baseline. (I'm not sure there's a concrete way to calculate this.)
    CGFloat baselineOffset = 6.0f;

    //iterate over numberOfLines and draw each line
    for (int x = 1; x < numberOfLines; x++)
    {
        //0.5f offset lines up line with pixel boundary
        CGContextMoveToPoint(context, self.bounds.origin.x, textFont.leading*x + 0.5f + baselineOffset);
        CGContextAddLineToPoint(context, self.bounds.size.width, textFont.leading*x + 0.5f + baselineOffset);
    }

    CGContextClosePath(context);
    CGContextStrokePath(context);
}

- (void)dealloc
{
    [textFont release];
    [underlineColor release];
    
    [super dealloc];
}

@end

@interface MFUnderlinedTextView()

@property(nonatomic, retain) MFUnderlinesView *underlinesView;

@end

@implementation MFUnderlinedTextView

@synthesize underlineColor;
@synthesize underlinesView;

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (underlinesView == nil)
    {
        underlinesView = [[MFUnderlinesView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.bounds.size.width, self.contentSize.height + self.bounds.size.height)];
        [underlinesView setUserInteractionEnabled:NO];
        [underlinesView.layer setOpaque:NO];
        [underlinesView setOpaque:NO];

        [underlinesView setUnderlineColor:underlineColor];
        [underlinesView setTextFont:self.font];

        [self startObservingChanges];
    }

    if (underlinesView.superview == nil)
    {
        [self insertSubview:underlinesView atIndex:0];
    }
}

- (void)dealloc
{
    [self stopObservingChanges];
    
    self.underlineColor = nil;
    self.underlinesView = nil;

    [super dealloc];
}

#pragma mark - KVO

static int kObservingContentSizeChangesContext;
static int kObservingFontChangesContext;
static int kObservingUnderlineColorChangesContext;

- (void)startObservingChanges
{
    [self addObserver:self forKeyPath:@"contentSize" options:0 context:&kObservingContentSizeChangesContext];
    [self addObserver:self forKeyPath:@"font" options:0 context:&kObservingFontChangesContext];
    [self addObserver:self forKeyPath:@"underlineColor" options:0 context:&kObservingUnderlineColorChangesContext];
}

- (void)stopObservingChanges
{
    [self removeObserver:self forKeyPath:@"contentSize" context:&kObservingContentSizeChangesContext];
    [self removeObserver:self forKeyPath:@"font" context:&kObservingFontChangesContext];
    [self removeObserver:self forKeyPath:@"underlineColor" context:&kObservingUnderlineColorChangesContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == &kObservingContentSizeChangesContext)
    {
        if ((self.contentSize.height>self.bounds.size.height && self.contentSize.height!=underlinesView.bounds.size.height)
            || self.contentSize.width != underlinesView.bounds.size.width)
        {
            CGSize size = CGSizeMake(self.bounds.size.width, self.bounds.size.height+self.contentSize.height);
            
            [underlinesView setFrame:CGRectMake(0.f, 0.f, size.width, size.height)];
            [underlinesView setNeedsDisplay];
        }
    }
    else if (context == &kObservingFontChangesContext)
    {
        [underlinesView setTextFont:self.font];
        [underlinesView setNeedsDisplay];
    }
    else if (context == &kObservingUnderlineColorChangesContext)
    {
        [underlinesView setUnderlineColor:underlineColor];
        [underlinesView setNeedsDisplay];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


@end
