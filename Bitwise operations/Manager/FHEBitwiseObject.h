//
//  FHEBitwiseObject.h
//  Bitwise operations
//
//  Created by mac1 on 11.09.2023.
//  Copyright © 2023 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "helayers/hebase/hebase.h"

using namespace helayers;

NS_ASSUME_NONNULL_BEGIN

@interface FHEBitwiseObject : NSObject

- (instancetype)initWithBits:(NSArray *)bits;
- (NSArray *)decrypt;
- (std::vector<CTile>)getEncryptedBits;

- (void)diffOther:(FHEBitwiseObject *)other;
- (void)summWithOther:(FHEBitwiseObject *)other;
- (void)multiplyWithOther:(FHEBitwiseObject *)other;
- (void)divideByOther:(FHEBitwiseObject *)other;

@end

NS_ASSUME_NONNULL_END
