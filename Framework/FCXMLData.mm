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

#import "FCXMLData.h"
#import "FCCore.h"
#import "FCResourceManager.h"

@interface FCXMLData(hidden)
-(void)parseData:(NSData*)data;
@end

@implementation FCXMLData

#pragma mark -
#pragma mark Validation and Debug

-(void)dumpContents:(NSMutableDictionary*)dict tab:(int)tabLevel
{
	static char cString[] = "                                                                                                                      ";
	
	NSString *tab = [[NSString alloc] initWithBytes:cString length:tabLevel * 2 encoding:NSUTF8StringEncoding];
	
	if (![dict isKindOfClass:[NSMutableDictionary class]]) 
	{
		FC_FATAL(@"GameData:dumpContents - not NSMutableDictionary class");
	}
	
	for( NSString* key in dict )	// iterate through keys
	{
		id value = [dict valueForKey:key];
		
		if( [value isKindOfClass:[NSString class]] )
		{
			NSString* blah = [NSString stringWithFormat:@"%@Key '%@' Value '%@'", tab, key, value];
			FC_LOG(blah);
			(void)blah;
		}
		if( [value isKindOfClass:[NSArray class]] )
		{
			NSString* blah = [NSString stringWithFormat:@"%@Array of '%@'", tab, key];
			FC_LOG(blah);
			for( NSMutableDictionary* entry in value )
			{
				[self dumpContents:entry tab:tabLevel + 1];	
			}
			blah = [NSString stringWithFormat:@"%@End Array of '%@'", tab, key];
			FC_LOG(blah);
		}
		if( [value isKindOfClass:[NSDictionary class]] )
		{
			NSString* blah = [NSString stringWithFormat:@"%@Dictionary '%@'", tab, key];
			FC_LOG(blah);
			[self dumpContents:value tab:tabLevel + 1];
			blah = [NSString stringWithFormat:@"%@End Dictionary '%@'", tab, key];
			FC_LOG(blah);
		}
	}
}

-(BOOL)validate
{
	return YES;
}

#pragma mark -
#pragma mark Initialiser

-(id)initWithContentsOfFile:(NSString*)filePath
{
	self = [super init];
	if (self) 
	{
		NSError* error = nil;
		
		NSData* fileData = [NSData dataWithContentsOfFile:filePath options:nil error:&error];

		if (error) {
			FC_FATAL([error description]);
		}
		
		self = [self initWithData:fileData];
	}
	return self;
}

+(FCXMLData*)fcxmlDataWithContentsOfFile:(NSString *)filePath
{
	FCXMLData* ret = [[FCXMLData alloc] initWithContentsOfFile:filePath];
	return ret;
}

-(id)initWithData:(NSData*)data
{
	self = [super init];
	if (self) 
	{
		[self parseData:data];
	}
	return self;
}

-(id)initWithContentsOfURL:(NSURL*)url
{
	self = [super init];
	if (self) 
	{
		NSError* error = nil;
		
		NSData* fileData = [NSData dataWithContentsOfURL:url options:nil error:&error];
		
		if (error) {
			FC_FATAL([error description]);
		}
		
		self = [self initWithData:fileData];
	}
	return self;
}

+(FCXMLData*)fcxmlDataWithContentsOfURL:(NSURL *)url
{
	FCXMLData* ret = [[FCXMLData alloc] initWithContentsOfURL:url];
	return ret;
}


-(void)parseData:(NSData*)data
{
	NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithData:data];
	xmlParser.delegate = self;
	[xmlParser parse];
}

-(NSArray*)arrayForKeyPath:(NSString*)keyPath
{
	id found = [mRoot valueForKeyPath:keyPath];

	if(!found)
	{
		return nil;
	}
	
	if([found isKindOfClass:[NSDictionary class]]) 
	{
		return [NSArray arrayWithObject:found];
	}

	if(![found isKindOfClass:[NSMutableArray class]]) 
	{
		return nil;
	}
	return found;
}

-(NSDictionary*)dictionaryForKeyPath:(NSString*)keyPath
{
	id found = [mRoot valueForKeyPath:keyPath];
	if (!found || ![found isKindOfClass:[NSMutableDictionary class]]) 
	{
		FC_FATAL(@"Object found at keypath is not a dictionary");
	}
	return found;
}

-(NSString*)stringForKeyPath:(NSString*)keyPath
{
	id found = [mRoot valueForKeyPath:keyPath];
	if (!found || ![found isKindOfClass:[NSMutableString class]]) 
	{
		FC_FATAL(@"Object found at keypath is not a string");
	}
	return found;
}

#pragma mark -
#pragma mark Accessors

-(NSMutableDictionary*)root
{
	return mRoot;
}

-(NSString*)description
{
	return [mRoot description];
}

#pragma mark NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	mCurrentNode = [mCurrentNodeStack objectAtIndex:[mCurrentNodeStack count] - 2];
	[mCurrentNodeStack removeLastObject];
}

- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix
{
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	NSMutableArray *array = nil;
	
	NSMutableDictionary* newElement = [[NSMutableDictionary alloc] init];
		
	// check if currentNode has entries of type 'elementName'

	id elementObject = [mCurrentNode objectForKey:elementName];
	
	if (!elementObject) 
	{
		[mCurrentNode setObject:newElement forKey:elementName];
	}
	else 
	{
		NSMutableArray* newArray = nil;

		if ([elementObject isKindOfClass:[NSMutableDictionary class]]) 
		{
			newArray = [[NSMutableArray alloc] init];
			[newArray addObject:elementObject];
			[mCurrentNode setObject:newArray forKey:elementName];
			elementObject = newArray;
		}
		
		array = elementObject;
		[array addObject:newElement];
	}

	[newElement addEntriesFromDictionary:attributeDict];

	// housekeeping
	
	[mCurrentNodeStack addObject:newElement];
	mCurrentNode = newElement;
}

- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI
{
}

- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue
{
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
}

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
}

- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model
{
}

- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)entityName publicID:(NSString *)publicID systemID:(NSString *)systemID
{
}

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString
{
}

- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value
{
}

- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID
{
}

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data
{
}

- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName
{
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
}

- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)entityName systemID:(NSString *)systemID
{
	return [[NSData alloc] init];
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError
{
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	mRoot = [[NSMutableDictionary alloc] init];
	mCurrentNodeStack = [[NSMutableArray alloc] init];
	
	[mCurrentNodeStack addObject:mRoot];
	mCurrentNode = mRoot;
}

@end

