//
//  APNSJWTPayload.swift
//  APNS
//
//  Created by Anthony Castelli on 4/1/18.
//

import Foundation
import JWT

struct APNSJWTPayload: JWTPayload {
    let iss: String
    let iat = IssuedAtClaim(value: Date())
    let exp = ExpirationClaim(value: Date(timeInterval: 3500, since: Date()))
    
    func verify() throws {
        try self.exp.verify()
    }
}
