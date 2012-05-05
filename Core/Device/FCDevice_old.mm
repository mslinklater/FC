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

#if 1

#include <sys/types.h>
#include <sys/sysctl.h>

#if TARGET_OS_IPHONE
#import "GameKit/GameKit.h"
#endif

#import "FCCore.h"
#import "FCDevice_old.h"

#import "FCXMLData.h"
#import "FCMaths.h"

#if defined (FC_LUA)
#import "FCLua.h"
#endif

#if TARGET_OS_IPHONE
#import "FCAnalytics.h"
#endif

static FCDevice* s_pDevice;

#pragma mark - Lua Interface

#if defined (FC_LUA)

static int lua_Probe( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	[s_pDevice probe];
	return 0;
}

static int lua_WarmProbe( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	[s_pDevice warmProbe];
	return 0;
}

static int lua_Print( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	[s_pDevice print];
	return 0;
}

static int lua_GetDeviceString( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	NSString* key = [NSString stringWithUTF8String:lua_tostring(_state, 1)];

	NSString* value = [s_pDevice valueForKey:key];

	lua_pushstring(_state, [value UTF8String]);
	
	return 1;
}

static int lua_GetDeviceNumber( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	NSString* key = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	
	FC_ASSERT([[s_pDevice valueForKey:key] isKindOfClass:[NSNumber class]]);
	
	float value = [[s_pDevice valueForKey:key] floatValue];

	lua_pushnumber(_state, value);
	return 1;
}

static int lua_GetGameCenterID( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	lua_pushstring(_state, [s_pDevice.gameCenterID UTF8String]);
	return 1;
}

#endif // defined(FC_LUA)

#pragma mark - Constants


#pragma mark - Implementation

static FCDevice* pInstance;

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
		
#if TARGET_OS_IPHONE
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenRotateResponder:) name:UIDeviceOrientationDidChangeNotification object:nil];
#endif

#if defined (FC_LUA)
//		FCLuaVM* lua = [FCLua instance].coreVM;
		FCLuaVM* lua = FCLua::Instance()->CoreVM();
		
//		[lua createGlobalTable:@"FCDevice"];
		lua->CreateGlobalTable("FCDevice");
//		[lua registerCFunction:lua_Probe as:@"FCDevice.Probe"];
		lua->RegisterCFunction(lua_Probe, "FCDevice.Probe");
//		[lua registerCFunction:lua_WarmProbe as:@"FCDevice.WarmProbe"];
		lua->RegisterCFunction(lua_WarmProbe, "FCDevice.WarmProbe");
//		[lua registerCFunction:lua_Print as:@"FCDevice.Print"];
		lua->RegisterCFunction(lua_Print, "FCDevice.Print");
//		[lua registerCFunction:lua_GetDeviceString as:@"FCDevice.GetString"];
		lua->RegisterCFunction(lua_GetDeviceString, "FCDevice.GetString");
//		[lua registerCFunction:lua_GetDeviceNumber as:@"FCDevice.GetNumber"];
		lua->RegisterCFunction(lua_GetDeviceNumber, "FCDevice.GetNumber");
//		[lua registerCFunction:lua_GetGameCenterID as:@"FCDevice.GetGameCenterID"];
		lua->RegisterCFunction(lua_GetGameCenterID, "FCDevice.GetGameCenterID");
#endif // defined(FC_LUA)
	}
	return self;
}

-(void)dealloc
{
#if TARGET_OS_IPHONE
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
#endif
}

