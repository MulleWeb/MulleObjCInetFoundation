//
//  MulleObjCInetFoundation.h
//  MulleObjCInetFoundation
//
//  Created by Nat! on 04.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#import "import.h"

#define MULLE_OBJC_INET_FOUNDATION_VERSION  ((0 << 20) | (13 << 8) | 0)

#import "NSURL.h"
#import "NSHost.h"

#import "MulleObjCLoader+MulleObjCInetFoundation.h"

// export nothing with _MulleObjC
#if MULLE_OBJC_STANDARD_FOUNDATION_VERSION < ((0 << 20) | (13 << 8) | 0)
# error "MulleObjCStandardFoundation is too old"
#endif
