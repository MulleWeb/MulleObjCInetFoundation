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


static void   test( NSString *baseURLString)
{
   NSString   *string;
   NSURL      *baseURL;

   baseURL = [NSURL URLWithString:baseURLString];
   if( ! baseURL)
   {
      printf( "baseURL %s is invalid\n", [baseURLString UTF8String]);
      return;
   }

   string = @"http://"
             "user:password"
             "@host:32765"
             "/path"
             ";parameter"
             "?query"
             "#fragment";
   run_test( baseURL, string);

   string  = @"/rel_path/foo.html"
              "#fragment";
   run_test( baseURL, string);

   string = @"rel_path/bar.html"
             ";parameter"
             "#fragment";
   run_test( baseURL, string);

   string = @";parameter";
   run_test( baseURL, string);
}


int   main(int argc, const char * argv[])
{
   NSString   *string;

#ifdef __MULLE_OBJC__
   struct _mulle_objc_universe   *universe;

   universe = mulle_objc_global_get_universe( __MULLE_OBJC_UNIVERSEID__);
   universe->debug.count_stackdepth = mulle_stacktrace_count_frames;
#endif

   string = @"http://"
            "base-user:base-password"
            "@base-host:80"
            "/base-path/"
            ";base-parameter"
            "?base-query"
            "#base-fragment";

   test( string);

   string = @"http://"
             "base-host:80"
             "/base-path"
             "?base-query"
             "#base-fragment";
   test( string);

   return 0;
}


