//
//  JWT+ES256.swift
//  APNS
//
//  Created by Anthony Castelli on 4/1/18.
//

import Foundation
import CNIOOpenSSL
import Crypto
import Bits
import JWT

public enum JWTError: Error {
    case createKey
    case createPublicKey
    case decoding
    case encoding
    case incorrectNumberOfSegments
    case incorrectPayloadForClaimVerification
    case missingAlgorithm
    case missingClaim(withName: String)
    case privateKeyRequired
    case signatureVerificationFailed
    case signing
    case verificationFailedForClaim(withName: String)
    case wrongAlgorithm
    case unknown(Error)
}

public final class ES256: JWTAlgorithm {
    internal let curve = NID_X9_62_prime256v1
    internal let key: Data
    
    public var jwtAlgorithmName: String {
        return "ES256"
    }
    
    public init(key: Data) {
        self.key = key
    }
    
    public func sign(_ plaintext: LosslessDataConvertible) throws -> Data {
        let digest = Bytes(try SHA256.hash(plaintext))
        let ecKey = try self.newECKeyPair()
        
        guard let signature = ECDSA_do_sign(digest, Int32(digest.count), ecKey) else {
            throw JWTError.signing
        }
        
        var derEncodedSignature: UnsafeMutablePointer<UInt8>? = nil
        let derLength = i2d_ECDSA_SIG(signature, &derEncodedSignature)
        guard let derCopy = derEncodedSignature, derLength > 0 else {
            throw JWTError.signing
        }
        
        var derBytes = [UInt8](repeating: 0, count: Int(derLength))
        for b in 0..<Int(derLength) {
            derBytes[b] = derCopy[b]
        }
        return Data(derBytes)
    }
    
    public func verify(_ signature: Data, signs plaintext: Data) throws -> Bool {
        var signaturePointer: UnsafePointer? = UnsafePointer(Bytes(signature))
        let signature = d2i_ECDSA_SIG(nil, &signaturePointer, signature.count)
        let digest = Bytes(try SHA256.hash(plaintext))
        let ecKey = try self.newECPublicKey()
        let result = ECDSA_do_verify(digest, Int32(digest.count), signature, ecKey)
        if result == 1 {
            return false
        }
        return true
    }
    
    func newECKey() throws -> OpaquePointer {
        guard let ecKey = EC_KEY_new_by_curve_name(curve) else {
            throw JWTError.createKey
        }
        return ecKey
    }
    
    func newECKeyPair() throws -> OpaquePointer {
        var privateNum = BIGNUM()
        
        // Set private key
        BN_init(&privateNum)
        BN_bin2bn(Bytes(key), Int32(key.count), &privateNum)
        let ecKey = try newECKey()
        EC_KEY_set_private_key(ecKey, &privateNum)
        
        // Derive public key
        let context = BN_CTX_new()
        BN_CTX_start(context)
        
        let group = EC_KEY_get0_group(ecKey)
        let publicKey = EC_POINT_new(group)
        EC_POINT_mul(group, publicKey, &privateNum, nil, nil, context)
        EC_KEY_set_public_key(ecKey, publicKey)
        
        // Release resources
        EC_POINT_free(publicKey)
        BN_CTX_end(context)
        BN_CTX_free(context)
        BN_clear_free(&privateNum)
        
        return ecKey
    }
    
    func newECPublicKey() throws -> OpaquePointer {
        var ecKey: OpaquePointer? = try self.newECKey()
        var publicBytesPointer: UnsafePointer? = UnsafePointer<UInt8>(Bytes(self.key))
        
        if let ecKey = o2i_ECPublicKey(&ecKey, &publicBytesPointer, self.key.count) {
            return ecKey
        } else {
            throw JWTError.createPublicKey
        }
    }
}
