//
//  PSAppDelegate.h
//  PlumSourceTextView
//
//  Created by Matt on 10/13/12.
//  Copyright (c) 2012 Matt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSViewController;

@interface PSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) PSViewController *viewController;

@end
