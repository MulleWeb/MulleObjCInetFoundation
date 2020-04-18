// prefer a local NSMutableCharacterSet over one in import.h
#ifdef __has_include
# if __has_include( "NSMutableCharacterSet.h")
#  import "NSMutableCharacterSet.h"
# endif
#endif

// we wan't "import.h" always anyway
#import "import.h"


@interface NSMutableCharacterSet( MulleURL)
@end
