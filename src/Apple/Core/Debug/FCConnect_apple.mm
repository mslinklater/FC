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

#import "FCConnect_apple.h"

#include <string>

#pragma mark - Platform API

bool plt_FCConnect_Start();
bool plt_FCConnect_EnableWithName( std::string name );
void plt_FCConnect_Stop();
void plt_FCConnect_SendString( std::string s );

bool plt_FCConnect_Start()
{
	return [[FCConnect_apple instance] start];
}

bool plt_FCConnect_EnableWithName( std::string name )
{
	return [[FCConnect_apple instance] enableWithName:[NSString stringWithUTF8String:name.c_str()]];
}

void plt_FCConnect_Stop()
{
	[[FCConnect_apple instance] stop];
}

void plt_FCConnect_SendString( std::string s )
{
	[[FCConnect_apple instance] sendString:[NSString stringWithUTF8String:s.c_str()]];
}

#pragma mark - Objective-C API

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <CFNetwork/CFSocketStream.h>
#include "Shared/Core/FCError.h"
#include "Shared/Lua/FCLua.h"

static NSString* s_ErrorDomain = @"FCConnectErrorDomain";
static FCConnect_apple* s_connect;

static NSString* kFCConnectLua = @"Lua_";
static NSString* kFCConnectLog = @"Log_";

static void ServerAcceptCallback(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void* data, void* info)
{
	if (type == kCFSocketAcceptCallBack) {
		CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle*)data;
		uint8_t name[SOCK_MAXADDRLEN];
		socklen_t namelen = sizeof(name);
		NSData* peer = nil;
		if ( getpeername(nativeSocketHandle, (struct sockaddr*)name, &namelen) == 0) {
			peer = [NSData dataWithBytes:name length:namelen];
		}
		CFReadStreamRef readStream = NULL;
		CFWriteStreamRef writeStream = NULL;
		CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle, &readStream, &writeStream);
		
		if (readStream && writeStream) {
			CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
			CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
//			[s_connect setInputStream:(__bridge_transfer NSInputStream*)readStream andOutputStream:(__bridge_transfer NSOutputStream*)writeStream];
//			[s_connect setInputStream:(__bridge NSInputStream*)readStream andOutputStream:(__bridge NSOutputStream*)writeStream];
			s_connect.inputStream = (__bridge NSInputStream*)readStream;
			s_connect.outputStream = (__bridge NSOutputStream*)writeStream;
			s_connect.connected = YES;
		}
		else
		{
			close( nativeSocketHandle );
		}
		if (readStream) {
			CFRelease(readStream);
		}
		if (writeStream) {
			CFRelease(writeStream);
		}
	}
}

@implementation FCConnect_apple
@synthesize connected = _connected;
@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;

+(FCConnect_apple*)instance
{
	static FCConnect_apple* s_pInstance = 0;
	if (!s_pInstance) {
		s_pInstance = [[FCConnect_apple alloc] init];
	}
	return s_pInstance;
}

-(id)init
{
	self = [super init];
	if (self) {
		_connected = NO;
		m_sendQueue = [[NSMutableArray alloc] init];
	}
	return self;
}


