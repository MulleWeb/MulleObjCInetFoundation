//
//  NSURL.h
//  MulleObjCStandardFoundation
//
//  Copyright (c) 2011 Nat! - Mulle kybernetiK.
//  Copyright (c) 2011 Codeon GmbH.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
#import "import.h"


@class NSString;
@class NSNumber;
@class NSArray;

extern NSString   *NSURLFileScheme;


struct MulleEscapedURLPartsUTF8
{
   // scheme
   mulle_utf8_t  *scheme_string;
   size_t        scheme_string_len;

   // authority
   mulle_utf8_t  *escaped_user_string;
   size_t        escaped_user_string_len;
   mulle_utf8_t  *escaped_password_string;
   size_t        escaped_password_string_len;

   mulle_utf8_t  *escaped_host_string;
   size_t        escaped_host_string_len;

   NSUInteger    port;

   // path
   mulle_utf8_t  *escaped_path_string;
   size_t        escaped_path_string_len;
   mulle_utf8_t  *escaped_parameter_string;
   size_t        escaped_parameter_string_len;

   // query
   mulle_utf8_t  *escaped_query_string;
   size_t        escaped_query_string_len;

   // fragment
   mulle_utf8_t  *escaped_fragment_string;
   size_t        escaped_fragment_string_len;
};


struct MulleURLSchemeHandler
{
   SEL    initURL;
   SEL    printURL;
   SEL    printResourceSpecifier;
};


struct MulleURLSchemeInitArguments
{
   mulle_utf8_t    *utf;
   mulle_utf8_t    length;
   mulle_utf8_t    scheme_length;
};


// Dont't use NSURL for file access! Use NSFileManager!
// NSURL is not an efficient storage mechanism for URLS, use NSString!
//
// NSURL will "preparse" the urlString. This makes URL objects
// fairly "fat". The Apple NSURL has this concept of marrying two NSURLs
// as baseURL and self with initWithString:baseURL:
//
// MulleFoundation doesn't do this, but creates a single new URL.
// I assume it's an outgrowth of the desire to replace strings for
// file operations, but that's IMO not a good idea. This NSURL also doesn't
// support these file operation methods, like changing attributes on files.
//
// Internally everything is stored as percentEscaped strings. But accessors
// will return unescaped strings for convenience, unless noted otherwise.
//
@interface NSURL : NSObject < NSCopying, MulleObjCImmutable>
{
   NSString   *_scheme;
   NSString   *_escapedUser;
   NSString   *_escapedPassword;
   NSString   *_escapedHost;
   NSNumber   *_port;
   NSString   *_escapedPath;
   NSString   *_escapedParameterString;
   NSString   *_escapedQuery;
   NSString   *_escapedFragment;
}


// incoming strings must already be percent escaped for all these methods
+ (instancetype) URLWithString:(NSString *) s;
+ (instancetype) URLWithString:(NSString *) s
                 relativeToURL:(NSURL *) url;
- (instancetype) initWithString:(NSString *) URLString;
- (instancetype) initWithString:(NSString *) URLString
                  relativeToURL:(NSURL *) baseURL;
- (id) mulleInitWithUTF8Characters:(mulle_utf8_t *) c_string
                            length:(NSUInteger) c_string_len;

// This method automatically uses percent encoding to escape the path
// and host parameters.
- (instancetype) initWithScheme:(NSString *) scheme
                           host:(NSString *) host
                           path:(NSString *) path;

// these return unescaped values

- (NSString *) scheme;
- (NSString *) user;
- (NSString *) password;
- (NSString *) host;
- (NSNumber *) port;       // just unescaped, no special file: handling
- (NSString *) path;
- (NSString *) parameterString;
- (NSString *) query;
- (NSString *) fragment;
- (NSString *) resourceSpecifier;

- (NSString *) description;   // URL with percent escapes

// mulle extensions

// incoming strings must be percent escaped already
// if you specify isLenient, path can contain query chars
- (instancetype) mulleInitWithEscapedURLPartsUTF8:(struct MulleEscapedURLPartsUTF8 *) parts
                               allowedCharacterSet:(NSCharacterSet *) characterSet;


// parses just path;parameterString?query#fragment
// incoming strings must be percent escaped already
- (instancetype) mulleInitResourceSpecifierWithUTF8Characters:(mulle_utf8_t *) utf
                                                       length:(NSUInteger) length;
/*
 * Support for different schemes
 */
+ (void) mulleRegisterHandler:(struct MulleURLSchemeHandler *) handler
                    forScheme:(NSString *) scheme;

// default scheme handler methods
- (NSString *) mulleGenericResourceSpecifierDescription;
- (NSString *) mulleGenericURLDescription;
- (BOOL) mulleIsAbsolutePath;

// this is where mailto: keeps the part after scheme:
// user-fragment will be nil then
- (NSString *) mulleEscapedResourceSpecifier;


@end


@interface NSURL (Legacy)

// legacy stuff, that probably doesn't do anything interesting anymore
- (BOOL) isFileURL;

- (NSURL *) standardizedURL;
- (NSString *) absoluteString;      // use description as string conversion
- (NSString *) relativePath;
- (NSString *) relativeString;
- (NSURL *) baseURL;          // this is always nil
- (NSURL *) absoluteURL;     // returns self

// these return unescaped values

- (NSArray *) pathComponents;
- (NSString *) lastPathComponent;
- (NSString *) pathExtension;


@end


char  *mulle_strnstr( char *s, size_t len, char *search);
