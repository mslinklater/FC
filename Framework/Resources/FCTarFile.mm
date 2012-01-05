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

// DEPRECATE

#import "FCTarFile.h"
#import "FCCore.h"

struct TarFileHeader
{
	char name[100];
	char mode[8];
	char uid[8];
	char gid[8];
	char size[12];
	char mtime[12];
	char chksum[8];
	char typeflag[1];
	char linkname[100];
	char magic[6];
	char version[2];
	char uname[32];
	char gname[32];
	char devmajor[8];
	char devminor[8];
	char prefix[155];
	char empty[12];
};

struct FCTarFileEntry
{
	int	offset;
	int	size;
};

@implementation FCTarFile

-(NSData*)dataForResource:(NSString*)name ofType:(NSString*)type
{
	NSString* resourceName = [NSString stringWithFormat:@"%@.%@", name, type];
	NSMutableDictionary* entry = [mEntries valueForKey:resourceName];

	NSAssert2(entry, @"FCTarFile - dataForResource resource not present %@.%@", name, type);
	
	NSRange range;
	range.location = [[entry valueForKey:@"offset"] intValue];
	range.length = [[entry valueForKey:@"size"] intValue];
	
	void* pBuffer = malloc( range.length );
	
	[mFileData getBytes:pBuffer range:range];
	
	NSData *data = [NSData dataWithBytes:pBuffer length:range.length];
	free(pBuffer);
	return data;
}

#pragma mark -
#pragma mark Lifespan

-(id)initWithContentsOfFile:(NSString*)filename
{
	self = [super init];
	if (self) {
		mFileData = [NSData dataWithContentsOfMappedFile:filename];
		if (!mFileData) {
			FC_FATAL1(@"Cannot open file '%@'", filename);
		}
		
		// parse tar file and build up entries dictionary
		
		NSInteger dataSize = [mFileData length];
	
		NSRange range;
		range.location = 0;
		range.length = sizeof( TarFileHeader );
		
		TarFileHeader headerBuffer;
		
		size_t rootPathLength = 0;
		
		mEntries = [[NSMutableDictionary alloc] init];
		
		do {
			[mFileData getBytes:&headerBuffer range:range];
			
			int fileType = headerBuffer.typeflag[0];
			
			if (fileType == 0) {
				break;
			}
			
			fileType -= '0';	// convert from ASCII
			
			int fileSize;	//= atoi( headerBuffer.size );
			sscanf( headerBuffer.size, "%o", &fileSize );
			
			if (rootPathLength == 0) {
				rootPathLength = strlen(headerBuffer.name);
			}
			
			switch (fileType) {
				case 0: // Normal file
					{
						NSMutableDictionary* entry = [[NSMutableDictionary alloc] init];
						[entry setValue:[NSNumber numberWithInt:fileSize] forKey:@"size"];
						[entry setValue:[NSNumber numberWithUnsignedLong:range.location + sizeof(TarFileHeader)] forKey:@"offset"];
						
						NSString* resourceName = [NSString stringWithUTF8String:(const char*)(&headerBuffer.name[rootPathLength])];
						
						[mEntries setValue:entry forKey:resourceName];
					}
					break;
				case 1:	// Link to another file
					break;
				case 2:	// Symbolic link
					break;
				case 3:	// Character special device
					break;
				case 4:	// Block special device
					break;
				case 5:	// Directory
					break;
				case 6:	// FIFO Special file
					break;
				case 7:	// Reserved
					break;					
				default:	// Unknown
					break;
			}
			
			fileSize = ((fileSize + 511) / 512) * 512;
			
			range.location += sizeof( TarFileHeader ) + fileSize;
			
		} while (range.location < dataSize);		
	}
	
	return self;
}


@end