-(BOOL)start
{
	CFSocketContext socketContext = {0, (__bridge void*)self, NULL, NULL, NULL};
	
	m_socketRef = CFSocketCreate(kCFAllocatorDefault, 
								 PF_INET6, 
								 SOCK_STREAM, 
								 IPPROTO_TCP, 
								 kCFSocketAcceptCallBack, 
								 (CFSocketCallBack)&ServerAcceptCallback, 
								 &socketContext);
	
	if (m_socketRef != NULL) 
	{
		m_protocolFamily = PF_INET6;
	}
	else
	{
		m_socketRef = CFSocketCreate(kCFAllocatorDefault, 
									 PF_INET, 
									 SOCK_STREAM, 
									 IPPROTO_TCP, 
									 kCFSocketAcceptCallBack, 
									 (CFSocketCallBack)&ServerAcceptCallback, 
									 &socketContext );
		if (m_socketRef != NULL) {
			m_protocolFamily = PF_INET;
		}
	}
	
	if (m_socketRef == NULL) {
//		if (error) {
//			*error = [[NSError alloc] initWithDomain:s_ErrorDomain code:kFCConnectNoSocketsAvailable userInfo:nil];
//		}
//		if (m_socketRef) {
//			CFRelease( m_socketRef );
//		}
//		m_socketRef = NULL;
		return NO;
	}
	
	int yes = 1;
	setsockopt(CFSocketGetNative(m_socketRef), SOL_SOCKET, SO_REUSEADDR, (void*)&yes, sizeof(yes));
	
	if (m_protocolFamily == PF_INET6) {
		struct sockaddr_in6 addr6;
		memset(&addr6, 0, sizeof(addr6));
		addr6.sin6_len = sizeof(addr6);
		addr6.sin6_family = AF_INET6;
		addr6.sin6_port = 0;
		addr6.sin6_flowinfo = 0;
		addr6.sin6_addr = in6addr_any;
		NSData* address6 = [NSData dataWithBytes:&addr6 length:sizeof(addr6)];
		
		if (CFSocketSetAddress(m_socketRef, (__bridge CFDataRef)address6) != kCFSocketSuccess) {
//			if (error) {
//				*error = [[NSError alloc] initWithDomain:s_ErrorDomain code:kFCConnectCouldNotBindToIPv6Address userInfo:nil];
//			}
//			if (m_socketRef) {
//				CFRelease(m_socketRef);
//			}
//			m_socketRef = NULL;
			return NO;
		}
		
		NSData* addr = (__bridge_transfer NSData*)CFSocketCopyAddress(m_socketRef);
		memcpy(&addr6, [addr bytes], [addr length]);
		m_port = ntohs( addr6.sin6_port );
	}
	else
	{
		struct sockaddr_in addr4;
		memset(&addr4, 0, sizeof(addr4));
		addr4.sin_len = sizeof(addr4);
		addr4.sin_family = AF_INET;
		addr4.sin_port = 0;
		addr4.sin_addr.s_addr = htonl(INADDR_ANY);
		NSData* address4 = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];
		
		if (kCFSocketSuccess != CFSocketSetAddress(m_socketRef, (__bridge CFDataRef)address4)) {
//			if (error) {
//				*error = [[NSError alloc] initWithDomain:s_ErrorDomain code:kFCConnectCouldNotBindToIPv4Address userInfo:nil];
//			}
			if (m_socketRef) {
				CFRelease(m_socketRef);
			}
			m_socketRef = 0;
			return NO;
		}
		
		NSData* addr = (__bridge_transfer NSData*)CFSocketCopyAddress(m_socketRef);
		memcpy(&addr4, [addr bytes], [addr length]);
		m_port = ntohs(addr4.sin_port);
	}
	
	CFRunLoopRef cfrl = CFRunLoopGetCurrent();
	CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, m_socketRef, 0);
	CFRunLoopAddSource(cfrl, source, kCFRunLoopCommonModes);
	CFRelease(source);
	
	return YES;
}

