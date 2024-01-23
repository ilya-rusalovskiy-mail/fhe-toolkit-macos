//
//  FHEManager.m
//  Bitwise operations
//
//  Created by mac1 on 08.09.2023.
//  Copyright © 2023 IBM. All rights reserved.
//

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

@interface FHEManager()


@end

@implementation FHEManager

// Note: These parameters have been chosen to provide fast running times as
// opposed to a realistic security level. As well as negligible security,
// these default parameters result in an algebra with only 10 slots which limits
// the size of both the “keys” and “values” to 10 chars. If you try to use
// bigger “keys” or “values” you will need to choose different parameters
// that give you more slots, otherwise the code will throw an
// "helib::OutOfRangeError" exception.
//
// Commented below there is the parameter "m-130" which will result in an algebra
// with 48 slots, thus allowing for “keys” and “values” up to 48 chars.

// Plaintext prime modulus
unsigned long p = 2;
// Cyclotomic polynomial - defines phi(m)
unsigned long m = 3; // this will give 1 slot
// Hensel lifting (default = 1)
unsigned long r = 1;
// Number of bits of the modulus chain
unsigned long bits = 1000;
// Number of columns of Key-Switching matrix (default = 2 or 3)
unsigned long c = 2;
// Size of NTL thread pool (default =1)
unsigned long nthreads = 12;
// debug output (default no debug output)
unsigned long debug = 1;

+ (instancetype)sharedObject {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // set NTL Thread pool size
        if (nthreads > 1) {
            NTL::SetNumThreads(nthreads);
        }
        
        // To setup helib using the hebase layer, let's first
        // copy all configuration params to an HelibConfig object:
        HelibConfig conf;
        conf.p = p;
        conf.m = m;
        conf.r = r;
        conf.L = bits;
        conf.c = c;
        
        // Next we'll initialize a BGV scheme in helib.
        // The following two lines perform full intializiation
        // Including key generation.
        he.init(conf);
        
        cout << "\nNumber of slots: " << he.slotCount() << endl;
    }
    return self;
}

- (void)encryptNumberBits:(NSArray *)bits result:(std::vector<helayers::CTile> *)result {
    Encoder encoder(he);
    for (NSNumber *bit in bits) {
        CTile encryptedBit(he);
        PTile encodedBit(he);
        encoder.encode(encodedBit, [bit intValue]);
        encoder.encrypt(encryptedBit, encodedBit);
        (*result).push_back(encryptedBit);
    }
}

- (NSArray *)decryptNumberBits:(std::vector<helayers::CTile> *)bits {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    Encoder encoder(he);
    for (const auto& bit : *bits) {
        int resultBit = encoder.decryptDecodeInt(bit)[0];
        [result addObject:@(resultBit)];
    }
    return result;
}

- (helayers::HelibBgvContext *)getContext {
    return &he;
}

- (void)invertBit:(CTile)bit {
    Encoder encoder(*[self getContext]);
    // helper bit to inverse encrypted bits
    CTile inverseBit(*[self getContext]);
    encoder.encodeEncrypt(inverseBit, vector<int>{1});
    bit.add(inverseBit);
}

@end
