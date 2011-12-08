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

#import "FCUserDefaults.h"
#import "FCAppContext.h"
#import "FCXMLData.h"

static FCUserDefaults* pInstance;

@implementation FCUserDefaults

+(FCUserDefaults*)instance
{
	if (!pInstance) 
	{
		pInstance = [[FCUserDefaults alloc] init];
	}
	return pInstance;
}

-(id)init
{
	self = [super init];
	if (self) {
		// blah
	}
	return self;
}


//----------------------------------------------------------------------------------------------------------------------

-(void)registerDefaults:(FCXMLData*)gameData
{
	NSArray* gameDataArray = [gameData arrayForKeyPath:@"gamedata.defaults.default"];
	
	NSMutableDictionary* defaultsDictionary = [[NSMutableDictionary alloc] init];
	
	for( NSDictionary* entry in gameDataArray )
	{
		NSString* defaultKey = [entry valueForKey:@"id"];
		NSString* value = [entry valueForKey:@"value"];
		
		if ([[entry valueForKey:@"type"] isEqualToString:@"bool"]) 
		{
			if ([value isEqualToString:@"true"]) 
			{
				[defaultsDictionary setObject:[NSNumber numberWithBool:YES] forKey:defaultKey];
			}
			else
			{
				[defaultsDictionary setObject:[NSNumber numberWithBool:NO] forKey:defaultKey];				
			}
		}
		else if ([[entry valueForKey:@"type"] isEqualToString:@"float"])
		{
			[defaultsDictionary setObject:[NSNumber numberWithFloat:[value floatValue]] forKey:defaultKey];			
		}
		else
		{
			NSAssert(0, @"unknown default type");	// unknown default type
		}
	}
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDictionary];

}

@end

#endif // TARGET_OS_IPHONE
