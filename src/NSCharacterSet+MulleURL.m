#import "NSCharacterSet+MulleURL.h"

#import "import-private.h"

#import <MulleObjCStandardFoundation/_MulleObjCConcreteCharacterSet.h>


@implementation NSCharacterSet ( MulleURL)

+ (instancetype) URLFragmentAllowedCharacterSet
{
   return( [[_MulleObjCConcreteCharacterSet newWithMemberFunction:mulle_unicode_is_validurlfragment
                                                    planeFunction:mulle_unicode_is_validurlfragmentplane
                                                           invert:NO] autorelease]);
}


+ (instancetype) URLHostAllowedCharacterSet
{
   return( [[_MulleObjCConcreteCharacterSet newWithMemberFunction:mulle_unicode_is_validurlhost
                                                    planeFunction:mulle_unicode_is_validurlhostplane
                                                           invert:NO] autorelease]);
}


+ (instancetype) URLPasswordAllowedCharacterSet
{
   return( [[_MulleObjCConcreteCharacterSet newWithMemberFunction:mulle_unicode_is_validurlpassword
                                                    planeFunction:mulle_unicode_is_validurlpasswordplane
                                                           invert:NO] autorelease]);
}


+ (instancetype) URLPathAllowedCharacterSet
{
   return( [[_MulleObjCConcreteCharacterSet newWithMemberFunction:mulle_unicode_is_validurlpath
                                                    planeFunction:mulle_unicode_is_validurlpathplane
                                                           invert:NO] autorelease]);
}


+ (instancetype) URLQueryAllowedCharacterSet
{
   return( [[_MulleObjCConcreteCharacterSet newWithMemberFunction:mulle_unicode_is_validurlquery
                                                    planeFunction:mulle_unicode_is_validurlqueryplane
                                                           invert:NO] autorelease]);
}


+ (instancetype) URLUserAllowedCharacterSet
{
   return( [[_MulleObjCConcreteCharacterSet newWithMemberFunction:mulle_unicode_is_validurluser
                                                    planeFunction:mulle_unicode_is_validurluserplane
                                                           invert:NO] autorelease]);
}

// be sure to duplicate these in NSMutableCharacterSet

+ (instancetype) mulleURLAllowedCharacterSet
{
   // https://en.wikipedia.org/wiki/Percent-encoding#Types_of_URI_characters
   return( [self characterSetWithCharactersInString:@"!*'();:@&=+$,/?#[]"
      "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      "abcdefghijklmnopqrstuvwxyz"
      "0123456789-_.~" ]);
}



+ (instancetype) mulleURLSchemeAllowedCharacterSet
{
   return( [[_MulleObjCConcreteCharacterSet newWithMemberFunction:mulle_unicode_is_validurlscheme
                                                    planeFunction:mulle_unicode_is_validurlschemeplane
                                                           invert:NO] autorelease]);
}


+ (instancetype) mulleNonPercentEscapeCharacterSet
{
   return( [[_MulleObjCConcreteCharacterSet newWithMemberFunction:mulle_unicode_is_nonpercentescape
                                                    planeFunction:mulle_unicode_is_nonpercentescapeplane
                                                           invert:NO] autorelease]);
}



@end
