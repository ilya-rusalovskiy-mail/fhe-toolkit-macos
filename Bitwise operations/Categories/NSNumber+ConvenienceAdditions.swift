//
//  NSNumber+ConvenienceAdditions.swift
//  Bitwise operations
//
//  Created by mac1 on 09.11.2023.
//  Copyright © 2023 IBM. All rights reserved.
//

import Foundation

extension NSNumber {
    
    @objc func binaryRepresentation(with size: Int) -> [NSNumber] {
        let value = int64Value
        var string = String(value, radix: 2)
        if value < 0 {
            string = string.replacingOccurrences(of: "-", with: "")
        }
        for _ in 0..<(size - 1 - string.count) {
            string = "0" + string
        }
        var result: [UInt8] = []
        if value < 0 {
            result = string.compactMap({ UInt8(String($0)) })
            result = NSNumber.revertTwosComplement(of: result)
            result.insert(1, at: 0)
        } else {
            string = "0" + string
            result = string.compactMap({ UInt8(String($0)) })
        }
        return result.compactMap({ NSNumber(value: $0) })
    }
    
    @objc static func buildFromBitsArray(_ bitsArray: [NSNumber]) -> NSNumber {
        var bits = bitsArray.map({ $0.uint8Value })
        let sign = bits.removeFirst()
        if sign == 1 {
            bits = revertTwosComplement(of: bits)
        }
        bits.reverse()
        var result: Double = 0
        for (index, bit) in bits.enumerated() {
            if bit == 1 {
                result += pow(2, Double(index))
            }
        }
        result = sign == 1 ? -result : result
        return NSNumber(value: result)
    }
    
    // MARK: - Helpers
    
    private static func revertTwosComplement(of array: [UInt8]) -> [UInt8] {
        // invert
        var result: [UInt8] = array.map({ $0 == 1 ? 0 : 1 })
        // add 1 to right
        result.reverse()
        var overflow: UInt8 = 1
        for i in 0...result.count-1 {
            let summ = result[i] ^ overflow
            overflow = result[i] & overflow
            result[i] = summ
        }
        result.reverse()
        return result
    }
    
}
