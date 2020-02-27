//
//  NSURL.m
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
#import "NSURL.h"

// other files in this library
#include "http_parser.h"

// other libraries of MulleObjCStandardFoundation

// std-c and dependencies
#include <string.h>
#include <ctype.h>


// could ifdef for TPS here :)
#define MulleURLPathComponentSeparator   @"/"
#define MulleURLPathExtensionSeparator   @"."
#define MulleURLPathParent               @".."


//#define NO_EMPTY_URL
#define APPLE_COMPATIBLE
// #define RIDICULOUS_APPLE_COMPATIBLE

@implementation NSURL


static struct
{
   mulle_thread_mutex_t   _lock;
   NSMapTable             *_schemes;
   NSMapTable             *_charsets;
} Self;


+ (void) load
{
   mulle_thread_mutex_init( &Self._lock);
}


+ (void) unload
{
   if( Self._schemes)
      NSFreeMapTable( Self._schemes);
   if( Self._charsets)
      NSFreeMapTable( Self._charsets);
   mulle_thread_mutex_done( &Self._lock);
}


enum URLCharacterSetCode
{
   URLSchemeAllowedCharacterSet,

   URLEscapedUserAllowedCharacterSet,
   URLEscapedPasswordAllowedCharacterSet,
   URLEscapedHostAllowedCharacterSet,
   URLEscapedPathAllowedCharacterSet,
   URLEscapedParameterStringAllowedCharacterSet,
   URLEscapedQueryAllowedCharacterSet,
   URLEscapedFragmentAllowedCharacterSet,

   URLEscapedAllowedCharacterSet
};


//
// we need specialized character sets, because we are checking percent escaped
// strings... If these turn out too big, then create custom ones...
// in NSCharacterSet
//
+ (void) initialize
{
   NSMutableCharacterSet   *characterSet;

   mulle_thread_mutex_init( &Self._lock);
   if( ! Self._charsets)
   {
      Self._charsets = NSCreateMapTable( NSIntegerMapKeyCallBacks,
                                         NSObjectMapValueCallBacks,
                                         8);

      characterSet = (id) [NSCharacterSet mulleURLSchemeAllowedCharacterSet];
      NSMapInsertKnownAbsent( Self._charsets, (void *) URLSchemeAllowedCharacterSet, characterSet);

      characterSet = [NSMutableCharacterSet URLUserAllowedCharacterSet];
      [characterSet addCharactersInString:@"%"];
      NSMapInsertKnownAbsent( Self._charsets, (void *) URLEscapedUserAllowedCharacterSet, characterSet);

      characterSet = [NSMutableCharacterSet URLPasswordAllowedCharacterSet];
      [characterSet addCharactersInString:@"%"];
      NSMapInsertKnownAbsent( Self._charsets, (void *) URLEscapedPasswordAllowedCharacterSet, characterSet);

      characterSet = [NSMutableCharacterSet URLHostAllowedCharacterSet];
      [characterSet addCharactersInString:@"%"];
      NSMapInsertKnownAbsent( Self._charsets, (void *) URLEscapedHostAllowedCharacterSet, characterSet);

      characterSet = [NSMutableCharacterSet URLPathAllowedCharacterSet];
      [characterSet addCharactersInString:@"%"];
      NSMapInsertKnownAbsent( Self._charsets, (void *) URLEscapedPathAllowedCharacterSet, characterSet);
      NSMapInsertKnownAbsent( Self._charsets, (void *) URLEscapedParameterStringAllowedCharacterSet, characterSet);

      characterSet = [NSMutableCharacterSet URLQueryAllowedCharacterSet];
      [characterSet addCharactersInString:@"%"];
      NSMapInsertKnownAbsent( Self._charsets, (void *) URLEscapedQueryAllowedCharacterSet, characterSet);

      characterSet = [NSMutableCharacterSet URLFragmentAllowedCharacterSet];
      [characterSet addCharactersInString:@"%"];
      NSMapInsertKnownAbsent( Self._charsets, (void *) URLEscapedFragmentAllowedCharacterSet, characterSet);

      characterSet = [NSMutableCharacterSet mulleURLAllowedCharacterSet];
      [characterSet addCharactersInString:@"%"];
      NSMapInsertKnownAbsent( Self._charsets, (void *) URLEscapedAllowedCharacterSet, characterSet);
   }
   mulle_thread_mutex_done( &Self._lock);
}



