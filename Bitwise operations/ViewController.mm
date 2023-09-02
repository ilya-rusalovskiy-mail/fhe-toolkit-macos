//
//  ViewController.m
//  Bitwise operations
//
//  Created by mac1 on 02.09.2023.
//  Copyright © 2023 IBM. All rights reserved.
//

#import "ViewController.h"
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

@implementation ViewController

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
unsigned long m = 128; // this will give 32 slots
// Hensel lifting (default = 1)
unsigned long r = 1;
// Number of bits of the modulus chain
unsigned long bits = 1000;
// Number of columns of Key-Switching matrix (default = 2 or 3)
unsigned long c = 2;
// Size of NTL thread pool (default =1)
unsigned long nthreads = 12;
// debug output (default no debug output)
unsigned long debug = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)bitwiseSumm {
    long left = 10;
    long right = 5;
    
    NSArray *leftBits = @[@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@1,@0,@1,@0];
    NSArray *rightBits = @[@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@1,@0,@1];
    
    // set NTL Thread pool size
    if (nthreads > 1) {
        NTL::SetNumThreads(nthreads);
    }
    
    
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
