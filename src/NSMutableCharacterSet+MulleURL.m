#import "NSMutableCharacterSet+MulleURL.h"

#import "import-private.h"



@implementation NSMutableCharacterSet ( MulleURL)


static id   construct( SEL _cmd)
{
   NSCharacterSet          *tmp;
   NSData                  *data;
   NSMutableCharacterSet   *set;

   tmp  = [NSCharacterSet performSelector:_cmd];
   data = [tmp bitmapRepresentation];
   set  = [[[NSMutableCharacterSet alloc] initWithBitmapRepresentation:data] autorelease];
   return( set);
}


+ (instancetype) URLFragmentAllowedCharacterSet
{
   return( construct( _cmd));
}


+ (instancetype) URLHostAllowedCharacterSet
{
   return( construct( _cmd));
}


+ (instancetype) URLPasswordAllowedCharacterSet
{
   return( construct( _cmd));
}


+ (instancetype) URLPathAllowedCharacterSet
{
   return( construct( _cmd));
}


+ (instancetype) URLQueryAllowedCharacterSet
{
   return( construct( _cmd));
}


+ (instancetype) URLUserAllowedCharacterSet
{
   return( construct( _cmd));
}


+ (instancetype) mulleNonPercentEscapeCharacterSet
{
   return( construct( _cmd));
}


+ (instancetype) mulleURLAllowedCharacterSet
{
   return( construct( _cmd));
}


+ (instancetype) mulleURLSchemeAllowedCharacterSet
{
   return( construct( _cmd));
}

@end
