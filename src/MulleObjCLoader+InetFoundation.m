//
//  MulleObjCLoader+InetFoundation.m
//  MulleObjCInetFoundation
//
//  Created by Nat! on 11.05.17.
//
//

#import "MulleObjCLoader+InetFoundation.h"

@implementation MulleObjCLoader( InetFoundation)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( Foundation) },

      { @selector( NSHost), MULLE_OBJC_NO_CATEGORYID },
      { @selector( NSURL), MULLE_OBJC_NO_CATEGORYID },
      { @selector( NSString), @selector( NSHost) },
      { MULLE_OBJC_NO_CLASSID, MULLE_OBJC_NO_CATEGORYID }
   };

   return( dependencies);
}

@end
