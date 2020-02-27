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


int   main(int argc, const char * argv[])
{
   NSURL   *URL;

#ifdef __MULLE_OBJC__
   struct _mulle_objc_universe   *universe;

   universe = mulle_objc_global_get_universe( __MULLE_OBJC_UNIVERSEID__);
   universe->debug.count_stackdepth = mulle_stacktrace_count_frames;
#endif
   URL = [NSURL URLWithString:@"http://"
                               "user%20very%20long%20no%20tps:password%20very%20long%20no%20tps"
                               "@host:32765"
                               "/path%20very%20long%20no%20tps"
                               ";parameter%20very%20long%20no%20tps"
                               "?query%20%20very%20long%20no%20tps"
                               "#fragment%20very%20long%20no%20tps"];
   printf( "%s\n", [[URL description] UTF8String]);
   return 0;
}


