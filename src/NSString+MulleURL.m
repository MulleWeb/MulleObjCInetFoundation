#import "NSString+MulleURL.h"

#import "NSCharacterSet+MulleURL.h"

#import "import-private.h"



@implementation NSString ( MulleURL)


- (NSString *) stringByAddingPercentEscapesUsingEncoding:(NSStringEncoding) encoding
{
   NSCharacterSet   *characterSet;

   NSAssert( encoding == NSUTF8StringEncoding, @"only suppports NSUTF8StringEncoding");
   characterSet = [NSCharacterSet mulleNonPercentEscapeCharacterSet];
   return( [self stringByAddingPercentEncodingWithAllowedCharacters:characterSet]);
}


- (NSString *) stringByReplacingPercentEscapesUsingEncoding:(NSStringEncoding) encoding
{
   NSCharacterSet   *characterSet;

   NSAssert( encoding == NSUTF8StringEncoding, @"only suppports NSUTF8StringEncoding");
   characterSet = [NSCharacterSet mulleNonPercentEscapeCharacterSet];
   return( [self mulleStringByReplacingPercentEscapesWithDisallowedCharacters:characterSet]);
}

@end
