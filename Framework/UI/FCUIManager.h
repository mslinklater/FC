/*
 Copyright (C) 2011 by Martin Linklater
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#if TARGET_OS_IPHONE

#import <Foundation/Foundation.h>
#import "FCProtocols.h"
#import "FCUIButtonDef.h"
#import "FCUITable.h"
#import "FCUISwitch.h"
#import "FCUISlider.h"

#ifdef PLATFORM_IPAD
#define UISLOT1Y 80
#define UISLOT2Y 200
#define UISLOT3Y 320
#define UISLOT4Y 440
#define UISLOT5Y 560
#define UISLOT6Y 640
#define UISLOT7Y 720
#else
#define UISLOT1Y 40
#define UISLOT2Y 100
#define UISLOT3Y 160
#define UISLOT4Y 220
#define UISLOT5Y 280
#define UISLOT6Y 340
#define UISLOT7Y 400
#endif


@interface FCUIManager : NSObject {
@private
	NSMutableDictionary* managedViewDictionary;
}

@property(nonatomic, retain) UINavigationController* navigationController;
@property(nonatomic, retain) UIWindow* window;

+(FCUIManager*)instance;

// View management

-(void)addToManagedViews:(UIView*)view withName:(NSString*)name;
-(void)removeFromManagedViews:(NSString*)name;
-(void)removeAllManagedViews;

-(void)hideAllManagedViews;
-(void)unhideAllManagedViews;

-(void)hideAllManagedViewsExcept:(NSSet*)these;

-(UIView*)getManagedView:(NSString*)name;

// Object creation

-(id)objectWithDef:(id)def;	// Factory method

// make these private ?
-(UIButton*)buttonWithDef:(FCUIButtonDef*)def;

-(UITableView*)tableViewWithDef:(FCUITableDef*)def;

-(UISwitch*)switchWithDef:(FCUISwitchDef*)def;

-(UISlider*)sliderWithDef:(FCUISliderDef*)def;

@end

#endif // TARGET_OS_IPHONE
