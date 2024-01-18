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
    FHEBitwiseObject *object1 = [[FHEBitwiseObject alloc] initWithBits:[@-4 binaryRepresentationWith:8]];
    FHEBitwiseObject *object2 = [[FHEBitwiseObject alloc] initWithBits:[@3 binaryRepresentationWith:8]];
    [object1 multiplyWithOther:object2];
    NSNumber *result1 = [NSNumber buildFromBitsArray: [object1 decrypt]];
    NSNumber *result2 = [NSNumber buildFromBitsArray: [object2 decrypt]];
    NSLog(@"Result is: %@", result1);
    NSLog(@"Other object after operation is: %@", result2);
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
