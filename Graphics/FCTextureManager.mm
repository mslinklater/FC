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

#import "FCTextureManager.h"
#import "FCTextureFile.h"
#import "FCTexture.h"
#import "FCCore.h"

@interface FCTextureManager()
@property(nonatomic, strong) NSMutableDictionary* textures;
@property(nonatomic, strong) NSMutableDictionary* textureFiles;
@property(nonatomic, strong) FCTextureFile* currentTextureFile;
@end

@implementation FCTextureManager
@synthesize textures = _textures;
@synthesize textureFiles = _textureFiles;
@synthesize currentTextureFile = _currentTextureFile;

-(id)init
{
	self = [super init];
	if (self) {
		
		self.textureFiles = [NSMutableDictionary dictionary];
		self.textures = [NSMutableDictionary dictionary];
		
		// load & process manifest
		NSURL* manifestURL = [[NSBundle mainBundle] URLForResource:@"texpackermanifest" withExtension:@"xml" subdirectory:@"Output"];

		FC_ASSERT(manifestURL);
		
		NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:manifestURL];
		parser.delegate = self;

		if( [parser parse] == NO )
		{
			FC_FATAL(@"Error parsing texture manifest");
		}


//		NSLog(@"NumAtlas %d", [self.textureFiles count]);
//		NSLog(@"Textures %@", self.textures);
		
		// process textures in directory		
		
	}
	return self;
}


#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:kFCKeyAtlas]) {
		FC_ASSERT(self.currentTextureFile);
		self.currentTextureFile = nil;
	}
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:kFCKeyTexture]) 
	{
		FCTexture* texture = [FCTexture fcTexture];
		texture.name = [attributeDict valueForKey:kFCKeyName];

		texture.textureFile = self.currentTextureFile;
		CGRect texUV;
		texUV.origin.x = [[attributeDict valueForKey:kFCKeyX] floatValue];
		texUV.origin.y = [[attributeDict valueForKey:kFCKeyY] floatValue];
		texUV.size.width = [[attributeDict valueForKey:kFCKeyWidth] floatValue];
		texUV.size.height = [[attributeDict valueForKey:kFCKeyHeight] floatValue];
		texture.absUV = texUV;
		
		[self.textures setValue:texture forKey:texture.name];		
	}
	else if ([elementName isEqualToString:kFCKeyAtlas]) 
	{
		FC_ASSERT(self.currentTextureFile == nil);

		NSString* atlasName = [attributeDict valueForKey:kFCKeyName];

		NSURL* url = [[NSBundle mainBundle] URLForResource:atlasName withExtension:@"pvr" subdirectory:@"Output/Textures"];

		FCTextureFile* textureFile = [FCTextureFile fcTextureFileWithURL:url];
		textureFile.name = atlasName;
		[self.textureFiles setValue:textureFile forKey:atlasName];
		self.currentTextureFile = textureFile;
		
		// OpenGL stuff ? 
	}
}


@end

#endif // TARGET_OS_IPHONE