static NSCharacterSet  *characterSetWithCode( enum URLCharacterSetCode code)
{
   NSCharacterSet   *characterSet;

   mulle_thread_mutex_init( &Self._lock);
   {
      characterSet = NSMapGet( Self._charsets, (void  *) code);
   }
   mulle_thread_mutex_done( &Self._lock);

   return( characterSet);
}


// handler must be a static or global struct, not allocated or autoreleased
//
+ (void) mulleRegisterHandler:(struct MulleURLSchemeHandler *) handler
                    forScheme:(NSString *) scheme
{
   mulle_thread_mutex_init( &Self._lock);
   {
      if( ! Self._schemes)
         Self._schemes = NSCreateMapTable( NSObjectMapKeyCallBacks,
                                           MulleSELMapValueCallBacks,
                                           8);

      NSMapInsert( Self._schemes, scheme, handler);
   }
   mulle_thread_mutex_done( &Self._lock);
}




static struct MulleURLSchemeHandler  *lookupHandlerForScheme( NSString *scheme)
{
   struct MulleURLSchemeHandler    *handler;

   scheme = [scheme lowercaseString];
   mulle_thread_mutex_init( &Self._lock);
   {
      handler = NSMapGet( Self._schemes, scheme);
   }
   mulle_thread_mutex_done( &Self._lock);

   return( handler);
}



+ (instancetype) URLWithString:(NSString *) string
{
   return( [[[self alloc] initWithString:string] autorelease]);
}


+ (instancetype) URLWithString:(NSString *) string
                 relativeToURL:(NSURL *) baseURL
{
   return( [[[self alloc] initWithString:string
                           relativeToURL:baseURL] autorelease]);
}


/*
 *  init
 */

