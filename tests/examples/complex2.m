//
//  main.m
//  archiver-test
//
//  Created by Nat! on 19.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//


#import <MulleStandaloneObjCExpatFoundation/MulleStandaloneObjCExpatFoundation.h>
//#import "MulleStandaloneObjCFoundation.h"


//
// Dates can not be tested, because we need the POSIX Foundation or the
// equivalent, which provides the NSDateFormatter functionality
//

static char   test_xml[] = "\
<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\"\n\
                       \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n\
<plist version=\"1.0\">\n\
<dict>\n\
   <key>Club</key>\n\
   <array>\n\
      <dict>\n\
         <key>name</key>\n\
         <string>VfL Bochum 1848</string>\n\
      </dict>\n\
   </array>\n\
   <key>Liga</key>\n\
   <array>\n\
      <dict>\n\
         <key>clubs</key>\n\
         <array>\n\
            <dict>\n\
               <key>name</key>\n\
               <string>VfL Bochum 1848</string>\n\
            </dict>\n\
         </array>\n\
         <key>name</key>\n\
         <string>2. Liga</string>\n\
      </dict>\n\
      <dict>\n\
         <key>name</key>\n\
         <string>Bundesliga</string>\n\
         <key>clubs</key>\n\
         <array/>\n\
      </dict>\n\
   </array>\n\
</dict>\n\
</plist>";



int   main( int argc, const char * argv[])
{
   NSData    *data;
   NSError   *error;
   id        plist;

   error = nil;
   data  = [NSData dataWithBytes:test_xml
                          length:sizeof( test_xml)];
   plist = [NSPropertyListSerialization propertyListFromData:data
                                            mutabilityOption:NSPropertyListImmutable
                                                      format:NULL
                                            errorDescription:&error];
   if( ! plist)
      NSLog( @"Error: %@", error);
   else
      NSLog( @"Plist: %@", plist);

   return( 0);
}
