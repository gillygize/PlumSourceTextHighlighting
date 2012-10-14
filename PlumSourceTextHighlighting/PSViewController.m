//
//  PSViewController.m
//  PlumSourceTextView
//
//  Created by Matt on 10/13/12.
//  Copyright (c) 2012 Matt. All rights reserved.
//

#import "PSViewController.h"

@interface PSViewController ()

@property (strong, nonatomic) NSMutableArray *currentSelectionViews;
@property (strong, nonatomic) UITextPosition *startingPosition;
@property (strong, nonatomic) UITextPosition *endPosition;
@property NSInteger offset;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation PSViewController

- (void)dealloc {
  [self.timer invalidate];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
    target:self
    selector:@selector(updateHighlight:)
    userInfo:nil
    repeats:YES];
  
  self.startingPosition = self.textView.beginningOfDocument;
  self.endPosition = [self.textView positionFromPosition:self.startingPosition offset:20];
  self.currentSelectionViews = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

- (void)updateHighlight:(NSTimer*)timer {
  CGRect lastSelectionRect = [[self.currentSelectionViews lastObject] frame];
  [self.currentSelectionViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [self.currentSelectionViews removeAllObjects];

  self.startingPosition = self.endPosition;
  self.endPosition = [self.textView positionFromPosition:self.startingPosition offset:20];
  UITextRange *range = [self.textView textRangeFromPosition:self.startingPosition toPosition:self.endPosition];
  NSArray *selectionRanges = [[self.textView selectionRectsForRange:range] mutableCopy];

  CGRect firstSelectionRect = [[selectionRanges objectAtIndex:0] rect];
  
  UIView *firstSelectionView = [[UIView alloc] initWithFrame:lastSelectionRect];
  firstSelectionView.backgroundColor = [UIColor yellowColor];
  firstSelectionView.alpha = 0.5f;
  [self.textView addSubview:firstSelectionView];
  [self.currentSelectionViews addObject:firstSelectionView];
  
  [UIView animateWithDuration:0.1f
    animations:^{
      firstSelectionView.frame = firstSelectionRect;
    } completion:^(BOOL finished) {
      [selectionRanges enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      UITextSelectionRect *textSelectionRect = (UITextSelectionRect*)obj;
      CGRect rect = textSelectionRect.rect;
      UIView *view = [[UIView alloc] initWithFrame:rect];
      view.backgroundColor = [UIColor yellowColor];
      view.alpha = 0.5f;
      [self.textView addSubview:view];
      [self.currentSelectionViews addObject:view];
    
      self.offset += 5;
    }];
  }];
}

@end
