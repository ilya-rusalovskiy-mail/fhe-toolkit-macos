//
//  FHEManager.h
//  Bitwise operations
//
//  Created by mac1 on 08.09.2023.
//  Copyright © 2023 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "helayers/hebase/helib/HelibBgvContext.h"
#include "helayers/hebase/hebase.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHEManager : NSObject
{
    helayers::HelibBgvContext he;
}

+ (instancetype)sharedObject;

- (void)encryptNumberBits:(NSArray *)bits result:(std::vector<helayers::CTile> *)result;
- (NSArray *)decryptNumberBits:(std::vector<helayers::CTile> *)bits;
- (helayers::HelibBgvContext *)getContext;
- (void)invertBit:(helayers::CTile)bit;

@end

NS_ASSUME_NONNULL_END