- (instancetype) initWithScheme:(NSString *) scheme
                           host:(NSString *) host
                           path:(NSString *) path
{
   struct MulleEscapedURLPartsUTF8   parts;

   memset( &parts, 0, sizeof( parts));

   // scheme = alpha *( alpha | digit | "+" | "-" | "." )

   // here use characterset w/o percent escaping
   host   = [host stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
   path   = [host stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];

   parts.scheme_string             = (mulle_utf8_t *) [scheme UTF8String];
   parts.scheme_string_len         = [scheme mulleUTF8StringLength];

   parts.escaped_host_string       = (mulle_utf8_t *) [host UTF8String];
   parts.escaped_host_string_len   = [host mulleUTF8StringLength];

   parts.escaped_path_string       = (mulle_utf8_t *) [path UTF8String];
   parts.escaped_path_string_len   = [path mulleUTF8StringLength];

   return( [self mulleInitWithEscapedURLPartsUTF8:&parts
                              allowedCharacterSet:[NSURL mulleURLEscapedAllowedCharacterSet]]);
}



static NSURL   *assign_checked_string_to_ivar( NSURL *self,
                                               NSString **ivar,
                                               NSString *s,
                                               NSCharacterSet *characterSet)
{
   NSUInteger   length;

   if( ! self || ! s)
      return( self);

   length = [s length];
   if( characterSet && [s mulleRangeOfCharactersFromSet:characterSet
                                                options:NSLiteralSearch
                                                  range:NSMakeRange( 0, length)].length != length)
   {
#ifdef DEBUG
      fprintf( stderr, "%s of URL has invalid characters\n", [s UTF8String]);
#endif
      [self release];
      return( nil);
   }

   *ivar = [s copy];
   return( self);
}



static id   assign_checked_utf8_to_ivar( NSURL *self,
                                         NSString **ivar,
                                         mulle_utf8_t *utf8,
                                         NSUInteger length,
                                         NSCharacterSet *characterSet)
{
   if( ! self)
      return( self);

   assert( utf8);

   *ivar = [[NSString alloc] mulleInitWithUTF8Characters:utf8
                                                  length:length];
   if( ! *ivar)
   {
#ifdef DEBUG
      fprintf( stderr, "%.*s of URL has invalid UTF8\n", (int) length, utf8);
#endif
      [self release];
      return( nil);
   }

   if( characterSet && [*ivar mulleRangeOfCharactersFromSet:characterSet
                                                    options:NSLiteralSearch
                                                      range:NSMakeRange( 0, length)].length != length)
   {
#ifdef DEBUG
      fprintf( stderr, "%.*s of URL has invalid characters\n", (int) length, utf8);
#endif
      [self release];
      return( nil);
   }

   return( self);
}


+ (NSCharacterSet *) mulleURLEscapedAllowedCharacterSet
{
   return( characterSetWithCode( URLEscapedAllowedCharacterSet));
}

//
- (instancetype) mulleInitWithEscapedURLPartsUTF8:(struct MulleEscapedURLPartsUTF8 *) parts
                              allowedCharacterSet:(NSCharacterSet *) allowedCharacterSet
{
   NSCharacterSet   *lenientCharacterSet;

   // do this first before self can become nil
   if( parts->port >= 0x10000)
   {
#ifdef DEBUG
      fprintf( stderr, "port of URL is invalid\n");
#endif

      [self release];
      return( nil);
   }

   if( parts->port)
      _port = [[NSNumber alloc] initWithUnsignedInteger:parts->port];

   // scheme (has not percent escapes)
   if( parts->scheme_string)
   {
      self = assign_checked_utf8_to_ivar( self,
                                          &_scheme,
                                          parts->scheme_string,
                                          parts->scheme_string_len,
                                          characterSetWithCode( URLSchemeAllowedCharacterSet));
   }
   // authority
   if( parts->escaped_user_string)
      self = assign_checked_utf8_to_ivar( self,
                                          &_escapedUser,
                                          parts->escaped_user_string,
                                          parts->escaped_user_string_len,
                                          characterSetWithCode( URLEscapedUserAllowedCharacterSet));
   if( parts->escaped_password_string)
      self = assign_checked_utf8_to_ivar( self,
                                          &_escapedPassword,
                                          parts->escaped_password_string,
                                          parts->escaped_password_string_len,
                                          characterSetWithCode( URLEscapedPasswordAllowedCharacterSet));
   if( parts->escaped_host_string)
      self = assign_checked_utf8_to_ivar( self,
                                          &_escapedHost,
                                          parts->escaped_host_string,
                                          parts->escaped_host_string_len,
                                          characterSetWithCode( URLEscapedHostAllowedCharacterSet));

   // Use allowedCharacterSet as mulleURLAllowedCharacterSet if we don't want to
   // inconvience a possibly incorrect split up URI of an unknown scheme

   if( parts->escaped_path_string)
      self = assign_checked_utf8_to_ivar( self,
                                          &_escapedPath,
                                          parts->escaped_path_string,
                                          parts->escaped_path_string_len,
                                          allowedCharacterSet
                                             ? allowedCharacterSet
                                             : characterSetWithCode( URLEscapedPathAllowedCharacterSet));
   // part of path really
   if( parts->escaped_parameter_string)
      self = assign_checked_utf8_to_ivar( self,
                                          &_escapedParameterString,
                                          parts->escaped_parameter_string,
                                          parts->escaped_parameter_string_len,
                                          allowedCharacterSet
                                             ? allowedCharacterSet
                                             : characterSetWithCode( URLEscapedParameterStringAllowedCharacterSet));
   // query
   if( parts->escaped_query_string)
      self = assign_checked_utf8_to_ivar( self,
                                          &_escapedQuery,
                                          parts->escaped_query_string,
                                          parts->escaped_query_string_len,
                                          allowedCharacterSet
                                             ? allowedCharacterSet
                                             : characterSetWithCode( URLEscapedQueryAllowedCharacterSet));
   // fragment
   if( parts->escaped_fragment_string)
      self = assign_checked_utf8_to_ivar( self,
                                          &_escapedFragment,
                                          parts->escaped_fragment_string,
                                          parts->escaped_fragment_string_len,
                                          allowedCharacterSet
                                             ? allowedCharacterSet
                                             : characterSetWithCode( URLEscapedFragmentAllowedCharacterSet));

#ifdef DEBUG
   [self mulleDump];
#endif
   return( self);
}



- (instancetype) mulleInitWithUTF8Characters:(mulle_utf8_t *) utf8
                                      length:(NSUInteger) length
{
   mulle_utf8_t                        *s;
   SEL                                 init;
   struct MulleURLSchemeHandler        *handler;
   struct MulleURLSchemeInitArguments  args;

   if( ! utf8)
   {
      [self release];
      return( nil);
   }

#ifdef NO_EMPTY_URL
   if( ! length)
   {
#ifdef DEBUG
      fprintf( stderr, "empty URL is invalid\n");
#endif
      [self release];
      return( nil);
   }
#endif

   // we want to differentiate between URLS w/o a scheme
   // URLs with a known scheme and URLs with an unknown scheme

   handler     = NULL;
   s           = mulle_utf8_strnchr( utf8, length, ':');

   if( ! s)
      return( [self mulleInitResourceSpecifierWithUTF8Characters:utf8
                                                          length:length]);


   args.scheme_length = s - utf8;
   _scheme            = [[NSString alloc] mulleInitWithUTF8Characters:utf8
                                                               length:args.scheme_length];
   handler            = lookupHandlerForScheme( _scheme);

   if( handler)
   {
      args.utf    = utf8;
      args.length = length;

      return( [self performSelector:handler->initURL
                         withObject:(id) &args]);
   }

   //
   // known scheme but no handler ? handle generically
   //
   utf8   += args.scheme_length + 1;
   length -= args.scheme_length + 1;

   return( [self mulleInitResourceSpecifierWithUTF8Characters:utf8
                                                       length:length]);
}


- (instancetype) mulleInitResourceSpecifierWithUTF8Characters:(mulle_utf8_t *) utf
                                                        length:(NSUInteger) length
{
   struct http_parser_url            url;
   struct MulleEscapedURLPartsUTF8   parts;
   mulle_utf8_t                      *end;
   mulle_utf8_t                      *tmp;

   // now do it all manually :(
   memset( &parts, 0, sizeof( parts));

#ifdef RIDICULOUS_APPLE_COMPATIBLE
   // do this for compatibility (late added hack)
   if( length >= 2 && utf[ 0] == utf[ 1] && utf[ 0] == '/')
   {
      parts.escaped_host_string     = &utf[ 2];
      parts.escaped_host_string_len = length - 2;
      tmp                           = mulle_utf8_strnchr( parts.escaped_host_string,
                                                          parts.escaped_host_string_len,
                                                          '/');

      if( ! tmp)
      {
#ifdef APPLE_COMPATIBLE
         parts.escaped_path_string     = parts.escaped_host_string;
         parts.escaped_path_string_len = 0;
#endif
         return( [self mulleInitWithEscapedURLPartsUTF8:&parts
                                    allowedCharacterSet:[NSURL mulleURLEscapedAllowedCharacterSet]]);
      }

      // no hostname, then just parse as path again
      if( tmp == parts.escaped_host_string)
      {
         parts.escaped_host_string     = NULL;
         parts.escaped_host_string_len = 0;
      }
      else
      {
         parts.escaped_host_string_len = (tmp - parts.escaped_host_string);

         utf     = tmp;
         length -= 2 + parts.escaped_host_string_len; // "//" <host>
      }
   }
#endif

   parts.escaped_parameter_string = mulle_utf8_strnchr( utf, length, ';');
   parts.escaped_query_string     = mulle_utf8_strnchr( utf, length, '?');
   parts.escaped_fragment_string  = mulle_utf8_strnchr( utf, length, '#');

   // some sanity checks
   if( parts.escaped_query_string)
   {
      if( parts.escaped_parameter_string > parts.escaped_query_string)
         parts.escaped_parameter_string = NULL;
   }

   if( parts.escaped_fragment_string)
   {
      if( parts.escaped_parameter_string > parts.escaped_fragment_string)
         parts.escaped_parameter_string = NULL;
      if( parts.escaped_query_string > parts.escaped_fragment_string)
         parts.escaped_query_string = NULL;
   }

   // calc lengths
   // calc length of path
   {
      if( parts.escaped_parameter_string)
         end = parts.escaped_parameter_string;
      else
         if( parts.escaped_query_string)
            end = parts.escaped_query_string;
         else
            if( parts.escaped_fragment_string)
               end = parts.escaped_fragment_string;
            else
               end = &utf[ length];

      parts.escaped_path_string_len = end - utf;
      if( parts.escaped_path_string_len) // 4 beauty
         parts.escaped_path_string = utf;
   }

   if( parts.escaped_parameter_string)
   {
      if( parts.escaped_query_string)
         end = parts.escaped_query_string;
      else
         if( parts.escaped_fragment_string)
            end = parts.escaped_fragment_string;
         else
            end = &utf[ length];

      parts.escaped_parameter_string++;
      parts.escaped_parameter_string_len = end - parts.escaped_parameter_string;
   }

   if( parts.escaped_query_string)
   {
      if( parts.escaped_fragment_string)
         end = parts.escaped_fragment_string;
      else
         end = &utf[ length];

      parts.escaped_query_string++;
      parts.escaped_query_string_len = end - parts.escaped_query_string;
   }

   if( parts.escaped_fragment_string)
   {
      end = &utf[ length];

      parts.escaped_fragment_string++;
      parts.escaped_fragment_string_len = end - parts.escaped_fragment_string;
   }

   return( [self mulleInitWithEscapedURLPartsUTF8:&parts
                              allowedCharacterSet:[NSURL mulleURLEscapedAllowedCharacterSet]]);
}


- (instancetype) initWithString:(NSString *) s
{
   NSUInteger     length;
   mulle_utf8_t   *utf8;

   NSParameterAssert( ! s || [s isKindOfClass:[NSString class]]);

   length = [s mulleUTF8StringLength];
   utf8   = (mulle_utf8_t *) [s UTF8String];

   return( [self mulleInitWithUTF8Characters:utf8
                                      length:length]);
}


- (instancetype) initWithString:(NSString *) string
                  relativeToURL:(NSURL *) baseURL
{
   NSURL             *url;
   NSString          *path;
   NSMutableArray    *components;
   NSArray           *array;

   NSParameterAssert( ! baseURL || [baseURL isKindOfClass:[NSURL class]]);

   self = [self initWithString:string];
   if( ! self || ! baseURL)
      return( self);

   if( _scheme)
      return( self);

   _scheme = [baseURL->_scheme copy];

   if( ! _escapedHost)
   {
      assert( ! _escapedUser);
      assert( ! _escapedPassword);

      _escapedUser     = [baseURL->_escapedUser copy];
      _escapedPassword = [baseURL->_escapedPassword copy];
      _escapedHost     = [baseURL->_escapedHost copy];
      _port            = [baseURL->_port copy];
   }

   //
   // if path is empty we only merge from baseURL until we have something
   //
   if( ! _escapedPath)
   {
      _escapedPath = [baseURL->_escapedPath copy];
      if( ! _escapedParameterString)
      {
         _escapedParameterString = [baseURL->_escapedParameterString copy];
         if( ! _escapedQuery)
         {
            _escapedQuery = [baseURL->_escapedQuery copy];
            if( ! _escapedFragment)
               _escapedFragment = [baseURL->_escapedFragment copy];
         }
      }
      return( self);
   }

   // otherwise merge paths, if relative
   if( [_escapedPath hasPrefix:@"/"]) // don't concat if absolute
      return( self);

   array      = [baseURL->_escapedPath componentsSeparatedByString:MulleURLPathComponentSeparator];
   components = [NSMutableArray arrayWithArray:array];

   // get rid of '/' or overwritten last component, except if only entry (/)
   if( [components count] > 1)
      [components removeLastObject];

   array      = [_escapedPath componentsSeparatedByString:MulleURLPathComponentSeparator];
   [components addObjectsFromArray:array];

   [_escapedPath autorelease];
   _escapedPath = [[components componentsJoinedByString:MulleURLPathComponentSeparator] copy];

   return( self);
}



- (void) dealloc
{
   [_scheme release];
   [_escapedUser release];
   [_escapedPassword release];
   [_escapedHost release];
   [_port release];
   [_escapedPath release];
   [_escapedParameterString release];
   [_escapedQuery release];
   [_escapedFragment release];

   [super dealloc];
}



// we are immutable...
- (id) copy
{
   return( [self retain]);
}


/*
 * Convert to string
 */

- (NSString *) mulleGenericResourceSpecifierDescription
{
   NSMutableString   *result;

   //
   // not sure what to do if baseURL has a resourceSpecifier
   //
   result = [NSMutableString string];

   if( _escapedPath)
      [result appendString:_escapedPath];

   if( _escapedParameterString)
   {
      [result appendString:@";"];
      [result appendString:_escapedParameterString];
   }

   if( _escapedQuery)
   {
      [result appendString:@"?"];
      [result appendString:_escapedQuery];
   }

   if( _escapedFragment)
   {
      [result appendString:@"#"];
      [result appendString:_escapedFragment];
   }
   return( result);
}


//
// <image url="https://en.wikipedia.org/wiki/File:URI_syntax_diagram.svg">
//
- (NSString *) mulleGenericURLDescription
{
   NSMutableString   *result;
   NSString          *uri;

   result = [NSMutableString string];

   if( _scheme)
   {
      [result appendString:_scheme];
      [result appendString:@":"];
   }

   // The URL syntax is dependent upon the scheme.!
   // If the "//" are printed or not
   // e.g. file:///etc/passwd has always a host component, even if empty
   // but mailto:user@foo.com doesn't.
   //
   // It's easier for printing if we allow "host" as nil and @"", which in
   // turn will print either http:/foo.com/x.html or http://foo.com/x.html
   // authority
   //

   if( _escapedHost)
   {
      [result appendString:@"//"];

      if( _escapedUser)
      {
         [result appendString:_escapedUser];

         if( _escapedPassword)
         {
            [result appendString:@":"];
            [result appendString:_escapedPassword];
         }

         [result appendString:@"@"];
      }

      [result appendString:_escapedHost];

      if( _port)
      {
         [result appendString:@":"];
         [result appendString:[_port description]];
      }
   }

   uri = [self mulleEscapedResourceSpecifier];
   [result appendString:uri];

   return( result);
}


- (NSString *) description
{
   SEL                            print;
   NSString                       *s;
   struct MulleURLSchemeHandler   *handler;

   handler = lookupHandlerForScheme( _scheme);
   print   = handler ? handler->printURL : @selector( mulleGenericURLDescription);
   s       = [self performSelector:print];
   return( s);
}


- (NSString *) mulleEscapedResourceSpecifier
{
   SEL                            print;
   NSString                       *s;
   struct MulleURLSchemeHandler   *handler;

   handler = lookupHandlerForScheme( _scheme);
   print   = handler ? handler->printResourceSpecifier
                     : @selector( mulleGenericResourceSpecifierDescription);
   s       = [self performSelector:print];
   return( s);
}



#pragma mark - unescaping accessors

//
// This property contains the path, unescaped using the
// stringByReplacingPercentEscapesUsingEncoding: method. If the receiver does
// not conform to RFC 1808, this property contains nil.
//
- (NSString *) scheme
{
   return( _scheme);
}


- (NSNumber *) port
{
   return( _port);
}

- (NSString *) user
{
   return( [_escapedUser stringByRemovingPercentEncoding]);
}


- (NSString *) password
{
   return( [_escapedPassword stringByRemovingPercentEncoding]);
}


- (NSString *) host
{
   return( [_escapedHost stringByRemovingPercentEncoding]);
}


- (NSString *) path
{
   return( [_escapedPath stringByRemovingPercentEncoding]);
}


- (NSString *) parameterString
{
   return( [_escapedParameterString stringByRemovingPercentEncoding]);
}


- (NSString *) query
{
   return( [_escapedQuery stringByRemovingPercentEncoding]);
}


- (NSString *) fragment
{
   return( [_escapedFragment stringByRemovingPercentEncoding]);
}


- (NSString *) resourceSpecifier
{
   return( [[self mulleEscapedResourceSpecifier] stringByRemovingPercentEncoding]);
}


/*
 * For compatibility some methods operating on path
 */

//
// can't reuse NSString code, because it might have different separator
// characters
//
static NSRange  getLastPathComponentRange( NSString *self)
{
   return( [self rangeOfString:MulleURLPathComponentSeparator
                       options:NSBackwardsSearch]);
}


static NSRange  getPathExtensionRange( NSString *self)
{
   NSRange   range1;
   NSRange   range2;

   range1 = getLastPathComponentRange( self);
   if( range1.length == 0)
      return( range1);

   range2 = [self rangeOfString:MulleURLPathExtensionSeparator
                        options:NSBackwardsSearch];
   if( range2.length && range1.location < range2.location)
      return( NSMakeRange( NSNotFound, 0));

   return( range1);
}


- (NSArray *) pathComponents
{
   return( [[self path] componentsSeparatedByString:MulleURLPathComponentSeparator]);
}


- (NSString *) lastPathComponent
{
   NSRange   range;
   NSString  *path;

   path  = [self path];
   range = getLastPathComponentRange( path);
   if( ! range.length)
      return( path);

   return( [path substringFromIndex:range.location + 1]);
}


- (NSString *) pathExtension
{
   NSRange    range;
   NSString   *path;

   path  = [self path];
   range = getPathExtensionRange( path);
   if( ! range.length)
      return( nil);
   return( [path substringFromIndex:range.location + 1]);
}



#pragma mark - obsolete stuff

- (NSURL *) standardizedURL
{
   return( self);
}


- (NSString *) absoluteString
{
   return( [self description]);
}


- (NSURL *) absoluteURL
{
   return( self);
}


- (NSString *) relativePath
{
   return( [self path]);
}


- (NSString *) relativeString
{
   if( [self mulleIsAbsolutePath])
      return( [self absoluteString]);
   return( [self mulleEscapedResourceSpecifier]);
}


- (NSURL *) baseURL
{
   return( nil);
}



#pragma mark - queries

- (BOOL) isFileURL
{
   return( [_scheme isEqualToString:@"file"]);
}


- (BOOL) mulleIsAbsolutePath
{
   return( [_escapedPath hasPrefix:MulleURLPathComponentSeparator]);
}


#if DEBUG
- (void) mulleDump
{
   char  *s;

   fprintf( stderr, "Scheme    : %p %s\n", _scheme,          (s = [_scheme cStringDescription]) ? s : "*nil*");
   fprintf( stderr, "User      : %p %s\n", _escapedUser,     (s = [_escapedUser cStringDescription]) ? s : "*nil*");
   fprintf( stderr, "Password  : %p %s\n", _escapedPassword, (s = [_escapedPassword cStringDescription]) ? s : "*nil*");
   fprintf( stderr, "Host      : %p %s\n", _escapedHost,     (s = [_escapedHost cStringDescription]) ? s : "*nil*");
   fprintf( stderr, "Port      : %p %ld\n",_port,     [_port longValue]);
   fprintf( stderr, "Path      : %p %s\n", _escapedPath,     (s = [_escapedPath cStringDescription]) ? s : "*nil*");
   fprintf( stderr, "Parameter : %p %s\n", _escapedParameterString,  (s = [_escapedParameterString cStringDescription]) ? s : "*nil*");
   fprintf( stderr, "Query     : %p %s\n", _escapedQuery,    (s = [_escapedQuery cStringDescription]) ? s : "*nil*");
   fprintf( stderr, "Fragment  : %p %s\n", _escapedFragment, (s = [_escapedFragment cStringDescription]) ? s : "*nil*");
}
#endif

@end