-(BOOL)enableWithName:(NSString*)name
{
	m_bonjourIdentifier = [NSString stringWithFormat:@"_%@._tcp.", name];
	
	m_netService = [[NSNetService alloc] initWithDomain:@"local" type:m_bonjourIdentifier name:@"" port:m_port];
	if (m_netService == nil) {
		return NO;
	}
	[m_netService setDelegate:self];
	[m_netService scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[m_netService publish];
	return YES;
}

-(void)stop
{
	
}

-(void)setInputStream:(NSInputStream *)inputStream
{
	_inputStream = inputStream;
	_inputStream.delegate = self;
	[_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_inputStream open];
}

-(void)setOutputStream:(NSOutputStream *)outputStream
{
	_outputStream = outputStream;
	_outputStream.delegate = self;
	[_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_outputStream open];
}

//-(void)setInputStream:(NSInputStream*)iStream andOutputStream:(NSOutputStream*)oStream
//{
//	m_inputStream = iStream;
//	m_inputStream.delegate = self;
//	[m_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//	[m_inputStream open];
//	
//	m_outputStream = oStream;
//	m_outputStream.delegate = self;
//	[m_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//	[m_outputStream open];
//	
//	_connected = YES;
//}

-(void)sendNextString
{
	NSString* sendPacket = [m_sendQueue objectAtIndex:0];
	NSInteger bytesToSend = [sendPacket length];
	NSInteger bytesSent = [_outputStream write:(const uint8_t*)[sendPacket UTF8String] maxLength:[sendPacket length]];
	
	if (bytesSent == bytesToSend) 
	{
		[m_sendQueue removeObjectAtIndex:0];
	} 
	else
	{
		sendPacket = [sendPacket substringFromIndex:bytesSent];
	}
}

-(void)sendString:(NSString *)string
{
	if (_connected) {
		[m_sendQueue addObject:string];
		[self sendNextString];
	}
}

#pragma mark - NSNetServiceDelegate

-(void)netServiceWillPublish:(NSNetService *)sender
{
	NSLog(@"netServiceWillPublish");
}

-(void)netServiceDidPublish:(NSNetService*)sender
{
	NSLog(@"netServiceDidPublish");
}

-(void)netService:(NSNetService*)sender didNotPublish:(NSDictionary *)errorDict
{
	NSLog(@"netService:didNotPublish");
}

-(void)netServiceWillResolve:(NSNetService *)sender
{
	NSLog(@"netServiceWillResolve");
}

-(void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
	NSLog(@"netService:didNotResolve");
}

-(void)netServiceDidResolveAddress:(NSNetService *)sender
{
	NSLog(@"netServiceDidResolveAddress");
}

-(void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data
{
	NSLog(@"netService:didUpdateTXTRecordData");
}

-(void)netServiceDidStop:(NSNetService *)sender
{
	NSLog(@"netServiceDidStop");
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
	if ( aStream == _inputStream ) 
	{
		switch (eventCode) {
			case NSStreamEventNone:
				NSLog(@"Input - None");
				break;
			case NSStreamEventOpenCompleted:
				break;
			case NSStreamEventHasBytesAvailable:
			{
				uint8_t pBuffer[128];
				NSUInteger bufferSize = 128;
				NSUInteger bytesRead = [_inputStream read:&pBuffer[0] maxLength:bufferSize];
				pBuffer[bytesRead] = 0;
				FCLua::Instance()->ExecuteLine( (char*)(&pBuffer[0]) );
				break;
			}
			case NSStreamEventHasSpaceAvailable:
				NSLog(@"Input - HasSpaceAvailable");
				break;
			case NSStreamEventErrorOccurred:
				NSLog(@"Input - ErrorOccurred");
				break;
			case NSStreamEventEndEncountered:
				NSLog(@"Input - EndEncountered");
				_connected = NO;
				break;				
			default:
				break;
		}
	} 
	else if ( aStream == _outputStream ) 
	{
		switch (eventCode) {
			case NSStreamEventNone:
				NSLog(@"Output - None");
				break;
			case NSStreamEventOpenCompleted:
				break;
			case NSStreamEventHasBytesAvailable:
				NSLog(@"Output - HasBytesAvailable");
				break;
			case NSStreamEventHasSpaceAvailable:
				if ([m_sendQueue count]) {
					[self sendNextString];
				}
				break;
			case NSStreamEventErrorOccurred:
				NSLog(@"Output - ErrorOccurred");
				break;
			case NSStreamEventEndEncountered:
				NSLog(@"Output - EndEncountered");
				break;				
			default:
				break;
		}
	}
}

@end
