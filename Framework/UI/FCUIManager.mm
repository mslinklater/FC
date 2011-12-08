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

#import "FCUIManager.h"
#import "FCAppContext.h"
#import "FCResourceManager.h"

//----------------------------------------------------------------------------------------------------------------------

@implementation FCUIManager

@synthesize navigationController = _navigationController;
@synthesize window=_window;

- (void)setWindow:(UIWindow*)window
{
	_window = window;
}

#pragma mark - FCSingleton

+(id)instance
{
	static FCUIManager* pInstance;
	if (!pInstance) {
		pInstance = [[FCUIManager alloc] init];
	}
	return pInstance;
}

#pragma mark - Lifetime

-(id)init
{
	self = [super init];
	if (self) {
		// print out font names
		
		managedViewDictionary = [[NSMutableDictionary alloc] init];
	}
	return self;
}


#pragma mark - View Management

-(UIView*)getManagedView:(NSString *)name
{
	return [managedViewDictionary valueForKey:name];
}

-(void)addToManagedViews:(UIView *)view withName:(NSString *)name
{
	NSAssert1( [managedViewDictionary valueForKey:name] == nil, @"View already managed - %@", name );
	
	[managedViewDictionary setObject:view forKey:name];
}

-(void)removeFromManagedViews:(NSString *)name
{
	NSAssert1([managedViewDictionary valueForKey:name], @"%@ not present in managed dictionary", name);
	
	[managedViewDictionary removeObjectForKey:name];
}

-(void)removeAllManagedViews
{
	[managedViewDictionary removeAllObjects];
}

-(void)hideAllManagedViews
{
	for( UIView* thisView in managedViewDictionary )
	{
		thisView.hidden = YES;
	}		
}

-(void)unhideAllManagedViews
{
	for( UIView* thisView in managedViewDictionary )
	{
		thisView.hidden = NO;
	}			
}

-(void)hideAllManagedViewsExcept:(NSSet *)these
{
#if defined (DEBUG)
	NSString* theseKey;
	
	for(theseKey in these)
	{
		NSAssert1([managedViewDictionary valueForKey:theseKey], @"hideAllManagedViewsExcept: Unknown view name %@", theseKey);
	}
#endif
	
	NSString* key;
	
	for(key in managedViewDictionary)
	{
		if ([these containsObject:key]) 
		{
			[[managedViewDictionary valueForKey:key] setHidden:NO];
		}
		else
		{
			[[managedViewDictionary valueForKey:key] setHidden:YES];			
		}
	}
}

#pragma mark - UI Object factory methods

-(id)objectWithDef:(id)def
{
	if ([def isKindOfClass:[FCUIButtonDef class]]) {
		return [self buttonWithDef:def];
	}
	else if ([def isKindOfClass:[FCUITableDef class]]) {
		return [self tableViewWithDef:def];
	}
	else if ([def isKindOfClass:[FCUISwitchDef class]]) {
		return [self switchWithDef:def];
	}
	else if ([def isKindOfClass:[FCUISliderDef class]]) {
		return [self sliderWithDef:def];
	}
	
	NSAssert1(nil, @"unknown def type %@", [def class]);
	
	return nil;
}

-(UIButton*)buttonWithDef:(FCUIButtonDef*)def
{
	UIImage* buttonImage = [UIImage imageWithData:[[FCResourceManager instance] dataForResource:def.defaultImage ofType:@"png"]];
	UIImage* buttonImage2 = nil;
	if (def.pressedImage) 
	{
		buttonImage2 = [UIImage imageWithData:[[FCResourceManager instance] dataForResource:def.pressedImage ofType:@"png"]];
	}

	CGRect buttonRect;
	CGFloat scale = [UIScreen mainScreen].scale;	

	
	if (def.width) {
		buttonRect.size.width = def.width;
		buttonRect.origin.x = def.center.x - ((def.width) * 0.5f);
	} else {
		buttonRect.size.width = buttonImage.size.width / scale;
		buttonRect.origin.x = def.center.x - ((buttonImage.size.width / scale) * 0.5f);
	}

	if (def.height) {
		buttonRect.size.height = def.height;
		buttonRect.origin.y = def.center.y - ((def.height / scale) * 0.5f);
	} else {
		buttonRect.size.height = buttonImage.size.height / scale;		
		buttonRect.origin.y = def.center.y - ((buttonImage.size.height / scale) * 0.5f);
	}

	UIButton* button = [[UIButton alloc] initWithFrame:buttonRect];
	[button setBackgroundImage:buttonImage forState:UIControlStateNormal];
	
	if (buttonImage2) 
	{
		[button setBackgroundImage:buttonImage2 forState:UIControlStateHighlighted];
	}
	
	[button addTarget:def.target action:def.action forControlEvents:UIControlEventTouchUpInside ];
	
	if (def.text) 
	{
		[button setTitle:NSLocalizedString(def.text, nil) forState:UIControlStateNormal];
		if (def.font && (def.fontSize > 0)) 
		{
			button.titleLabel.font = [UIFont fontWithName:def.font size:def.fontSize];
		}
	}
	
	[button setHidden:def.hidden];
	[def.parentView addSubview:button];

	return button;
}

