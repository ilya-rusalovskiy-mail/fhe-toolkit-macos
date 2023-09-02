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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dispatch_async(dispatch_get_global_queue( QOS_CLASS_USER_INITIATED, 0), ^(void){
        [self bitwiseSumm];
    });
}

- (void)bitwiseSumm {
    long left = 10;
    long right = 5;
    
    std::vector<int> leftBits{0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0};
    std::vector<int> rightBits{0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1};
    
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
    HelibBgvContext he;
    he.init(conf);
    
    cout << "\nNumber of slots: " << he.slotCount() << endl;
    
    // The encoder class handles both encoding and encrypting.
    Encoder encoder(he);
    
    vector<CTile> encLeftBits;
    for (const auto& bit : leftBits) {
        CTile encryptedBit(he);
        PTile encodedBit(he);
        encoder.encode(encodedBit, bit);
        encoder.encrypt(encryptedBit, encodedBit);
        encLeftBits.push_back(encryptedBit);
    }
    
    vector<CTile> encRightBits;
    for (const auto& bit : rightBits) {
        CTile encryptedBit(he);
        PTile encodedBit(he);
        encoder.encode(encodedBit, bit);
        encoder.encrypt(encryptedBit, encodedBit);
        encRightBits.push_back(encryptedBit);
    }
    
    for(int i = 0; i < encLeftBits.size(); i++) {
        encLeftBits[i].add(encRightBits[i]);
    }
    
    NSMutableArray *resultArray = [NSMutableArray new];
    for (const auto& res : encLeftBits) {
        int resultBit = encoder.decryptDecodeInt(res)[0];
        [resultArray addObject:@(resultBit)];
    }
    NSLog(@"Operation result is: %@", resultArray);
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
