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

#import "FCPersistentData.h"
#import "FCCore.h"
#import "FCLua.h"

#pragma mark - Lua Interface

static int SaveData( lua_State* lua )
{
	[[FCPersistentData instance] saveData];
	return 0;
}

static int LoadData( lua_State* lua )
{
	[[FCPersistentData instance] loadData];
	return 0;
}

@implementation FCPersistentData

@synthesize dataRoot = _dataRoot;

+(FCPersistentData*)instance
{
	static FCPersistentData* pInstance;
	
	if (!pInstance) 
	{
		pInstance = [[FCPersistentData alloc] init];
	}
	return pInstance;
}

+(void)registerLuaFunctions:(FCLuaVM*)lua
{
	[lua createGlobalTable:@"PersistentData"];
	[lua registerCFunction:SaveData as:@"PersistentData.SaveData"];
	[lua registerCFunction:LoadData as:@"PersistentData.LoadData"];
}

-(NSString*)filename
{
	NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentDirectory = [documentDirectories objectAtIndex:0];
	return [documentDirectory stringByAppendingPathComponent:@"savedata"];
}

#pragma mark - Object Lifespan

-(id)init
{
	self = [super init];
	if (self) 
	{
	}
	return self;
}

-(void)dealloc
{
	self.dataRoot = nil;
	[super dealloc];
}

#pragma mark - Load and Save

-(void)loadData
{
	FC_LOG(@"FCPersisteneData:loadData");
	self.dataRoot = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filename]];
	
	if (!self.dataRoot) {
		self.dataRoot = [NSMutableDictionary dictionary];
	}
}

-(void)saveData
{
	FC_LOG(@"FCPersisteneData:saveData");
	[NSKeyedArchiver archiveRootObject:self.dataRoot toFile:[self filename]];
}

-(id)objectForKey:(NSString*)key
{
	return [self.dataRoot valueForKey:key];
}

-(void)addObject:(id)object forKey:(NSString*)key
{
	[self.dataRoot setObject:object forKey:key];
}

@end
