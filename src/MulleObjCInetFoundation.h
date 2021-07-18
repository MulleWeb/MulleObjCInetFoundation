//
//  MulleObjCInetFoundation.h
//  MulleObjCInetFoundation
//
//  Created by Nat! on 04.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#import "import.h"

#define MULLE_OBJC_INET_FOUNDATION_VERSION  ((0 << 20) | (18 << 8) | 1)

#import "_MulleObjCInetFoundation-export.h"

// export nothing with _MulleObjC
#if MULLE_OBJC_STANDARD_FOUNDATION_VERSION < ((0 << 20) | (17 << 8) | 0)
# error "MulleObjCStandardFoundation is too old"
#endif