-(UITableView*)tableViewWithDef:(FCUITableDef*)def
{
	// Validation ? Against protocol
	
	NSAssert([def.delegateAndDataSource conformsToProtocol:@protocol(UITableViewDataSource)] &&
		 [def.delegateAndDataSource conformsToProtocol:@protocol(UITableViewDelegate)],
			 @"FCUIManager:tableViewWithDef - does not support table delegates"); 
	
	NSAssert(def.parentView != nil, @"nil parentView");
	
	UITableView* newTable = [[UITableView alloc] initWithFrame:def.rect style:UITableViewStylePlain];
	newTable.delegate = def.delegateAndDataSource;
	newTable.dataSource = def.delegateAndDataSource;
	newTable.bounces = YES;
	newTable.backgroundColor = def.color;
	newTable.separatorStyle = UITableViewCellSeparatorStyleNone;
	[def.parentView addSubview:newTable];
	return newTable;
}

-(UISwitch*)switchWithDef:(FCUISwitchDef*)def
{
	// validation
	
	NSAssert([def.target respondsToSelector:def.action], @"target does not respond to selector"); 
	
	NSAssert([[NSUserDefaults standardUserDefaults] objectForKey:def.userDefaultsID], @"user default does not exist");
	
	// build the UI
	UISwitch* newSwitch = [[UISwitch alloc] initWithFrame:def.rect];
	
	// check for default state
		
	[newSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:def.userDefaultsID] animated:NO];
	[def.parentView addSubview:newSwitch];
	[newSwitch addTarget:def.target action:def.action forControlEvents:UIControlEventValueChanged];
	
	// add label
	
	CGRect switchBounds = newSwitch.bounds;
	float switchSize = switchBounds.size.width;
	float labelSize = def.rect.size.width - switchSize;
	CGRect labelRect = CGRectMake(def.rect.origin.x + switchSize,
								  def.rect.origin.y,
								  labelSize,
								  switchBounds.size.height);
	
	UILabel* newLabel = [[UILabel alloc] initWithFrame:labelRect];
	[def.parentView addSubview:newLabel];
	newLabel.text = NSLocalizedString(def.textString, nil);
	newLabel.textAlignment = UITextAlignmentRight;
	newLabel.backgroundColor = [UIColor clearColor];
	
	return newSwitch;
}

-(UISlider*)sliderWithDef:(FCUISliderDef*)def
{
	// validation
	
	NSAssert([def.target respondsToSelector:def.action], @"does not respond to selector" );
	
	NSAssert1([[NSUserDefaults standardUserDefaults] objectForKey:def.userDefaultsID], @"No such user default %@", def.userDefaultsID);

	// build the UI
	
	CGRect sliderRect = def.rect;
	sliderRect.size.width = sliderRect.size.width / 2;
	
	UISlider* newSlider = [[UISlider alloc] initWithFrame:sliderRect];
	[newSlider addTarget:def.target action:def.action forControlEvents:UIControlEventValueChanged];
	[def.parentView addSubview:newSlider];
	newSlider.minimumValue = 0.0f;
	newSlider.maximumValue = 1.0f;
	newSlider.value = [[NSUserDefaults standardUserDefaults] floatForKey:def.userDefaultsID];

// text label

	CGRect labelRect = sliderRect;
	labelRect.size.height = newSlider.frame.size.height;
	labelRect.origin.x += labelRect.size.width;
	UILabel* newLabel = [[UILabel alloc] initWithFrame:labelRect];
	[def.parentView addSubview:newLabel];
	[newLabel setTextAlignment:UITextAlignmentRight];
	newLabel.text = NSLocalizedString(def.textString, nil);
	newLabel.backgroundColor = [UIColor clearColor];
	
	return newSlider;
}

@end

#endif // TARGET_OS_IPHONE
