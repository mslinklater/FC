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

#if TARGET_OS_IPHONE

#include <sys/types.h>
#include <sys/sysctl.h>
#import "GameKit/GameKit.h"

#import "FCCore.h"
#import "FCDevice.h"

#import "FCXMLData.h"
#import "FCMaths.h"
#import "FCLua.h"
#import "FCAnalytics.h"

static FCDevice* s_pDevice;

#pragma mark - Lua Interface

static int lua_Probe( lua_State* _state )
{
	FC_ASSERT(lua_gettop(_state) == 0);
	[s_pDevice probe];
	return 0;
}

static int lua_WarmProbe( lua_State* _state )
{
	FC_ASSERT(lua_gettop(_state) == 0);
	[s_pDevice warmProbe];
	return 0;
}

static int lua_Print( lua_State* _state )
{
	FC_ASSERT(lua_gettop(_state) == 0);
	[s_pDevice print];
	return 0;
}

static int lua_GetDeviceString( lua_State* _state )
{
	FC_ASSERT(lua_gettop(_state) == 1);
	FC_ASSERT(lua_isstring(_state, 1));
	
	NSString* key = [NSString stringWithUTF8String:lua_tostring(_state, 1)];

	NSString* value = [s_pDevice valueForKey:key];

	lua_pushstring(_state, [value UTF8String]);
	
	return 1;
}

static int lua_GetDeviceNumber( lua_State* _state )
{
	FC_ASSERT(lua_gettop(_state) == 1);
	FC_ASSERT(lua_isstring(_state, 1));
	
	NSString* key = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	
	FC_ASSERT([[s_pDevice valueForKey:key] isKindOfClass:[NSNumber class]]);
	
	float value = [[s_pDevice valueForKey:key] floatValue];

	lua_pushnumber(_state, value);
	return 1;
}

static int lua_GetGameCenterID( lua_State* _state )
{
	lua_pushstring(_state, [s_pDevice.gameCenterID UTF8String]);
	return 1;
}

#pragma mark - Constants

NSString* kFCDeviceTrue = @"true";
NSString* kFCDeviceFalse = @"false";

NSString* kFCDevicePresent = @"present";
NSString* kFCDeviceNotPresent = @"not present";
NSString* kFCDeviceUnknown = @"unknown";

NSString* kFCDevicePlatformPhone = @"platform_iphone";
NSString* kFCDevicePlatformPhoneRetina = @"platform_iphone_retina";
NSString* kFCDevicePlatformPhoneOnPad = @"platform_iphone_on_ipad";
NSString* kFCDevicePlatformPad = @"platform_ipad";
NSString* kFCDevicePlatformPadRetina = @"platform_ipad_retina";

//------- keys

NSString* kFCDeviceDisplayAspectRatio = @"display_aspect_ratio";
NSString* kFCDeviceDisplayLogicalXRes = @"display_logical_xres";
NSString* kFCDeviceDisplayLogicalYRes = @"display_logical_yres";
NSString* kFCDeviceDisplayPhysicalXRes = @"display_physical_xres";
NSString* kFCDeviceDisplayPhysicalYRes = @"display_physical_yres";
NSString* kFCDeviceDisplayScale = @"display_scale";

NSString* kFCDeviceHardwareModelID = @"hardware_model_id";
NSString* kFCDeviceHardwareModel = @"hardware_model";
NSString* kFCDeviceHardwareUDID = @"hardware_udid";
NSString* kFCDeviceHardwareName = @"hardware_name";

NSString* kFCDeviceLocale = @"locale";

NSString* kFCDeviceOSVersion = @"os_version";
NSString* kFCDeviceOSName = @"os_name";
NSString* kFCDeviceOSGameCenter = @"os_gamecenter";

NSString* kFCDevicePlatform = @"platform";

NSString* kFCDeviceSimulator = @"simulator";

NSString* kFCDeviceAppPirated = @"pirated";

#pragma mark - Implementation

static FCDevice* pInstance;

//@interface FCDevice() {
////	FCLuaVM* _luaVM;
//}
////@property(nonatomic, strong) FCLuaVM* luaVM;
//@end

@implementation FCDevice

@synthesize caps = _caps;
@synthesize gameCenterID = _gameCenterID;

