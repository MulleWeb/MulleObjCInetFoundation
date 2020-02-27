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

static void   run_test( NSURL *baseURL, NSString *string)
{
   NSURL      *URL;
   NSString   *result;

   URL = [NSURL URLWithString:string
                relativeToURL:baseURL];
   result = [URL absoluteString];
   if( ! URL && ! [NSURL URLWithString:string])
      result = @"relative is invalid";

   printf( "%s (base)\n + %s (relative)\n-> %s\n\n", [[baseURL absoluteString] UTF8String],
                                   [string UTF8String],
                                   [result UTF8String]);
}


static void   test( NSURL *baseURL)
{
   NSString   *string;

   string = @"file://"
             "host:32765"
             "/path";
   run_test( baseURL, string);

   string  = @"/rel_path/foo.html";
   run_test( baseURL, string);

   string = @"rel_path/bar.html";
   run_test( baseURL, string);
}


int   main(int argc, const char * argv[])
{
   NSURL   *baseURL;

#ifdef __MULLE_OBJC__
   struct _mulle_objc_universe   *universe;

   universe = mulle_objc_global_get_universe( __MULLE_OBJC_UNIVERSEID__);
   universe->debug.count_stackdepth = mulle_stacktrace_count_frames;
#endif

   baseURL = [NSURL URLWithString:@"file://"
                                  "base-host"
                                  "/base-path/"];
   test( baseURL);

   baseURL = [NSURL URLWithString:@"file://"
                                  "base-host"
                                  "/base-path"];
   test( baseURL);

   return 0;
}


