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

#include <sys/types.h>
#include <sys/sysctl.h>

#import "FCCore.h"
#import "FCCaps.h"

#import "FCXMLData.h"
#import "FCMaths.h"

#pragma mark - Constants

NSString* kFCCapsTrue = @"true";
NSString* kFCCapsFalse = @"false";

NSString* kFCCapsPresent = @"present";
NSString* kFCCapsNotPresent = @"not present";
NSString* kFCCapsUnknown = @"unknown";

NSString* kFCCapsPlatformPhone = @"platform_iphone";
NSString* kFCCapsPlatformPhoneRetina = @"platform_iphone_retina";
NSString* kFCCapsPlatformPhoneOnPad = @"platform_iphone_on_ipad";
NSString* kFCCapsPlatformPad = @"platform_ipad";
NSString* kFCCapsPlatformPadRetina = @"platform_ipad_retina";

//------- keys

NSString* kFCCapsDisplayAspectRatio = @"display_aspect_ratio";
NSString* kFCCapsDisplayLogicalXRes = @"display_logical_xres";
NSString* kFCCapsDisplayLogicalYRes = @"display_logical_yres";
NSString* kFCCapsDisplayPhysicalXRes = @"display_physical_xres";
NSString* kFCCapsDisplayPhysicalYRes = @"display_physical_yres";
NSString* kFCCapsDisplayScale = @"display_scale";

NSString* kFCCapsHardwareModelID = @"hardware_model_id";
NSString* kFCCapsHardwareModel = @"hardware_model";
NSString* kFCCapsHardwareUDID = @"hardware_udid";
NSString* kFCCapsHardwareName = @"hardware_name";

NSString* kFCCapsOSMultitaskingSupported = @"os_multitaskingsupported";
NSString* kFCCapsOSVersion = @"os_version";
NSString* kFCCapsOSName = @"os_name";
NSString* kFCCapsOSGameCenter = @"os_gamecenter";

NSString* kFCCapsPlatform = @"platform";

NSString* kFCCapsSimulator = @"simulator";

NSString* kFCCapsAppPirated = @"apppirated";

#pragma mark - Implementation

static FCCaps* pInstance;

@implementation FCCaps

@synthesize caps = _caps;

#pragma mark - Singleton

+(FCCaps*)instance
{
	if (!pInstance) {
		pInstance = [[FCCaps alloc] init];
	}
	return pInstance;
}

#pragma mark - Object Lifetime

