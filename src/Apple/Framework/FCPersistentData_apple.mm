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

#import "FCPersistentData_apple.h"
#include <string>
#include "Shared/Core/FCCore.h"

void plt_FCPersistentData_Load();
void plt_FCPersistentData_Save();
void plt_FCPersistentData_Clear();
void plt_FCPersistentData_ClearValueForKey( const char* key );
void plt_FCPersistentData_Print();
void plt_FCPersistentData_SetValueForKey( const char* value, const char* key );
const char* plt_FCPersistentData_ValueForKey( const char* key );

void plt_FCPersistentData_Load()
{
	[[FCPersistentData_apple instance] load];
}

void plt_FCPersistentData_Save()
{
	[[FCPersistentData_apple instance] save];	
}

void plt_FCPersistentData_Clear()
{
	[[FCPersistentData_apple instance] clear];	
}

void plt_FCPersistentData_ClearValueForKey( const char* key )
{
	[[FCPersistentData_apple instance].dataRoot removeObjectForKey:@(key)];
}

void plt_FCPersistentData_Print()
{
	[[FCPersistentData_apple instance] print];	
}

void plt_FCPersistentData_SetValueForKey( const char* value, const char* key )
{
	[[FCPersistentData_apple instance].dataRoot setValue:@(value) forKey:@(key)];
}

const char* plt_FCPersistentData_ValueForKey( const char* key )
{
	NSString* ret = [[FCPersistentData_apple instance].dataRoot valueForKey:@(key)];
		
	if (ret) {
		FC_ASSERT( [ret isKindOfClass:[NSString class]] );
		return [ret UTF8String];
	} else {
		return "";
	}
}

@implementation FCPersistentData_apple

+(FCPersistentData_apple*)instance
{
	static FCPersistentData_apple* s_pInstance;
	if (!s_pInstance) {
		s_pInstance = [[FCPersistentData_apple alloc] init];
	}
	return s_pInstance;
}

-(id)init
{
	self = [super init];
	if (self) {
		NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		NSString* directory = [documentDirectories objectAtIndex:0];
		
		NSError* error;
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:directory])
			[[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:NO attributes:nil error:&error];
		
		_filename = [directory stringByAppendingPathComponent:@"savedata"];
	}
	return self;
}

-(void)load
{
	self.dataRoot = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filename]];
	
	if (!self.dataRoot) {
		self.dataRoot = [NSMutableDictionary dictionary];
	}	
}

-(void)save
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		
		if( [NSKeyedArchiver archiveRootObject:self.dataRoot toFile:_filename] == NO)
		{
			FCLog("Error saving data");
		}
		
	});
}

-(void)clear
{
	self.dataRoot = [NSMutableDictionary dictionary];
	[self save];
}

-(void)print
{
	NSLog(@"%@", self.dataRoot);
}

@end
