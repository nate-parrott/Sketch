//
//  SKAppDelegate.h
//  Sketch
//
//  Created by Nate Parrott on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


/*
 TODO
 =========
 -retina images
 -tiling bug
 -open new docs in pen mode?
 
 FEATURES TO ADD
 ================
 -shadows
 -rotation
 -better color picker/saved colors/eyedropper control
 -line styles
 */

#import <UIKit/UIKit.h>

#import "SKStyledButton.h"
#import "SKSpecialNavigationController.h"
#define TITLE_COLOR [UIColor colorWithRed:0.808 green:0.184 blue:0.171 alpha:1.000]
#define TEXTURED_BACKGROUND_COLOR [UIColor colorWithPatternImage:[UIImage imageNamed:@"tinyGrid"]]//[UIColor colorWithPatternImage:[UIImage imageNamed:@"lfelt"]]
#define DARK_BACKGROUND [UIColor colorWithRed:0.417 green:0.421 blue:0.392 alpha:1.000]
#define LIGHT_BACKGROUND [UIColor colorWithRed:0.983 green:0.996 blue:0.915 alpha:1.000]
#define OFF_LIGHT [UIColor colorWithRed:0.867 green:0.835 blue:0.689 alpha:1.000]
#define BACKGROUND_COLOR [UIColor colorWithRed:0.850 green:0.864 blue:0.886 alpha:1.000] //[UIColor colorWithRed:0.684 green:0.693 blue:0.640 alpha:1.000]

#define SKDocumentThumbnailMaxDimension 300

extern const NSString* SKAppDelegateShouldSaveData;
extern const NSString* SKAppDelegateDidGainFocus;

@interface SKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