-(id)init
{
	self = [super init];
	if (self) {
		_caps = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(void)dealloc
{
	[_caps release], _caps = nil;
	[super dealloc];
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

-(void)probeCaps
{
	// get the OS version...
	
	[_caps setValue:[UIDevice currentDevice].systemVersion forKey:kFCCapsOSVersion];

	// OS name

	[_caps setValue:[UIDevice currentDevice].systemName forKey:kFCCapsOSName];

	// multitasking support
	
	if ([UIDevice currentDevice].multitaskingSupported) {
		[_caps setValue:kFCCapsTrue forKey:kFCCapsOSMultitaskingSupported];
	} else {
		[_caps setValue:kFCCapsFalse forKey:kFCCapsOSMultitaskingSupported];		
	}
	
	// UDID

	[_caps setValue:[UIDevice currentDevice].uniqueIdentifier forKey:kFCCapsHardwareUDID];

	// name

	[_caps setValue:[UIDevice currentDevice].name forKey:kFCCapsHardwareName];

	// hardware model ID
	
	[_caps setValue:[self machine] forKey:kFCCapsHardwareModelID];
	
	// Check for frameworks
	
	Class gcClass = (NSClassFromString(@"GKLocalPlayer"));	// Game Center
	
	BOOL osVersionSupported = ([[_caps valueForKey:kFCCapsOSVersion] compare:@"4.1" options:NSNumericSearch] != NSOrderedAscending);
	
	if (osVersionSupported && gcClass) 
	{
		[_caps setValue:kFCCapsUnknown forKey:kFCCapsOSGameCenter];	// Need to wait for login to complete
	}
	else
	{
		[_caps setValue:kFCCapsNotPresent forKey:kFCCapsOSGameCenter];		
	}

	// display caps

	CGFloat scale = [UIScreen mainScreen].scale;
	CGRect bounds = [UIScreen mainScreen].bounds;
	CGSize screenSize = [UIScreen mainScreen].currentMode.size;
	CGFloat aspectRatio = [UIScreen mainScreen].currentMode.pixelAspectRatio;
	
	// make all sizes etc portrait here...

	if (bounds.size.width > bounds.size.height) {
		FC::Swap(bounds.size.width, bounds.size.height);
	}
	
	// push values into caps
	
	[_caps setValue:[NSString stringWithFormat:@"%f", scale] forKey:kFCCapsDisplayScale];
	[_caps setValue:[NSString stringWithFormat:@"%f", aspectRatio] forKey:kFCCapsDisplayAspectRatio];

	[_caps setValue:[NSString stringWithFormat:@"%f", bounds.size.width] forKey:kFCCapsDisplayLogicalXRes];
	[_caps setValue:[NSString stringWithFormat:@"%f", bounds.size.height] forKey:kFCCapsDisplayLogicalYRes];

	[_caps setValue:[NSString stringWithFormat:@"%f", screenSize.width] forKey:kFCCapsDisplayPhysicalXRes];
	[_caps setValue:[NSString stringWithFormat:@"%f", screenSize.height] forKey:kFCCapsDisplayPhysicalYRes];

	// work out the the platform designation
	
	if( ((bounds.size.width * scale) == screenSize.width) && ((bounds.size.height * scale) == screenSize.height)) 
	{
		// Native app
		
		if (scale == 2.0)	// retina
		{
			if (bounds.size.width == 320) 
				[_caps setValue:kFCCapsPlatformPhoneRetina forKey:kFCCapsPlatform];
			else
				[_caps setValue:kFCCapsPlatformPadRetina forKey:kFCCapsPlatform];				
		}
		else
		{
			if (bounds.size.width == 320) 
				[_caps setValue:kFCCapsPlatformPhone forKey:kFCCapsPlatform];
			else
				[_caps setValue:kFCCapsPlatformPad forKey:kFCCapsPlatform];				
		}
	}
	else
	{
		// non-native, so iPhone running on iPad
		
		[_caps setValue:kFCCapsPlatformPhoneOnPad forKey:kFCCapsPlatform];		
	}
	
	// Now for some lower level stuff
	
	[_caps setValue:[self model] forKey:@"modelid"];
	[_caps setValue:[self machinearch] forKey:@"machinearch"];
	[_caps setValue:[NSNumber numberWithInt:[self numcpu]] forKey:@"numcpu"];
	[_caps setValue:[NSNumber numberWithInt:[self byteorder]] forKey:@"byteorder"];
	[_caps setValue:[NSNumber numberWithLongLong:[self memsize]] forKey:@"memsize"];
	[_caps setValue:[NSNumber numberWithInt:[self pagesize]] forKey:@"pagesize"];

	// detect if pirated ?

	if ([[[NSBundle mainBundle] infoDictionary] objectForKey: @"SignerIdentity"] == nil) {
		[_caps setValue:kFCCapsTrue forKey:kFCCapsAppPirated];
	} else {
		[_caps setValue:kFCCapsFalse forKey:kFCCapsAppPirated];		
	}
	[self dumpToTTY];
	
	return;
}

-(void)dumpToTTY
{
	FC_LOG1(@"Caps - %@", self.caps);
}

-(void)setGameCenterUnavailable
{
	[_caps setValue:kFCCapsNotPresent forKey:kFCCapsOSGameCenter];
}

-(void)setGameCenterAvailable
{
	[_caps setValue:kFCCapsPresent forKey:kFCCapsOSGameCenter];
}

-(void)setWindowBounds:(CGRect)bounds
{
	[_caps setValue:[NSNumber numberWithInt:bounds.size.width] forKey:kFCCapsDisplayLogicalXRes];
	[_caps setValue:[NSNumber numberWithInt:bounds.size.height] forKey:kFCCapsDisplayLogicalYRes];
}

-(void)setPhysicalResolutionX:(int)x Y:(int)y
{
	[_caps setValue:[NSNumber numberWithInt:x] forKey:kFCCapsDisplayPhysicalXRes];
	[_caps setValue:[NSNumber numberWithInt:y] forKey:kFCCapsDisplayPhysicalYRes];	
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
	return [[self.caps valueForKey:key] isEqualToString:kFCCapsPresent];	
}

@end

#endif // TARGET_OS_IPHONE
