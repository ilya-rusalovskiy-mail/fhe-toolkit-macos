//
//  MathTesting.mm
//  Bitwise operations
//
//  Created by mac1 on 07.02.2024.
//  Copyright © 2024 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MathTesting.h"
#import "FHEManager.h"
#import "FHEBitwiseObject.h"
#import "Bitwise_operations-Swift.h"
#include <math.h>

@implementation MathTesting

- (void)testSum {
    int testsCount = 100;
    int bitsCount = 32;
    // 2 = 1 for sign bit + 1 for overflow
    int maxValue = (int)pow(2, bitsCount - 2);
    int correctCount = 0;
    NSDate *methodStart = [NSDate date];
    for (int i = 0; i < testsCount; i++) {
        // generate random values
        int leftM = arc4random_uniform(maxValue);
        int rightM = arc4random_uniform(maxValue);
        // encrypt generated values
        FHEBitwiseObject *leftC = [[FHEBitwiseObject alloc] initWithBits:[@(leftM) binaryRepresentationWith:bitsCount]];
        FHEBitwiseObject *rightC = [[FHEBitwiseObject alloc] initWithBits:[@(rightM) binaryRepresentationWith:bitsCount]];
        // sum
        [leftC summWithOther:rightC];
        // decrypt result
        NSNumber *result = [NSNumber buildFromBitsArray: [leftC decrypt]];
        // assert
        if (result.intValue == leftM + rightM) {
            correctCount++;
        } else {
            NSLog(@"Failed summ of %i and %i. Expected %i, but got %i", leftM, rightM, leftM+rightM, result.intValue);
        }
    }
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    [self printTestResultsWithTestsCount:testsCount success:correctCount time:executionTime];
}

- (void)testDiff {
    int testsCount = 100;
    int bitsCount = 32;
    // 1 = 1 for sign bit
    int maxValue = (int)pow(2, bitsCount - 1);
    int correctCount = 0;
    NSDate *methodStart = [NSDate date];
    for (int i = 0; i < testsCount; i++) {
        // generate random values
        int leftM = arc4random_uniform(maxValue);
        int rightM = arc4random_uniform(maxValue);
        // encrypt generated values
        FHEBitwiseObject *leftC = [[FHEBitwiseObject alloc] initWithBits:[@(leftM) binaryRepresentationWith:bitsCount]];
        FHEBitwiseObject *rightC = [[FHEBitwiseObject alloc] initWithBits:[@(rightM) binaryRepresentationWith:bitsCount]];
        // sum
        [leftC diffOther:rightC];
        // decrypt result
        NSNumber *result = [NSNumber buildFromBitsArray: [leftC decrypt]];
        // assert
        if (result.intValue == leftM - rightM) {
            correctCount++;
        } else {
            NSLog(@"Failed diff of %i and %i. Expected %i, but got %i", leftM, rightM, leftM-rightM, result.intValue);
        }
    }
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    [self printTestResultsWithTestsCount:testsCount success:correctCount time:executionTime];
}

- (void)testMultiplication {
    int testsCount = 100;
    int bitsCount = 32;
    // 1 = 1 for sign bit
    int maxValue = (int)pow(2, bitsCount/2 - 1);
    int correctCount = 0;
    NSDate *methodStart = [NSDate date];
    for (int i = 0; i < testsCount; i++) {
        // generate random values
        int leftM = arc4random_uniform(maxValue);
        int rightM = arc4random_uniform(maxValue);
        // encrypt generated values
        FHEBitwiseObject *leftC = [[FHEBitwiseObject alloc] initWithBits:[@(leftM) binaryRepresentationWith:bitsCount]];
        FHEBitwiseObject *rightC = [[FHEBitwiseObject alloc] initWithBits:[@(rightM) binaryRepresentationWith:bitsCount]];
        // sum
        [leftC multiplyWithOther:rightC];
        // decrypt result
        NSNumber *result = [NSNumber buildFromBitsArray: [leftC decrypt]];
        // assert
        if (result.intValue == leftM * rightM) {
            correctCount++;
        } else {
            NSLog(@"Failed multiplication of %i and %i. Expected %i, but got %i", leftM, rightM, leftM*rightM, result.intValue);
        }
    }
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    [self printTestResultsWithTestsCount:testsCount success:correctCount time:executionTime];
}

- (void)testDivision {
    int testsCount = 100;
    int bitsCount = 32;
    // 1 = 1 for sign bit
    int maxValue = (int)pow(2, bitsCount - 1);
    int correctCount = 0;
    NSDate *methodStart = [NSDate date];
    for (int i = 0; i < testsCount; i++) {
        // generate random values
        int leftM = arc4random_uniform(maxValue);
        int rightM = arc4random_uniform(maxValue);
        // encrypt generated values
        FHEBitwiseObject *leftC = [[FHEBitwiseObject alloc] initWithBits:[@(leftM) binaryRepresentationWith:bitsCount]];
        FHEBitwiseObject *rightC = [[FHEBitwiseObject alloc] initWithBits:[@(rightM) binaryRepresentationWith:bitsCount]];
        // sum
        [leftC divideByOther:rightC];
        // decrypt result
        NSNumber *result = [NSNumber buildFromBitsArray: [leftC decrypt]];
        // assert
        int expectedResult = (int)round((double)leftM / (double)rightM);
        if (result.intValue == expectedResult) {
            correctCount++;
        } else {
            NSLog(@"Failed division of %i and %i. Expected %i, but got %i", leftM, rightM, expectedResult, result.intValue);
        }
    }
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    [self printTestResultsWithTestsCount:testsCount success:correctCount time:executionTime];
}

- (void)printTestResultsWithTestsCount:(int)testsCount success:(int)success time:(NSTimeInterval)time {
    int error = testsCount - success;
    NSLog(@"Tests completed. Was executed %i tests.", testsCount);
    NSLog(@"Pass: %i. Failed: %i", success, error);
    NSLog(@"Execution time: %f", time);
}

@end
