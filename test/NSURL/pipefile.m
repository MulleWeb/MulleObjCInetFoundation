//
//  main.m
//  archiver-test
//
//  Created by Nat! on 19.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#ifdef __MULLE_OBJC__
# import <MulleObjCInetFoundation/MulleObjCInetFoundation.h>
#else
# import <Foundation/Foundation.h>
#endif

//#import "MulleStandaloneObjCFoundation.h"

char  *safe_string( char *s)
{
   return( s ? s : "*null*");
}


int main( int argc, const char * argv[])
{
   NSURL   *url;
   char    *a, *b;

   url = [NSURL URLWithString:@"/|.scion"];
   if( url)
   {
      a = safe_string( [[url host] UTF8String]);
      b = safe_string( [[url path] UTF8String]);
      printf( "host:%s path:%s\n", a, b);
   }
   else
      printf( "invalid #1\n");

   url = [NSURL URLWithString:@"|.scion"];
   if( url)
   {
      a = safe_string( [[url host] UTF8String]);
      b = safe_string( [[url path] UTF8String]);
      printf( "host:%s path:%s\n", a, b);
   }
   else
      printf( "invalid #2\n");

   return( 0);
}
