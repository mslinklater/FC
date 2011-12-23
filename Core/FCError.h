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

#import <Foundation/Foundation.h>
#import "Lua/FCLuaClass.h"

#define FC_FATAL(n) [FCError fatal:[NSString stringWithFormat:@"%s %s:%d", __FILE__, __FUNCTION__, __LINE__] info:n]
#define FC_FATAL1(n,m) [FCError fatal1:[NSString stringWithFormat:@"%s %s:%d", __FILE__, __FUNCTION__, __LINE__] info:n arg1:m]
#define FC_FATAL2(n,m,a) [FCError fatal2:[NSString stringWithFormat:@"%s %s:%d", __FILE__, __FUNCTION__, __LINE__] info:n arg1:m arg2:a]
#define FC_HALT [FCError halt]
#define FC_UNUSED(n) (void)(n)

#if defined (DEBUG)

#define FC_ERROR(n) [FCError error:[NSString stringWithFormat:@"%s%s:%d", __FILE__, __FUNCTION__, __LINE__] info:n]
#define FC_ERROR1(n,m) [FCError error1:[NSString stringWithFormat:@"%s %s:%d", __FILE__, __FUNCTION__, __LINE__] info:n arg1:m]
#define FC_ERROR2(n,m,a) [FCError error2:[NSString stringWithFormat:@"%s %s:%d", __FILE__, __FUNCTION__, __LINE__] info:n arg1:m arg2:a]
#define FC_WARNING(n) [FCError warning:[NSString stringWithFormat:@"%s%s:%d", __FILE__, __FUNCTION__, __LINE__] info:n]
#define FC_WARNING1(n,m) [FCError warning1:[NSString stringWithFormat:@"%s %s:%d", __FILE__, __FUNCTION__, __LINE__] info:n arg1:m]
#define FC_LOG(n) [FCError log:n]
#define FC_LOG1(n,m) [FCError log1:n arg1:(m)]
#define FC_LOG2(n,m,a) [FCError log2:n arg1:(m) arg2:(a)]
#define FC_LOG3(n,m,a,b) [FCError log3:n arg1:(m) arg2:(a) arg3:(b)]

#define FC_ASSERT(n) if(!(n))FC_FATAL(@"Assert failure")
#define FC_ASSERT1(n,m) if(!(n))FC_FATAL(m)

#else

#define FC_ERROR(n) {}
#define FC_ERROR1(n,m) {}
#define FC_WARNING(n) {}
#define FC_WARNING1(n,m) {}
#define FC_LOG(n) {}
#define FC_LOG1(n,m) {}
#define FC_LOG2(n,m,a) {}
#define FC_LOG3(n,m,a,b) {}

#define FC_ASSERT(n)
#define FC_ASSERT1(n,m)

#endif

@interface FCError : NSObject <FCLuaClass> {

}
//+(void)fatal:(NSString*)location info:(NSString*)errorString;
//+(void)fatal1:(NSString*)location info:(NSString*)errorString arg1:(id)arg1;
//+(void)fatal2:(NSString*)location info:(NSString*)errorString arg1:(id)arg1 arg2:(id)arg2;

+(void)fatal:(NSString*)location info:(NSString*)errorString;
+(void)fatal1:(NSString*)location info:(NSString*)errorString arg1:(id)arg1;
+(void)fatal2:(NSString*)location info:(NSString*)errorString arg1:(id)arg1 arg2:(id)arg2;

+(void)error:(NSString*)location info:(NSString*)errorString;
+(void)error1:(NSString*)location info:(NSString*)errorString arg1:(id)arg1;
+(void)error2:(NSString*)location info:(NSString*)errorString arg1:(id)arg1 arg2:(id)arg2;

+(void)warning:(NSString*)location info:(NSString*)warningString;
+(void)warning1:(NSString*)location info:(NSString*)warningString arg1:(id)arg1;

+(void)log:(id)logItem;
+(void)log1:(id)logItem arg1:(id)arg1;
+(void)log2:(id)logItem arg1:(id)arg1 arg2:(id)arg2;
+(void)log3:(id)logItem arg1:(id)arg1 arg2:(id)arg2 arg3:(id)arg3;
+(void)halt;
@end
