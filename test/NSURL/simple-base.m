//
//  main.m
//  NSURLTest
//
//  Created by Nat! on 24.02.20.
//  Copyright © 2020 Nat!. All rights reserved.
//
#ifdef __MULLE_OBJC__
# import <MulleObjCInetFoundation/MulleObjCInetFoundation.h>
# include <mulle-stacktrace/mulle-stacktrace.h>
#else
# import <Foundation/Foundation.h>
#endif

@interface NSObject( CStringDescription)
@end


@implementation NSObject( CStringDescription)

- (char *) cStringDescription
{
   return( [[self description] UTF8String]);
}

@end


static void   print_url( NSURL  *url)
{
   char  *s;

   printf( "Scheme            : %s\n", (s = [[url scheme] cStringDescription]) ? s : "*nil*");
   printf( "User              : %s\n", (s = [[url user] cStringDescription]) ? s : "*nil*");
   printf( "Password          : %s\n", (s = [[url password] cStringDescription]) ? s : "*nil*");
   printf( "Host              : %s\n", (s = [[url host] cStringDescription]) ? s : "*nil*");
   printf( "Port              : %ld\n",[[url port] longValue]);
   printf( "Path              : %s\n", (s = [[url path] cStringDescription]) ? s : "*nil*");
   printf( "Parameter         : %s\n", (s = [[url parameterString] cStringDescription]) ? s : "*nil*");
   printf( "Query             : %s\n", (s = [[url query] cStringDescription]) ? s : "*nil*");
   printf( "Fragment          : %s\n", (s = [[url fragment] cStringDescription]) ? s : "*nil*");
   printf( "ResourceSpecifier : %s\n", (s = [[url resourceSpecifier] cStringDescription]) ? s : "*nil*");
}


static NSURL  *test( NSURL *baseURL, NSString *string)
{
   NSURL   *url;
   char    *s;

   url = [NSURL URLWithString:string
                relativeToURL:baseURL];
#ifdef __MULLE_OBJC__
   [url mulleDump];
#endif

   printf( "String: %s baseURL: %s -> <%s> %s\n", (s = [string cStringDescription]) ? s : "*nil*",
                                                  (s = [baseURL cStringDescription]) ? s : "*nil*",
                                                  (s = [NSStringFromClass([ url class]) cStringDescription]) ? s : "*nil*",
                                                  (s = [url cStringDescription]) ? s : "*nil*");
   if( url)
      print_url( url);
   printf( "\n");
   return( url);
}


int   main( int argc, const char * argv[])
{
   NSURL   *baseURL;

#ifdef __MULLE_OBJC__
   struct _mulle_objc_universe   *universe;

   universe = mulle_objc_global_get_universe( __MULLE_OBJC_UNIVERSEID__);
   universe->debug.count_stackdepth = mulle_stacktrace_count_frames;
#endif
   @autoreleasepool {
      baseURL = [NSURL URLWithString:@"a"];
      test( baseURL, @"b");
   }
   return 0;
}


