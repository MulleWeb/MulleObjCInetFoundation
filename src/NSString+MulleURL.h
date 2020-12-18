// prefer a local NSString over one in import.h
#ifdef __has_include
# if __has_include( "NSString.h")
#  import "NSString.h"
# endif
#endif

// we wan't "import.h" always anyway
#import "import.h"


@interface NSString( MulleURL)

- (NSString *) stringByAddingPercentEscapesUsingEncoding:(NSStringEncoding) encoding;
- (NSString *) stringByReplacingPercentEscapesUsingEncoding:(NSStringEncoding) encoding;


@end
