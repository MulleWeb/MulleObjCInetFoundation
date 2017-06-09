//
//  main.m
//  archiver-test
//
//  Created by Nat! on 19.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//


#import <MulleObjCRegexFoundation/MulleObjCRegexFoundation.h>
//#import "MulleStandaloneObjCFoundation.h"


//
// Dates can not be tested, because we need the POSIX Foundation or the
// equivalent, which provides the NSDateFormatter functionality
//

static char   test_xml[] = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n\
<plist version=\"1.0\">\n\
<dict>\n\
   <key>name</key>\n\
   <string>VfL Bochum 1848</string>\n\
   <key>count</key>\n\
   <integer>2</integer>\n\
   <key>test</key>\n\
   <string>Test</string>\n\
   <key>deep</key>\n\
   <array>\n\
      <dict>\n\
         <key>name</key>\n\
         <string>VfL</string>\n\
      </dict>\n\
   </array>\n\
   <key>list</key>\n\
   <array>\n\
      <string>0 (value)</string>\n\
      <string>1 (value)</string>\n\
   </array>\n\
   <key>bag</key>\n\
   <dict>\n\
      <key>a</key>\n\
      <string>a (value)</string>\n\
      <key>b</key>\n\
      <string>b (value)</string>\n\
   </dict>\n\
</dict>\n\
</plist>\n\
";



int   main( int argc, const char * argv[])
{
   NSData    *data;
   NSString  *error;
   id        plist;

   error = nil;
   data  = [NSData dataWithBytes:test_xml
                          length:sizeof( test_xml)];
   plist = [NSPropertyListSerialization propertyListFromData:data
                                            mutabilityOption:NSPropertyListImmutable
                                                      format:NULL
                                            errorDescription:&error];
   if( ! plist)
      fprintf( stderr, "Error: %s\n", [error UTF8String]);
   else
      printf( "Plist: %s\n", [[plist description] UTF8String]);

   return( 0);
}
