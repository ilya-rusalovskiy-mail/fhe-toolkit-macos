//
//  FHEBitwiseObject.m
//  Bitwise operations
//
//  Created by mac1 on 11.09.2023.
//  Copyright © 2023 IBM. All rights reserved.
//

#import "FHEBitwiseObject.h"
#import "FHEManager.h"
#include <iostream>
#include "helayers/hebase/hebase.h"
#include "helayers/hebase/helib/HelibBgvContext.h"
#include <fstream>
#include <helib/helib.h>
#include <helib/EncryptedArray.h>
#include <helib/ArgMap.h>
#include <NTL/BasicThreadPool.h>

using namespace helayers;
using namespace std;

@interface FHEBitwiseObject()
{
    vector<CTile> encryptedBits;
}

@end

@implementation FHEBitwiseObject

- (instancetype)initWithBits:(NSArray *)bits {
    self = [super init];
    [[FHEManager sharedObject] encryptNumberBits:bits result:&encryptedBits];
    return self;
}

- (NSArray *)decrypt {
    return [[FHEManager sharedObject] decryptNumberBits:&encryptedBits];
}

- (vector<CTile>)getEncryptedBits {
    return encryptedBits;
}

- (void)summWithOther:(FHEBitwiseObject *)other {
    Encoder encoder(*[self getHe]);
    // TODO: use 0 for ADD and 1 for DIFF
    CTile f(*[self getHe]);
    encoder.encodeEncrypt(f, vector<int>{0});
    CTile a(*[self getHe]);
    CTile b(*[self getHe]);
    CTile p = f;
    
    CTile overflowBit(*[self getHe]);
    vector<CTile> result;
    for(int i = int(encryptedBits.size()) - 1; i >= 0; i--) {
        // initial setup
        a = encryptedBits[i];
        b = [other getEncryptedBits][i];
        b.add(f);

        // XOR-AND single bit adder
        CTile aXorB = a;
        aXorB.add(b);

        CTile aAndB = a;
        aAndB.multiply(b);

        CTile c = aXorB;
        c.add(p);
        // result bit
        result.push_back(c);

        aXorB.multiply(p);
        aXorB.add(aAndB);
        if (i == 0) {
            // last iteration - iteration over sign bits
            // calculate overflow bit
            // ref: https://www.geeksforgeeks.org/overflow-in-arithmetic-addition-in-binary-number-system/
            overflowBit = p;
            overflowBit.add(aXorB);
        }
        // carry bit
        p = aXorB;
    }
    reverse(result.begin(), result.end());
    encryptedBits = result;
}

- (HelibBgvContext *)getHe {
    return [[FHEManager sharedObject] getContext];
}

@end
