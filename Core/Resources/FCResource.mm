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

#import "FCResource.h"

@implementation FCResource

@synthesize binaryPayload = _binaryPayload;
@synthesize xml = _xml;
@synthesize name = _name;
@synthesize userData = _userData;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+(id)resource
{
	return [[FCResource alloc] init];
}

-(id)initWithContentsOfURL:(NSURL*)url
{
	self = [self init];
	if (self) {		
		NSURL* fcrURL = [[url URLByDeletingPathExtension] URLByAppendingPathExtension:@"fcr"];
		NSURL* binURL = [[url URLByDeletingPathExtension] URLByAppendingPathExtension:@"bin"];
		
		_xml = new FCXML;
		_xml->InitWithContentsOfFile([[fcrURL absoluteString] UTF8String]);
		
		self.binaryPayload = [NSData dataWithContentsOfURL:binURL];
	}
	return self;
}

+(FCResource*)resourceWithContentsOfURL:(NSURL*)url
{
	FCResource* ret = [[FCResource alloc] initWithContentsOfURL:url];
	return ret;
}


#if !defined (MASTER)
-(NSString*)description
{
	NSMutableString* retString = [NSMutableString stringWithString:@"--- FCResource ---\n"];
	[retString appendFormat:@"Name: %@\n", self.name];
	[retString appendFormat:@"Size: %d\n", [self.binaryPayload length]];
	[retString appendFormat:@"UserData: %@\n", self.userData];
	return [NSString stringWithString:retString];
}
#endif

@end
