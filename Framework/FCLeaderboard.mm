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



#import "FCLeaderboard.h"
#import "FCPersistentData.h"

NSString* kFCLeaderboardEntryKeyName = @"name";
NSString* kFCLeaderboardEntryKeyScore = @"score";

@implementation FCLeaderboard

@synthesize type = _type;
@synthesize numEntries = _numEntries;

-(id)initWithType:(FCLeaderboardType)type size:(int)size andPersistentKey:(NSString *)key
{
	self = [super init];
	if (self) 
	{
		_numEntries = size;
		mPersistentKey = key;
		
		if ([[FCPersistentData instance] objectForKey:key]) {
			mEntriesArray = [[FCPersistentData instance] objectForKey:key];
		}
		else
		{
			mEntriesArray = [[NSMutableArray alloc] initWithCapacity:self.numEntries];
			[[FCPersistentData instance] addObject:mEntriesArray forKey:key];
		}
		
		// create enpty entries
		
		NSUInteger count = [mEntriesArray count];
		
		if (self.numEntries > count) 
		{
			for (int i = 0; i < ( self.numEntries - count ); i++) 
			{
				[self addScore:0 forName:@"Curly Rocket"];
			}
		}
	}
	return self;
}

-(void)dealloc
{
	mEntriesArray = nil;
}

-(void)setNumEntries:(int)numEntries
{
	if (numEntries != [mEntriesArray count]) {
		
		// If smaller, create a new array and copy entries over, then free old array and reassign
		if (numEntries < [mEntriesArray count]) 
		{
			NSMutableArray* newArray = [[NSMutableArray alloc] initWithCapacity:numEntries];
			
			for (int i = 0; i < numEntries; i++) {
				[newArray addObject:[mEntriesArray objectAtIndex:i]];
			}
				// should be freed now
			
			mEntriesArray = newArray;
			[[FCPersistentData instance] addObject:mEntriesArray forKey:mPersistentKey];
		}
		_numEntries = numEntries;
	}
}

-(void)addScore:(int)score forName:(NSString*)name
{
	NSDictionary* entryDict = [[NSDictionary alloc] initWithObjectsAndKeys:name, kFCLeaderboardEntryKeyName, [NSNumber numberWithInt:score], kFCLeaderboardEntryKeyScore, nil];
	[mEntriesArray addObject:entryDict];
	
	// sort	
	
	NSSortDescriptor* sortByScoreDesc = [NSSortDescriptor sortDescriptorWithKey:kFCLeaderboardEntryKeyScore ascending:NO];
	[mEntriesArray sortUsingDescriptors:[NSArray arrayWithObject:sortByScoreDesc]];
	
	// drop the last entry if bigger than size
	
	if ([mEntriesArray count] > self.numEntries) 
	{
		[mEntriesArray removeLastObject];
	}
}

-(NSArray*)getEntriesStartingAt:(int)start size:(int)size
{
	return nil;
}

@end


