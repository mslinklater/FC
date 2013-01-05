/*
 Copyright (C) 2011-2012 by Martin Linklater
 
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

#import "GameKit/GameKit.h"

#import "FCDevice_apple.h"

#include "Shared/Core/FCCore.h"
#include "Shared/Core/Device/FCDevice.h"

#include <sstream>

#pragma mark - plt Interface

void plt_FCDevice_ColdProbe();
void plt_FCDevice_WarmProbe();

void plt_FCDevice_ColdProbe()
{
	[[FCDevice_apple instance] coldBoot];
}

void plt_FCDevice_WarmProbe( uint32_t options )
{
	[[FCDevice_apple instance] warmBoot:options];
}

#pragma mark - Objective-C class

@implementation FCDevice_apple

+(FCDevice_apple*)instance
{
	static FCDevice_apple* s_pInstance = 0;
	if (!s_pInstance) {
		s_pInstance = [[FCDevice_apple alloc] init];
	}
	return s_pInstance;
}

-(id)init
{
	self = [super init];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenRotateResponder:) name:UIDeviceOrientationDidChangeNotification object:nil];
	}
	return self;
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)screenRotateResponder:(NSNotification*)note
{
	[self getScreenCaps];
}

-(void)getScreenCaps
{
	CGFloat scale = [UIScreen mainScreen].scale;
	CGRect bounds = [UIScreen mainScreen].bounds;
	CGSize screenSize = [UIScreen mainScreen].currentMode.size;
	CGFloat aspectRatio = bounds.size.width / bounds.size.height;
	
	// bounds are always reported for portrait, so do some swapping if landscape
	
	if (UIDeviceOrientationIsLandscape( [UIDevice currentDevice].orientation ) && (m_warmBootOptions & kFCInterfaceOrientation_Landscape))
	{
		float temp = bounds.size.height;
		bounds.size.height = bounds.size.width;
		bounds.size.width = temp;
	}
	
	if (UIDeviceOrientationIsPortrait( [UIDevice currentDevice].orientation ) && (m_warmBootOptions & kFCInterfaceOrientation_Portrait))
	{
		float temp = screenSize.height;
		screenSize.height = screenSize.width;
		screenSize.width = temp;
	}

	std::stringstream ss;
	
	ss << scale;
	FCDevice::Instance()->SetCap(kFCDeviceDisplayScale, ss.str());
	
	ss.str("");
	ss << aspectRatio;
	FCDevice::Instance()->SetCap(kFCDeviceDisplayAspectRatio, ss.str());
	
	ss.str("");
	ss << bounds.size.width;
	FCDevice::Instance()->SetCap(kFCDeviceDisplayLogicalXRes, ss.str());
	
	ss.str("");
	ss << bounds.size.height;
	FCDevice::Instance()->SetCap(kFCDeviceDisplayLogicalYRes, ss.str());

	ss.str("");
	ss << screenSize.width;
	FCDevice::Instance()->SetCap(kFCDeviceDisplayPhysicalXRes, ss.str());

	ss.str("");
	ss << screenSize.height;
	FCDevice::Instance()->SetCap(kFCDeviceDisplayPhysicalYRes, ss.str());	
}

-(void)coldBoot
{
	std::stringstream ss;
	
	FCDevice::Instance()->SetCap(kFCDeviceOSVersion, [[UIDevice currentDevice].systemVersion UTF8String]);
	FCDevice::Instance()->SetCap(kFCDeviceOSName, [[UIDevice currentDevice].systemName UTF8String]);
	FCDevice::Instance()->SetCap(kFCDeviceHardwareName, [[UIDevice currentDevice].name UTF8String]);
	FCDevice::Instance()->SetCap(kFCDeviceHardwareModel, [[UIDevice currentDevice].model UTF8String]);
	
	// Pirated
	
	if ([[[NSBundle mainBundle] infoDictionary] objectForKey: @"SignerIdentity"] == nil) 
	{
		FCDevice::Instance()->SetCap(kFCDeviceAppPirated, kFCDeviceTrue);
	} 
	else 
	{
		FCDevice::Instance()->SetCap(kFCDeviceAppPirated, kFCDeviceFalse);
	}
}

-(void)warmBoot:(uint32_t)options
{
	m_warmBootOptions = options;
	
	[self getScreenCaps];
	
	NSString* localeCode = [[NSLocale preferredLanguages] objectAtIndex:0];
	FCDevice::Instance()->SetCap(kFCDeviceLocale, [localeCode UTF8String]);

	[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) 
	 {
		 if (error == nil)
		 {
			 FCDevice::Instance()->SetCap(kFCDeviceOSGameCenter, kFCDevicePresent);
			 FCDevice::Instance()->SetCap(kFCDeviceGameCenterID, [[[GKLocalPlayer localPlayer] playerID] UTF8String]);
		 }
		 else
		 {
			 FCDevice::Instance()->SetCap(kFCDeviceOSGameCenter, kFCDeviceNotPresent);
			 FCDevice::Instance()->SetCap(kFCDeviceGameCenterID, "local");
		 }
	 }];
}

@end
