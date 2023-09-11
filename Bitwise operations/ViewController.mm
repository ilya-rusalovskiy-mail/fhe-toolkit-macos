//
//  ViewController.m
//  Bitwise operations
//
//  Created by mac1 on 02.09.2023.
//  Copyright © 2023 IBM. All rights reserved.
//

#import "ViewController.h"
#import "FHEBitwiseObject.h"

@implementation ViewController

//// Note: These parameters have been chosen to provide fast running times as
//// opposed to a realistic security level. As well as negligible security,
//// these default parameters result in an algebra with only 10 slots which limits
//// the size of both the “keys” and “values” to 10 chars. If you try to use
//// bigger “keys” or “values” you will need to choose different parameters
//// that give you more slots, otherwise the code will throw an
//// "helib::OutOfRangeError" exception.
////
//// Commented below there is the parameter "m-130" which will result in an algebra
//// with 48 slots, thus allowing for “keys” and “values” up to 48 chars.
//
//// Plaintext prime modulus
//unsigned long p = 2;
//// Cyclotomic polynomial - defines phi(m)
//unsigned long m = 3; // this will give 1 slot
//// Hensel lifting (default = 1)
//unsigned long r = 1;
//// Number of bits of the modulus chain
//unsigned long bits = 1000;
//// Number of columns of Key-Switching matrix (default = 2 or 3)
//unsigned long c = 2;
//// Size of NTL thread pool (default =1)
//unsigned long nthreads = 12;
//// debug output (default no debug output)
//unsigned long debug = 1;
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//    dispatch_async(dispatch_get_global_queue( QOS_CLASS_USER_INITIATED, 0), ^(void){
//        [self bitwiseSumm];
//    });
//}
//
//- (void)bitwiseSumm {
//    long left = 120;
//    long right = -5;
//
//    std::vector<int> leftBits{0,1,1,1,1,0,0,0};
//    std::vector<int> rightBits{1,1,1,1,1,0,1,1};
//
//    // set NTL Thread pool size
//    if (nthreads > 1) {
//        NTL::SetNumThreads(nthreads);
//    }
//
//    // To setup helib using the hebase layer, let's first
//    // copy all configuration params to an HelibConfig object:
//    HelibConfig conf;
//    conf.p = p;
//    conf.m = m;
//    conf.r = r;
//    conf.L = bits;
//    conf.c = c;
//
//    // Next we'll initialize a BGV scheme in helib.
//    // The following two lines perform full intializiation
//    // Including key generation.
//    HelibBgvContext he;
//    he.init(conf);
//
//    cout << "\nNumber of slots: " << he.slotCount() << endl;
//
//    // The encoder class handles both encoding and encrypting.
//    Encoder encoder(he);
//
//    vector<CTile> encLeftBits;
//    for (const auto& bit : leftBits) {
//        CTile encryptedBit(he);
//        PTile encodedBit(he);
//        encoder.encode(encodedBit, bit);
//        encoder.encrypt(encryptedBit, encodedBit);
//        encLeftBits.push_back(encryptedBit);
//    }
//
//    vector<CTile> encRightBits;
//    for (const auto& bit : rightBits) {
//        CTile encryptedBit(he);
//        PTile encodedBit(he);
//        encoder.encode(encodedBit, bit);
//        encoder.encrypt(encryptedBit, encodedBit);
//        encRightBits.push_back(encryptedBit);
//    }
//
//    CTile f(he);
//    // TODO: use 0 for ADD and 1 for DIFF
//    encoder.encodeEncrypt(f, vector<int>{0});
//    CTile a(he);
//    CTile b(he);
//    CTile p = f;
//
//    CTile overflowBit(he);
//    vector<CTile> result;
//    for(int i = int(encLeftBits.size()) - 1; i >= 0; i--) {
//        // initial setup
//        a = encLeftBits[i];
//        b = encRightBits[i];
//        b.add(f);
//
//        // XOR-AND single bit adder
//        CTile aXorB = a;
//        aXorB.add(b);
//
//        CTile aAndB = a;
//        aAndB.multiply(b);
//
//        CTile c = aXorB;
//        c.add(p);
//        // result bit
//        result.push_back(c);
//
//        aXorB.multiply(p);
//        aXorB.add(aAndB);
//        if (i == 0) {
//            // last iteration - iteration over sign bits
//            // calculate overflow bit
//            // ref: https://www.geeksforgeeks.org/overflow-in-arithmetic-addition-in-binary-number-system/
//            overflowBit = p;
//            overflowBit.add(aXorB);
//        }
//        // carry bit
//        p = aXorB;
//    }
//    reverse(result.begin(), result.end());
//
//    NSMutableArray *resultArray = [NSMutableArray new];
//    for (const auto& res : result) {
//        int resultBit = encoder.decryptDecodeInt(res)[0];
//        [resultArray addObject:@(resultBit)];
//    }
//
//    int overflow = encoder.decryptDecodeInt(overflowBit)[0];
//    NSLog(@"Operation result.\nNumber: [%@].\nOverflow bit: %@", [resultArray componentsJoinedByString:@""], @(overflow));
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *bits = @[@0,@0,@0,@0,@1,@1,@0,@0];
    FHEBitwiseObject *object1 = [[FHEBitwiseObject alloc] initWithBits:bits];
    FHEBitwiseObject *object2 = [[FHEBitwiseObject alloc] initWithBits:bits];
    [object1 summWithOther:object2];
    NSArray *result = [object1 decrypt];
    NSLog(@"%@", result);
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
