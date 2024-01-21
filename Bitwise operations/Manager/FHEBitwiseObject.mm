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
    // remainder = [a0, a0, a0, ....]
    // remainder = [a0, ...., a1]
    // res = reminder - B
    // c0 = not(res0 xor b0)
    // c = c + 1
    Encoder encoder(*[self getHe]);
    CTile aSignBit = encryptedBits[0];
    vector<CTile> remainderBits(encryptedBits.size(), aSignBit);
    vector<CTile> resultBits;
    // helper bit to inverse encrypted bits
    CTile inverseBit(*[self getHe]);
    encoder.encodeEncrypt(inverseBit, vector<int>{1});
    
    // result sign = a0 xor b0
    CTile resultSign = aSignBit;
    resultSign.add(other.getEncryptedBits[0]);
    resultBits.push_back(resultSign);
    
    // result bits
    for(int i = 1; i < encryptedBits.size() + 1; i++) {
        remainderBits.erase(remainderBits.begin());
        if (i < encryptedBits.size()) {
            remainderBits.push_back(encryptedBits[i]);
        } else {
            CTile additionalBit(*[self getHe]);
            encoder.encodeEncrypt(additionalBit, vector<int>{0});
            remainderBits.push_back(additionalBit);
        }
        FHEBitwiseObject *remainder = [[FHEBitwiseObject alloc] initWithEncriptedBits:remainderBits];
        // diff if signs are the same, sum otherwise
        // sum mode 0, diff mode 1, so just not(r0 xor bo)
        CTile modeBit = remainder.getEncryptedBits[0];
        modeBit.add(other.getEncryptedBits[0]);
        modeBit.add(inverseBit);
        
        [remainder summOrDiffWithOther:other encMode:modeBit];
        CTile resultBit = remainder.getEncryptedBits[0];
        resultBit.add(other.getEncryptedBits[0]);
        resultBit.add(inverseBit);
        resultBits.push_back(resultBit);
        // restore remainder if needed
        // a or b = (a and b) xor a xor b
        // (a0 xor remainder0) and old_remainderBits or not(a0 xor remainder0) and new_remainderBits
        CTile notEqBit = encryptedBits[0];
        notEqBit.add(remainder.getEncryptedBits[0]);
        CTile eqBit = notEqBit;
        eqBit.add(inverseBit);
        
        vector<CTile> correctedRemainderBits;
        for(int j = 0; j < remainderBits.size(); j++) {
            CTile left = remainderBits[j];
            left.multiply(notEqBit);
            
            CTile right = remainder.getEncryptedBits[j];
            right.multiply(eqBit);
            
            CTile bit = left;
            bit.multiply(right);
            bit.add(left);
            bit.add(right);
            correctedRemainderBits.push_back(bit);
        }
        remainderBits = correctedRemainderBits;
    }
    FHEBitwiseObject *one = [[FHEBitwiseObject alloc] initWithBits:[@1 binaryRepresentationWith:resultBits.size()]];
    FHEBitwiseObject *result = [[FHEBitwiseObject alloc] initWithEncriptedBits:resultBits];
    [result summWithOther:one];
    resultBits = result.getEncryptedBits;
    resultBits.pop_back();
    encryptedBits = resultBits;
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
