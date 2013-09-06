//
//  CPColorPicker.m
//  NPColorPicker3
//
//  Created by Nate Parrott on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPColorPicker.h"
#import "CPHueWheel.h"
#import "CPBrightnessSaturationView.h"
#import "SKColorView.h"
#import "RGB-HSV.h"
#import "CPAlphaSlider.h"

@interface CPColorPicker ()

@end

@implementation CPColorPicker
@synthesize callback=_callback;

-(id)init {
    self = [super initWithNibName:@"CPColorPicker" bundle:nil];
    self.title = @"Solid color";
    return self;
}

#pragma mark UI
@synthesize hueWheel=_hueWheel;
@synthesize brightnessSaturationView=_brightnessSaturationView;
@synthesize alphaSlider=_alphaSlider;

-(void)updateControls {
    self.hueWheel.hue = _hue;
    self.brightnessSaturationView.hue = _hue;
    self.brightnessSaturationView.saturation = _sat;
    self.brightnessSaturationView.brightness = _brightness;
    self.alphaSlider.alpha = _alpha;
}

-(void)didUpdateColor {
    _colorView.color = self.color;
    self.alphaSlider.color = [self.color colorWithAlphaComponent:1];
}
-(void)sendCallback {
    if (self.callback)
        self.callback(self.color);
}
#pragma mark View management
-(void)viewDidLoad {
    [super viewDidLoad];
    [self updateControls];
    [self didUpdateColor];
}
-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.hueWheel.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width);
    self.hueWheel.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    self.brightnessSaturationView.frame = CGRectMake(0, 0, self.hueWheel.frame.size.width-(CPColorPickerHueWheelWidth+CPHueWheelInset)*2, self.hueWheel.frame.size.height-(CPColorPickerHueWheelWidth+CPHueWheelInset)*2);
    self.brightnessSaturationView.center = self.hueWheel.center;
    [self layoutSavedColors];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self addSavedColor:self.color];
    [self saveColors];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadSavedColors];
}
#pragma mark Saved colors
-(void)loadSavedColors {
    for (SKColorView* colorView in _savedColorViews) {
        [colorView removeFromSuperview];
    }
    _savedColorViews = [NSMutableArray new];
    _savedColors = nil; // clear in-memory cache of saved colors
    
    for (UIColor* color in [self savedColors]) {
        SKColorView* colorView = [self colorViewForColor:color];
        [_savedColorViews addObject:colorView];
        [_savedColorScrollView addSubview:colorView];
    }
    [self layoutSavedColors];
}
-(SKColorView*)colorViewForColor:(UIColor*)color {
    SKColorView* colorView = [SKColorView new];
    colorView.color = color;
    colorView.clickTarget = self;
    colorView.clickSelector = @selector(clickedSavedColorView:);
    return colorView;
}
-(void)clickedSavedColorView:(SKColorView*)colorView {
    self.color = colorView.color;
    [self sendCallback];
}
-(NSArray*)savedColors {
    if (!_savedColors) {
        _savedColors = [NSMutableArray new];
        NSData* data = [[NSUserDefaults standardUserDefaults] objectForKey:@"SavedColors"];
        if (data) {
            [_savedColors addObjectsFromArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
        } else {
            for (NSString* colorName in [@"blueColor blackColor redColor orangeColor yellowColor greenColor" componentsSeparatedByString:@" "]) {
                [_savedColors addObject:[UIColor performSelector:NSSelectorFromString(colorName)]];
            }
        }
        if ([_savedColors count] > 20) {
            [_savedColors removeObjectsInRange:NSMakeRange(20, _savedColors.count-20)];
        }
    }
    return _savedColors;
}
-(void)removeSavedColor:(UIColor*)color {
    [self savedColors]; // make sure they're loaded
    while ([_savedColors containsObject:color]) {
        int index = [_savedColors indexOfObject:color];
        SKColorView* colorView = [_savedColorViews objectAtIndex:index];
        [colorView removeFromSuperview];
        [_savedColorViews removeObject:colorView];
        [_savedColors removeObjectAtIndex:index];
    }
    [self layoutSavedColors];
}
-(void)addSavedColor:(UIColor*)color {
    [self removeSavedColor:color];
    SKColorView* colorView = [self colorViewForColor:color];
    [_savedColorScrollView addSubview:colorView];
    [_savedColorViews insertObject:colorView atIndex:0];
    [_savedColors insertObject:color atIndex:0];
}
-(void)saveColors {
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_savedColors] forKey:@"SavedColors"];
}
-(void)layoutSavedColors {
    CGFloat colorViewSize = _savedColorScrollView.bounds.size.height*0.8;
    //CGFloat minContentWidth = _savedColorViews.count*(colorViewSize+minColorPadding);
    //CGFloat contentWidth = ceilf(minContentWidth/_savedColorScrollView.bounds.size.width)*_savedColorScrollView.bounds.size.width;
    //CGFloat colorPadding = (contentWidth - (colorViewSize*_savedColorViews.count))/_savedColorViews.count;
    CGFloat padding = 20;
    CGFloat x = 0;
    for (SKColorView* colorView in _savedColorViews) {
        x += padding;
        colorView.frame = CGRectMake(x, (_savedColorScrollView.bounds.size.height-colorViewSize)/2, colorViewSize, colorViewSize);
        x += colorViewSize;
    }
    x += padding;
    _savedColorScrollView.contentSize = CGSizeMake(x, _savedColorScrollView.bounds.size.height);
}
#pragma mark API
-(void)setColor:(UIColor*)color {
    if (!color)
        color = [UIColor grayColor];
    if (![color getHue:&_hue saturation:&_sat brightness:&_brightness alpha:&_alpha]) {
        [color getWhite:&_brightness alpha:&_alpha];
        _hue = 0;
        _sat = 0;
    }
    [self updateControls];
    [self didUpdateColor];
}
-(UIColor*)color {
    return [UIColor colorWithHue:_hue saturation:_sat brightness:_brightness alpha:_alpha];
}
-(void)updateHue:(CGFloat)hue {
    _hue = hue;
    
    _brightness = 1;
    _sat = 1; // for usability
    
    self.brightnessSaturationView.hue = hue;
    self.brightnessSaturationView.saturation = 1;
    self.brightnessSaturationView.brightness = 1;
    [self didUpdateColor];
    [self sendCallback];
}
-(void)updateAlpha:(CGFloat)alpha {
    _alpha = alpha;
    [self didUpdateColor];
    [self sendCallback];
}
-(void)updateBrightness:(CGFloat)brightness andSaturation:(CGFloat)saturation {
    _brightness = brightness;
    _sat = saturation;
    [self didUpdateColor];
    [self sendCallback];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
