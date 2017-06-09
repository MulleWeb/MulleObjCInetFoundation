//
//  NSHost.h
//  MulleObjCCAresFoundation
//
//  Created by Nat! on 9/8/16
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import <MulleObjCFoundation/MulleObjCFoundation.h>


//
// NSHost is lazy
// a resolver library needs to be added to actually have some
// lookup functionality here
//
@interface NSHost : NSObject
{
   NSLock   *_lock;
}

@property( nonatomic, readonly, copy) NSArray  *names;
@property( nonatomic, readonly, copy) NSArray  *addresses;
@property( nonatomic, readonly) BOOL  _IP6;
@property( nonatomic, readonly) BOOL  _isCurrentHost;

+ (instancetype) hostWithName:(NSString *) name;
+ (instancetype) hostWithAddress:(NSString *) address;

- (BOOL) isEqualToHost:(NSHost *) other;

- (NSString *) name;
- (NSString *) address;

@end


@interface NSHost( Future)

+ (instancetype) currentHost;
- (NSString *) localizedName;

@end