#pragma mark - Singleton

+(FCDevice*)instance
{
	if (!s_pDevice) {
		s_pDevice = [[FCDevice alloc] init];
	}
	return s_pDevice;
}

#pragma mark - Object Lifetime

-(id)init
{
	self = [super init];
	if (self) {
		_caps = [[NSMutableDictionary alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenRotateResponder:) name:UIDeviceOrientationDidChangeNotification object:nil];

		FCLuaVM* lua = [FCLua instance].coreVM;
		
		[lua createGlobalTable:@"FCDevice"];
		[lua registerCFunction:lua_Probe as:@"FCDevice.Probe"];
		[lua registerCFunction:lua_WarmProbe as:@"FCDevice.WarmProbe"];
		[lua registerCFunction:lua_Print as:@"FCDevice.Print"];
		[lua registerCFunction:lua_GetDeviceString as:@"FCDevice.GetString"];
		[lua registerCFunction:lua_GetDeviceNumber as:@"FCDevice.GetNumber"];
		[lua registerCFunction:lua_GetGameCenterID as:@"FCDevice.GetGameCenterID"];
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

#pragma mark - Misc

- (NSString *)machine
{
	size_t size = 0;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0); 
	char *name = (char*)malloc(size);
	sysctlbyname("hw.machine", name, &size, NULL, 0);
	NSString *machine = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
	free(name);
	
	return machine;
}

- (NSString *)model
{
	size_t size = 0;
	sysctlbyname("hw.model", NULL, &size, NULL, 0); 
	char *name = (char*)malloc(size);
	sysctlbyname("hw.model", name, &size, NULL, 0);
	NSString *model = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
	free(name);
	
	return model;
}

- (NSString *)machinearch
{
	size_t size = 0;
	sysctlbyname("hw.machine_arch", NULL, &size, NULL, 0); 
	char *name = (char*)malloc(size);
	sysctlbyname("hw.machine_arch", name, &size, NULL, 0);
	NSString *arch = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
	free(name);
	
	return arch;
}

- (int)numcpu
{
	int	numcpu;
	size_t size = sizeof(numcpu);
	sysctlbyname("hw.ncpu", &numcpu, &size, NULL, 0);	
	return numcpu;
}

- (int)byteorder
{
	int	byteorder;
	size_t size = sizeof(byteorder);
	sysctlbyname("hw.byteorder", &byteorder, &size, NULL, 0);	
	return byteorder;
}

- (long long)memsize
{
	long long	memsize;
	size_t size = sizeof(memsize);
	sysctlbyname("hw.memsize", &memsize, &size, NULL, 0);	
	return memsize;
}

- (int)pagesize
{
	int	pagesize;
	size_t size = sizeof(pagesize);
	sysctlbyname("hw.pagesize", &pagesize, &size, NULL, 0);	
	return pagesize;
}

-(void)getScreenCaps
{
	CGFloat scale = [UIScreen mainScreen].scale;
	CGRect bounds = [UIScreen mainScreen].bounds;
	CGSize screenSize = [UIScreen mainScreen].currentMode.size;
	CGFloat aspectRatio = [UIScreen mainScreen].currentMode.pixelAspectRatio;
	
	// bounds are always reported for portrait, so do some swapping if landscape

	if (UIDeviceOrientationIsLandscape( [UIDevice currentDevice].orientation )) 
	{
		float temp = bounds.size.height;
		bounds.size.height = bounds.size.width;
		bounds.size.width = temp;
	}

	if (UIDeviceOrientationIsPortrait( [UIDevice currentDevice].orientation )) 
	{
		float temp = screenSize.height;
		screenSize.height = screenSize.width;
		screenSize.width = temp;
	}

	// push values into caps
	
	[_caps setValue:[NSNumber numberWithFloat:scale] forKey:kFCDeviceDisplayScale];
	[_caps setValue:[NSNumber numberWithFloat:aspectRatio] forKey:kFCDeviceDisplayAspectRatio];
	
	[_caps setValue:[NSNumber numberWithFloat:bounds.size.width] forKey:kFCDeviceDisplayLogicalXRes];
	[_caps setValue:[NSNumber numberWithFloat:bounds.size.height] forKey:kFCDeviceDisplayLogicalYRes];
	
	[_caps setValue:[NSNumber numberWithFloat:screenSize.width] forKey:kFCDeviceDisplayPhysicalXRes];
	[_caps setValue:[NSNumber numberWithFloat:screenSize.height] forKey:kFCDeviceDisplayPhysicalYRes];
	
	// work out the the platform designation
	
	if( ((bounds.size.width * scale) == screenSize.width) && ((bounds.size.height * scale) == screenSize.height)) 
	{
		// Native app
		
		if (scale == 2.0)	// retina
		{
			if (bounds.size.width == 320) 
				[_caps setValue:kFCDevicePlatformPhoneRetina forKey:kFCDevicePlatform];
			else
				[_caps setValue:kFCDevicePlatformPadRetina forKey:kFCDevicePlatform];				
		}
		else
		{
			if (bounds.size.width == 320) 
				[_caps setValue:kFCDevicePlatformPhone forKey:kFCDevicePlatform];
			else
				[_caps setValue:kFCDevicePlatformPad forKey:kFCDevicePlatform];				
		}
	}
	else
	{
		// non-native, so iPhone running on iPad
		
		[_caps setValue:kFCDevicePlatformPhoneOnPad forKey:kFCDevicePlatform];		
	}
}

-(void)probe
{	
	// get the OS version...
	
	[_caps setValue:[UIDevice currentDevice].systemVersion forKey:kFCDeviceOSVersion];

	// OS name

	[_caps setValue:[UIDevice currentDevice].systemName forKey:kFCDeviceOSName];

	// name

	[_caps setValue:[UIDevice currentDevice].name forKey:kFCDeviceHardwareName];

	// hardware model ID
	
	[_caps setValue:[self machine] forKey:kFCDeviceHardwareModelID];
	
	// Check for frameworks
	
	// display caps

	[self getScreenCaps];
	
	
	// Now for some lower level stuff
	
	[_caps setValue:[self model] forKey:@"modelid"];
	[_caps setValue:[self machinearch] forKey:@"machinearch"];
	[_caps setValue:[NSNumber numberWithInt:[self numcpu]] forKey:@"numcpu"];
	[_caps setValue:[NSNumber numberWithInt:[self byteorder]] forKey:@"byteorder"];
	[_caps setValue:[NSNumber numberWithLongLong:[self memsize]] forKey:@"memsize"];
	[_caps setValue:[NSNumber numberWithInt:[self pagesize]] forKey:@"pagesize"];

	// detect if pirated ?

	if ([[[NSBundle mainBundle] infoDictionary] objectForKey: @"SignerIdentity"] == nil) {
		[_caps setValue:kFCDeviceTrue forKey:kFCDeviceAppPirated];
	} else {
		[_caps setValue:kFCDeviceFalse forKey:kFCDeviceAppPirated];		
	}
	
	// Locale
	
	NSString* localeCode = [[NSLocale preferredLanguages] objectAtIndex:0];
	[_caps setValue:localeCode forKey:kFCDeviceLocale];

	// game center
		
	[[FCAnalytics instance] registerSystemValues];

	return;
}

-(void)warmProbe
{
	// Singed into game center
	
	[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) 
	 {
		 if (error == nil)
		 {
			 [_caps setValue:kFCDevicePresent forKey:kFCDeviceOSGameCenter];
			 _gameCenterID = [[GKLocalPlayer localPlayer] playerID];
		 }
		 else
		 {
			 [_caps setValue:kFCDeviceNotPresent forKey:kFCDeviceOSGameCenter];
			 _gameCenterID = @"local";
		 }
	 }];
}

-(void)print
{
	FC_LOG1(@"Caps - %@", self.caps);
}

-(id)valueForKey:(NSString *)key
{
	return [self.caps valueForKey:key];
}

-(BOOL)valueForKey:(NSString*)key equalTo:(NSString*)key2
{
	return [[self.caps valueForKey:key] isEqualToString:key2];
}

-(BOOL)isPresent:(NSString*)key
{
	return [[self.caps valueForKey:key] isEqualToString:kFCDevicePresent];	
}

@end

#endif // TARGET_OS_IPHONE