#if TARGET_OS_IPHONE
-(void)screenRotateResponder:(NSNotification*)note
{
	[self getScreenCaps];
}
#endif

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
#if TARGET_OS_IPHONE
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
	
	[_caps setValue:[NSNumber numberWithFloat:scale] forKey:[NSString stringWithUTF8String:kFCDeviceDisplayScale.c_str()]];
	[_caps setValue:[NSNumber numberWithFloat:aspectRatio] forKey:[NSString stringWithUTF8String:kFCDeviceDisplayAspectRatio.c_str()]];
	
	[_caps setValue:[NSNumber numberWithFloat:bounds.size.width] forKey:[NSString stringWithUTF8String:kFCDeviceDisplayLogicalXRes.c_str()]];
	[_caps setValue:[NSNumber numberWithFloat:bounds.size.height] forKey:[NSString stringWithUTF8String:kFCDeviceDisplayLogicalYRes.c_str()]];
	
	[_caps setValue:[NSNumber numberWithFloat:screenSize.width] forKey:[NSString stringWithUTF8String:kFCDeviceDisplayPhysicalXRes.c_str()]];
	[_caps setValue:[NSNumber numberWithFloat:screenSize.height] forKey:[NSString stringWithUTF8String:kFCDeviceDisplayPhysicalYRes.c_str()]];
	
	// work out the the platform designation
	
	if( ((bounds.size.width * scale) == screenSize.width) && ((bounds.size.height * scale) == screenSize.height)) 
	{
		// Native app
		
		if (scale == 2.0)	// retina
		{
			if (bounds.size.width == 320) 
				[_caps setValue:[NSString stringWithUTF8String:kFCDevicePlatformPhoneRetina.c_str()] forKey:[NSString stringWithUTF8String:kFCDevicePlatform.c_str()]];
			else
				[_caps setValue:[NSString stringWithUTF8String:kFCDevicePlatformPadRetina.c_str()] forKey:[NSString stringWithUTF8String:kFCDevicePlatform.c_str()]];				
		}
		else
		{
			if (bounds.size.width == 320) 
				[_caps setValue:[NSString stringWithUTF8String:kFCDevicePlatformPhone.c_str()] forKey:[NSString stringWithUTF8String:kFCDevicePlatform.c_str()]];
			else
				[_caps setValue:[NSString stringWithUTF8String:kFCDevicePlatformPad.c_str()] forKey:[NSString stringWithUTF8String:kFCDevicePlatform.c_str()]];				
		}
	}
	else
	{
		// non-native, so iPhone running on iPad
		
		[_caps setValue:[NSString stringWithUTF8String:kFCDevicePlatformPhoneOnPad.c_str()] forKey:[NSString stringWithUTF8String:kFCDevicePlatform.c_str()]];		
	}
#endif
}

-(void)probe
{	
	// get the OS version...
#if TARGET_OS_IPHONE
	[_caps setValue:[UIDevice currentDevice].systemVersion forKey:[NSString stringWithUTF8String:kFCDeviceOSVersion.c_str()]];

	// OS name

	[_caps setValue:[UIDevice currentDevice].systemName forKey:[NSString stringWithUTF8String:kFCDeviceOSName.c_str()]];

	// name

	[_caps setValue:[UIDevice currentDevice].name forKey:[NSString stringWithUTF8String:kFCDeviceHardwareName.c_str()]];
#endif
	// hardware model ID
	
	[_caps setValue:[self machine] forKey:[NSString stringWithUTF8String:kFCDeviceHardwareModelID.c_str()]];
	
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
		[_caps setValue:[NSString stringWithUTF8String:kFCDeviceTrue.c_str()] forKey:[NSString stringWithUTF8String:kFCDeviceAppPirated.c_str()]];
	} else {
		[_caps setValue:[NSString stringWithUTF8String:kFCDeviceFalse.c_str()] forKey:[NSString stringWithUTF8String:kFCDeviceAppPirated.c_str()]];		
	}
	
	// Locale
	
	NSString* localeCode = [[NSLocale preferredLanguages] objectAtIndex:0];
	[_caps setValue:localeCode forKey:[NSString stringWithUTF8String:kFCDeviceLocale.c_str()]];

	// game center

#if TARGET_OS_IPHONE
//	[[FCAnalytics instance] registerSystemValues];
#endif
	return;
}

-(void)warmProbe
{
	// Signed into game center
	
#if TARGET_OS_IPHONE
	[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) 
	 {
		 if (error == nil)
		 {
			 [_caps setValue:[NSString stringWithUTF8String:kFCDevicePresent.c_str()] forKey:[NSString stringWithUTF8String:kFCDeviceOSGameCenter.c_str()]];
			 _gameCenterID = [[GKLocalPlayer localPlayer] playerID];
		 }
		 else
		 {
			 [_caps setValue:[NSString stringWithUTF8String:kFCDeviceNotPresent.c_str()] forKey:[NSString stringWithUTF8String:kFCDeviceOSGameCenter.c_str()]];
			 _gameCenterID = @"local";
		 }
	 }];
#endif
}

-(void)print
{
	FC_LOG( std::string("Caps: ") + [[self.caps description] UTF8String]);
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
	return [[self.caps valueForKey:key] isEqualToString:[NSString stringWithUTF8String:kFCDevicePresent.c_str()]];	
}

@end

#endif
