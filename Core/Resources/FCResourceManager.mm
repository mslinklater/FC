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



#import "FCCore.h"
#import "FCResourceManager.h"
#import "FCDevice.h"

static NSString* kHDSuffix = @"_high";
static NSString* kUDSuffix = @"_ultra";

//======================================================================================================================

#pragma mark - Private Interface

@interface FCResourceManager() {
	NSSet*	mSuffixedImageTypes;
}
@property(nonatomic, strong) NSString* suffixImages;
@end

//======================================================================================================================

#pragma mark - Implementation

@implementation FCResourceManager

@synthesize suffixImages = _suffixImages;

#pragma mark - FCSingleton protocol

+(id)instance
{
	static FCResourceManager* pInstance;
	
	if (!pInstance) {
		pInstance = [[FCResourceManager alloc] init];
	}
	return pInstance;
}

#pragma mark -
#pragma mark Lifespan

-(id)init
{
	self = [super init];
	if (self) 
	{
		mSuffixedImageTypes = [NSSet setWithObjects:@"png", @"jpg", nil];
	}
	return self;
}


#pragma mark - Member methods

-(NSString*)actualResourceName:(NSString*)resource ofType:(NSString*)type
{
	NSString* actualResourceName = nil;
	
	if ([mSuffixedImageTypes containsObject:type])
	{
		if (!self.suffixImages) 
		{
			if (!self.suffixImages) self.suffixImages = @"";
		}
		
		actualResourceName = [NSString stringWithFormat:@"%@%@", resource, self.suffixImages];
	}
	else
	{
		actualResourceName = resource;
	}
	
	NSAssert1( actualResourceName, @"Resource type (%@) not known in 'actualResourceName'", type);
	
	return actualResourceName;
}

-(NSData*)dataForResource:(NSString*)resource ofType:(NSString*)type
{
	NSString* outputResource = [NSString stringWithFormat:@"Assets/%@", resource];
	
	NSString* actualResourceName = [self actualResourceName:outputResource ofType:type];

	NSString* path = [[NSBundle mainBundle] pathForResource:actualResourceName ofType:type];
	
	if(path == nil)
	{
		path = [[NSBundle mainBundle] pathForResource:resource ofType:resource];
	}

	if (path == nil) 
	{
		FC_FATAL( std::string("File not found: ") + [actualResourceName UTF8String] + "." + [type UTF8String]);
		return nil;
	}
	
	return [NSData dataWithContentsOfFile:path];
}

#pragma mark - Public API

-(FCResource*)resourceWithPath:(NSString*)resourcePath
{
	// resourcePath should not have a file suffix
	
	NSAssert([[resourcePath pathExtension] length] == 0, @"Should not put path extensions to resouce loads");
	
	NSString* xmlPath = [self actualResourceName:resourcePath ofType:@"fcr"];
	NSString* payloadPath = [self actualResourceName:resourcePath ofType:@"bin"];
	
	FCXMLPtr xml = new FCXML;
	xml->InitWithContentsOfFile(std::string("Assets/") + std::string([xmlPath UTF8String]) + ".fcr");
	
	NSData* payloadData = [self dataForResource:payloadPath ofType:@"bin"];

	FCResource* resource = [FCResource resource];

	resource.xml = xml;
	resource.binaryPayload = payloadData;
	resource.name = resourcePath;
	
	
	return resource;
}

@end


