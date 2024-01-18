//
//  FHEBitwiseObject.m
//  Bitwise operations
//
//  Created by mac1 on 11.09.2023.
//  Copyright © 2023 IBM. All rights reserved.
//

#import "FHEBitwiseObject.h"
#import "FHEManager.h"
#import "Bitwise_operations-Swift.h"
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

- (instancetype)initWithEncriptedBits:(vector<CTile>)bits {
    self = [super init];
    encryptedBits = bits;
    return self;
}

- (NSArray *)decrypt {
    return [[FHEManager sharedObject] decryptNumberBits:&encryptedBits];
}

- (vector<CTile>)getEncryptedBits {
    return encryptedBits;
}

- (void)multiplyWithBit:(CTile)bit {
    for(int i = 0; i < encryptedBits.size(); i++) {
        encryptedBits[i].multiply(bit);
    }
}

- (void)rShiftPositions:(int)positions {
    if (positions < 1) {
        // do nothing
        return;
    }
    CTile signBit = encryptedBits[0];
    for(int i = 0; i < positions; i++) {
        encryptedBits.pop_back();
        encryptedBits.insert(encryptedBits.begin(), signBit);
    }
}

- (void)lShiftPositions:(int)positions {
    if (positions < 1) {
        // do nothing
        return;
    }
    Encoder encoder(*[self getHe]);
    CTile additionalBit(*[self getHe]);
    encoder.encodeEncrypt(additionalBit, vector<int>{0});
    for(int i = 0; i < positions; i++) {
        encryptedBits.erase(encryptedBits.begin());
        encryptedBits.insert(encryptedBits.end(), additionalBit);
    }
}

- (void)multiplyWithOther:(FHEBitwiseObject *)other {
    Encoder encoder(*[self getHe]);
    FHEBitwiseObject *result = [[FHEBitwiseObject alloc] initWithBits:[@0 binaryRepresentationWith:encryptedBits.size()]];
    CTile additionalBit(*[self getHe]);
    encoder.encodeEncrypt(additionalBit, vector<int>{0});
    vector<CTile> otherBits = other.getEncryptedBits;
    otherBits.insert(otherBits.end(), additionalBit);
    for(int i = int(otherBits.size()) - 2; i >= 0; i--) {
        CTile bCurrent = otherBits[i];
        CTile bNext = otherBits[i+1];
        // bi xor bi-1
        CTile coeff = bCurrent;
        coeff.add(bNext);
        // (A and (bi xor bi-1)) << i-1
        FHEBitwiseObject *partSumm = [[FHEBitwiseObject alloc] initWithEncriptedBits:encryptedBits];
        [partSumm multiplyWithBit:coeff];
        [partSumm lShiftPositions:int(otherBits.size()) - 2 - i];
        // F = (bi xor bi-1) AND bi
        coeff.multiply(bCurrent);
        [result summOrDiffWithOther:partSumm encMode:coeff];
    }
    encryptedBits = result.getEncryptedBits;
}

- (void)divideByOther:(FHEBitwiseObject *)other {
    
}

- (void)diffOther:(FHEBitwiseObject *)other {
    [self summOrDiffWithOther:other mode:1];
}

- (void)summWithOther:(FHEBitwiseObject *)other {
    [self summOrDiffWithOther:other mode:0];
}

- (void)summOrDiffWithOther:(FHEBitwiseObject *)other mode:(int)mode {
    Encoder encoder(*[self getHe]);
    CTile f(*[self getHe]);
    encoder.encodeEncrypt(f, vector<int>{mode});
    [self summOrDiffWithOther:other encMode:f];
}

- (void)summOrDiffWithOther:(FHEBitwiseObject *)other encMode:(CTile)f {
    Encoder encoder(*[self getHe]);
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
