// prefer a local NSCharacterSet over one in import.h
#ifdef __has_include
# if __has_include( "NSCharacterSet.h")
#  import "NSCharacterSet.h"
# endif
#endif

// we wan't "import.h" always anyway
#import "import.h"


@interface NSCharacterSet( MulleURL)

+ (instancetype) URLFragmentAllowedCharacterSet;
+ (instancetype) URLHostAllowedCharacterSet;
+ (instancetype) URLPasswordAllowedCharacterSet;
+ (instancetype) URLPathAllowedCharacterSet;
+ (instancetype) URLQueryAllowedCharacterSet;
+ (instancetype) URLUserAllowedCharacterSet;

+ (instancetype) mulleURLAllowedCharacterSet;
+ (instancetype) mulleURLSchemeAllowedCharacterSet;
+ (instancetype) mulleNonPercentEscapeCharacterSet;

@end
