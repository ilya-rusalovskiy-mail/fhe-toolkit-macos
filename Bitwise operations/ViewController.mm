//
//  ViewController.m
//  Bitwise operations
//
//  Created by mac1 on 02.09.2023.
//  Copyright © 2023 IBM. All rights reserved.
//

#import "ViewController.h"
#import "FHEBitwiseObject.h"
#import "Bitwise_operations-Swift.h"
#import "GaussianElimination.h"
#include <stdlib.h>
#import "MathTesting.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Summ and Diff
//    NSArray *bits = [@8 binaryRepresentationWith:8];
//    FHEBitwiseObject *object1 = [[FHEBitwiseObject alloc] initWithBits:bits];
//    FHEBitwiseObject *object2 = [[FHEBitwiseObject alloc] initWithBits:bits];
//    [object1 summWithOther:object2];
//
//    FHEBitwiseObject *object3 = [[FHEBitwiseObject alloc] initWithBits:[@2 binaryRepresentationWith:8]];
//    [object1 diffOther:object3];
//    NSNumber *result = [NSNumber buildFromBitsArray: [object1 decrypt]];
//    NSLog(@"Result is: %@", result);
    // Multiply
//    FHEBitwiseObject *object1 = [[FHEBitwiseObject alloc] initWithBits:[@-4 binaryRepresentationWith:8]];
//    FHEBitwiseObject *object2 = [[FHEBitwiseObject alloc] initWithBits:[@3 binaryRepresentationWith:8]];
//    [object1 multiplyWithOther:object2];
//    NSNumber *result1 = [NSNumber buildFromBitsArray: [object1 decrypt]];
//    NSNumber *result2 = [NSNumber buildFromBitsArray: [object2 decrypt]];
//    NSLog(@"Result is: %@", result1);
//    NSLog(@"Other object after operation is: %@", result2);
    // Division
//    FHEBitwiseObject *object1 = [[FHEBitwiseObject alloc] initWithBits:[@10 binaryRepresentationWith:32]];
//    FHEBitwiseObject *object2 = [[FHEBitwiseObject alloc] initWithBits:[@-2 binaryRepresentationWith:32]];
//    [object1 divideByOther:object2];
//    [object1 divideByOther:object2];
//    NSNumber *result1 = [NSNumber buildFromBitsArray: [object1 decrypt]];
//    NSNumber *result2 = [NSNumber buildFromBitsArray: [object2 decrypt]];
//    NSLog(@"Result is: %@", result1);
//    NSLog(@"Other object after operation is: %@", result2);
//    NSArray *matrix = @[
//        @[@2, @5, @4, @1, @20],
//        @[@1, @3, @2, @1, @11],
//        @[@2, @10, @9, @7, @40],
//        @[@3, @8, @9, @2, @37],
//    ];
//    NSArray *matrix = @[
//        @[@1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @1],
//        @[@0, @1, @0, @0, @0, @0, @0, @0, @0, @0, @2],
//        @[@0, @0, @1, @0, @0, @0, @0, @0, @0, @0, @3],
//        @[@0, @0, @0, @1, @0, @0, @0, @0, @0, @0, @4],
//        @[@0, @0, @0, @0, @1, @0, @0, @0, @0, @0, @5],
//        @[@0, @0, @0, @0, @0, @1, @0, @0, @0, @0, @6],
//        @[@0, @0, @0, @0, @0, @0, @1, @0, @0, @0, @7],
//        @[@0, @0, @0, @0, @0, @0, @0, @1, @0, @0, @8],
//        @[@0, @0, @0, @0, @0, @0, @0, @0, @1, @0, @9],
//        @[@0, @0, @0, @0, @0, @0, @0, @0, @0, @1, @10],
//    ];
//    NSDate *methodStart = [NSDate date];
//    GaussianElimination *ga = [[GaussianElimination alloc] init];
//    NSArray *result = [ga findResultOfMatrix:matrix];
//    NSLog(@"Result is: %@", result);
//    NSDate *methodFinish = [NSDate date];
//    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
//    NSLog(@"executionTime = %f", executionTime);
    // Test divisions
//    FHEBitwiseObject *object = [[FHEBitwiseObject alloc] initWithBits:[@20 binaryRepresentationWith:16]];
//    FHEBitwiseObject *other = [[FHEBitwiseObject alloc] initWithBits:[@8 binaryRepresentationWith:16]];
//    for (int i = 0; i < 100; i++) {
////        int random = arc4random_uniform(10);
////        FHEBitwiseObject *other = [[FHEBitwiseObject alloc] initWithBits:[@(random) binaryRepresentationWith:16]];
//        [object divideByOther:other];
//    }
//    NSNumber *result = [NSNumber buildFromBitsArray: [object decrypt]];
//    NSLog(@"Result is: %@", result);
    
    MathTesting *testing = [MathTesting new];
    [testing testDivision];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
