//
//  GaussianElimination.m
//  Bitwise operations
//
//  Created by mac1 on 21.01.2024.
//  Copyright © 2024 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GaussianElimination.h"
#import "FHEManager.h"
#import "FHEBitwiseObject.h"
#import "Bitwise_operations-Swift.h"

@implementation GaussianElimination

- (int)getBitsNumber {
    return 12;
}

- (NSArray<NSNumber *> *)findResultOfMatrix:(NSArray<NSArray *> *)matrix {
    int bitsNumber = [self getBitsNumber];
    // helpers
    FHEBitwiseObject *encZero = [[FHEBitwiseObject alloc] initWithBits:[@0 binaryRepresentationWith:bitsNumber]];
    // encrypt data
    NSMutableArray<NSMutableArray<FHEBitwiseObject *> *> *encryptedData = [[NSMutableArray alloc] init];
    for (NSArray *line in matrix) {
        NSMutableArray *encLine = [[NSMutableArray alloc] init];
        for (NSNumber *element in line) {
            FHEBitwiseObject *encElement = [[FHEBitwiseObject alloc] initWithBits:[element binaryRepresentationWith:bitsNumber]];
            [encLine addObject:encElement];
        }
        [encryptedData addObject:encLine];
    }
    // straight stroke
    for (int i = 0; i < [matrix[0] count] - 2; i++) {
        // replace lines
        for (int j = i + 1; j < [matrix count]; j++) {
            // check zero bit
            CTile eq = [encZero compareWithOther:encryptedData[i][i]];
            // replace lines if needed
            NSArray<NSArray<FHEBitwiseObject *> *> *correctedLines = [self shiftElements:@[encryptedData[i], encryptedData[j]] basedOnBit:eq];
            encryptedData[i] = [correctedLines[0] mutableCopy];
            encryptedData[j] = [correctedLines[1] mutableCopy];
        }
        
        // zero bytes
        for (int j = i + 1; j < [matrix count]; j++) {
            for (int k = i + 1; k < [matrix[0] count]; k++) {
                FHEBitwiseObject *aCopy = [[FHEBitwiseObject alloc] initWithEncriptedBits:encryptedData[i][k].getEncryptedBits];
                [aCopy multiplyWithOther:encryptedData[j][i]];
                [encryptedData[j][k] multiplyWithOther:encryptedData[i][i]];
                [encryptedData[j][k] diffOther:aCopy];
            }
            encryptedData[j][i] = encZero;
        }
    }
    
    // reverse stroke
    NSMutableArray<FHEBitwiseObject *> *results = [[NSMutableArray alloc] init];
    for (int i = int([matrix[0] count] - 2); i >= 0; i--) {
        int lastIndex = int([matrix[0] count] - 1);
        for (int j = i + 1; j < lastIndex; j++) {
            // invert index
            int resultIndex = int([matrix[0] count]) - 2 - j;
            [encryptedData[i][j] multiplyWithOther:results[resultIndex]];
            [encryptedData[i][lastIndex] diffOther:encryptedData[i][j]];
        }
        [encryptedData[i][lastIndex] divideByOther:encryptedData[i][i]];
        
        [results addObject:encryptedData[i][lastIndex]];
    }
    results = [[[results reverseObjectEnumerator] allObjects] mutableCopy];
    // decrypt results
    NSMutableArray<NSNumber *> *decResults = [[NSMutableArray alloc] init];
    for (FHEBitwiseObject *result in results) {
        NSNumber *decResult = [NSNumber buildFromBitsArray:[result decrypt]];
        [decResults addObject:decResult];
    }
    NSLog(@"Result is: %@", decResults);
    return decResults;
}

- (NSArray<NSArray<FHEBitwiseObject *> *> *)shiftElements:(NSArray<NSArray<FHEBitwiseObject *> *> *)array basedOnBit:(CTile)bit {
    CTile useA = bit;
    CTile useB = bit;
    [[FHEManager sharedObject] invertBit:useB];
    
    NSMutableArray<FHEBitwiseObject *> *resultA = [[NSMutableArray alloc] init];
    NSMutableArray<FHEBitwiseObject *> *resultB = [[NSMutableArray alloc] init];
    for (int i = 0; i < array[0].count; i++) {
        // A AND bit
        FHEBitwiseObject *aAndBit = [[FHEBitwiseObject alloc] initWithEncriptedBits: array[0][i].getEncryptedBits];
        [aAndBit multiplyWithBit:useA];
        // A AND not_bit
        FHEBitwiseObject *aAndNotBit = [[FHEBitwiseObject alloc] initWithEncriptedBits: array[0][i].getEncryptedBits];
        [aAndNotBit multiplyWithBit:useB];
        // B AND not_bit
        FHEBitwiseObject *bAndNotBit = [[FHEBitwiseObject alloc] initWithEncriptedBits: array[0][i].getEncryptedBits];
        [aAndNotBit multiplyWithBit:useB];
        // B AND bit
        FHEBitwiseObject *bAndBit = [[FHEBitwiseObject alloc] initWithEncriptedBits: array[1][i].getEncryptedBits];
        [aAndBit multiplyWithBit:useA];
        // (A AND bit) OR (B AND not_bit)
        [aAndBit summWithOther:bAndNotBit];
        // (A AND not_bit) OR (B AND bit)
        [aAndNotBit summWithOther:bAndBit];
        [resultA addObject:aAndBit];
        [resultB addObject:aAndNotBit];
    }
    return @[resultA, resultB];
}

- (void)printCurrentMatrix:(NSArray<NSArray<FHEBitwiseObject *> *> *)encryptedData {
    NSMutableArray *testArray = [[NSMutableArray alloc] init];
    for (NSMutableArray *line in encryptedData) {
        NSMutableArray *lineArray = [[NSMutableArray alloc] init];
        for (FHEBitwiseObject *object in line) {
            NSNumber *decObject = [NSNumber buildFromBitsArray:[object decrypt]];
            [lineArray addObject:decObject];
        }
        [testArray addObject:lineArray];
    }
    NSLog(@"Straight stroke result: %@", testArray);
}

@end
