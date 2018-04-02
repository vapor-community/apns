//
//  KeyGenerator.swift
//  APNS
//
//  Created by Anthony Castelli on 4/1/18.
//

import Foundation
import Crypto
import CNIOOpenSSL
import Bits
import NIO

/// Key generators 
internal class KeyGenerator {
    /// Generates a new key, value pair
    internal static func generate(from path: String) -> (Data, Data){
        var pKey = EVP_PKEY_new()
        
        let fp = fopen(path, "r")
        PEM_read_PrivateKey(fp, &pKey, nil, nil)
        let ecKey = EVP_PKEY_get1_EC_KEY(pKey)
        EC_KEY_set_conv_form(ecKey, POINT_CONVERSION_UNCOMPRESSED)
        fclose(fp)
        
        var pub: UnsafeMutablePointer<UInt8>? = nil
        let pub_len = i2o_ECPublicKey(ecKey, &pub)
        var publicKey = ""
        if let pub = pub {
            var publicBytes = Bytes(repeating: 0, count: Int(pub_len))
            for i in 0..<Int(pub_len) {
                publicBytes[i] = Byte(pub[i])
            }
            publicKey = Data(bytes: publicBytes).hexEncodedString()
        } else {
            publicKey = ""
        }
        
        let bn = EC_KEY_get0_private_key(ecKey!)
        let privKeyBigNum = BN_bn2hex(bn)
        
        let privateKey = "00\(String.init(validatingUTF8: privKeyBigNum!)!)"
        
        let privData = dataFromHexadecimalString(key: privateKey)!
        let pubData = dataFromHexadecimalString(key: publicKey)!
        
        return (privData, pubData)
    }
    
    internal static func dataFromHexadecimalString(key: String) -> Data? {
        var data = Data(capacity: key.count / 2)
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: key, options: [], range: NSMakeRange(0, key.count)) { match, flags, stop in
            let range = key.range(from: match!.range)
            let byteString = key[range!]
            var num = UInt8(byteString, radix: 16)
            data.append(&num!, count: 1)
        }
        return data
    }
}
