//
//  PSViewController.m
//  PlumSourceTextView
//
//  Created by Matt on 10/13/12.
//  Copyright (c) 2012 Matt. All rights reserved.
//

#import "PSViewController.h"

const static NSInteger kHighlightOffset = 20;

@interface PSViewController ()

@property (strong, nonatomic) NSMutableArray *currentSelectionViews;
@property (strong, nonatomic) UITextPosition *startingPosition;
@property (strong, nonatomic) UITextPosition *endPosition;
@property NSInteger offset;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation PSViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    _currentSelectionViews = [[NSMutableArray alloc] init];
  }
  
  return self;
}

- (void)dealloc {
  [self.timer invalidate];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.startingPosition = self.textView.beginningOfDocument;
  self.endPosition = [self.textView positionFromPosition:self.startingPosition offset:kHighlightOffset];
  
  UITextRange *range = [self.textView textRangeFromPosition:self.startingPosition toPosition:self.endPosition];
  NSMutableArray *selectionRanges = [[self.textView selectionRectsForRange:range] mutableCopy];

  [selectionRanges enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    UITextSelectionRect *textSelectionRect = (UITextSelectionRect*)obj;
    CGRect rect = textSelectionRect.rect;
    UIView *view = [self highlightViewWithRect:rect];
    
    [self.textView addSubview:view];
    [self.currentSelectionViews addObject:view];
      
    self.offset += kHighlightOffset;
  }];
  
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
    target:self
    selector:@selector(updateHighlight:)
    userInfo:nil
    repeats:YES];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

// It is probably non-intuitive what I am doing here.  Basically, there is one major problem with text hightlighting:
// the highlight might cover one, two, three or more lines and the number of lines that it covers will change with each
// update.  Each line will need to have its own rectangle.  So how do you animate from, for example, one rectangle to
// two rectangles?  My solution is to animate the position of the *last* rectangle of the previous highlight to the
// the position of the *first* highlight of the next update.  If there are any other other rectangles which need to be
// drawn, I just them when the animation is complete.  This seems to produce a reasonably natural animation effect.

- (void)updateHighlight:(NSTimer*)timer {
  // save the position of the last selection
  CGRect lastSelectionRect = [[self.textView.subviews lastObject] frame];
  
  // remove all of the views from the previous update
  [self.currentSelectionViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [self.currentSelectionViews removeAllObjects];

  // make the end of the previous selection into the start of the next selection
  self.startingPosition = self.endPosition;
  self.endPosition = [self.textView positionFromPosition:self.startingPosition offset:kHighlightOffset];
  
  // get the selection ranges
  UITextRange *range = [self.textView textRangeFromPosition:self.startingPosition toPosition:self.endPosition];
  NSMutableArray *selectionRects = [[self.textView selectionRectsForRange:range] mutableCopy];
  
  // get the frame of the first selection for the next one
  CGRect firstSelectionRect = [[selectionRects objectAtIndex:0] rect];

  NSAssert(selectionRects.count > 0, @"There are no selection ranges");

  // create a view with a frame which is identical to the frame of the last highlighted rectangle of the previous update
  UIView *firstSelectionView = [self highlightViewWithRect:lastSelectionRect];
  
  [self.textView addSubview:firstSelectionView];
  [self.currentSelectionViews addObject:firstSelectionView];
  
  // since we have already drawn the view, remove it from selection rects so we don't draw it twice
  [selectionRects removeObjectAtIndex:0];
  
  [UIView animateWithDuration:0.1f
    animations:^{
      // animate from the previous position to the current position
      firstSelectionView.frame = firstSelectionRect;
    }
    completion:^(BOOL finished) {
      // if there are more selection rects (ie, the highlighting covers multiple lines), draw them now
      [selectionRects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UITextSelectionRect *textSelectionRect = (UITextSelectionRect*)obj;
        CGRect rect = textSelectionRect.rect;
        UIView *view = [self highlightViewWithRect:rect];
        
        [self.textView addSubview:view];
        [self.currentSelectionViews addObject:view];
      
        self.offset += kHighlightOffset;
      }];
    }
  ];
}

- (UIView*)highlightViewWithRect:(CGRect)rect {
  UIView *view = [[UIView alloc] initWithFrame:rect];
  view.backgroundColor = [UIColor yellowColor];
  view.alpha = 0.5f;

  return view;
}

@end
