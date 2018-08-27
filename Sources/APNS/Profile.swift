//
//  Profile.swift
//  APNS
//
//  Created by Anthony Castelli on 4/1/18.
//

import Foundation
import JWT

public class Profile {
    /// The two port options for Apple's APNS
    public enum Port: Int {
        /// Default HTTPS Port 443
        case `default` = 443
        
        /// You can alternatively use port 2197 when communicating with APNs. You might do this,
        /// for example, to allow APNs traffic through your firewall but to block other HTTPS traffic.
        case alternative = 2197
    }
    
    /// The port to make the HTTP call on
    public var port: Port = .default
    
    /// The topic of the remote notification, which is typically the bundle ID for your app.
    public var topic: String
    
    /// The issuer (iss) registered claim key, whose value is your 10-character Team ID,
    /// obtained from your developer account
    public var teamId: String
    
    /// A 10-character key identifier (kid) key, obtained from your developer account.
    public var keyId: String
    
    /// File path to the certificate key
    public var keyPath: String
    
    /// Debug logging
    public var debugLogging: Bool = false
    
    /// Token data
    public var token: String?
    public var tokenExpiration: Date = Date()
    
    internal var privateKey: Data
    internal var publicKey: Data
    
    public var description: String {
        return """
        Topic \(self.topic)
        \nPort \(self.port.rawValue)
        \nCER - Key path: \(self.keyPath)
        \nTOK - Key ID: \(String(describing: self.keyId))
        """
    }
    
    public init(topic: String, forTeam teamId: String, withKey keyId: String, keyPath: String, debugLogging: Bool = false) throws {
        self.teamId = teamId
        self.topic = topic
        self.keyId = keyId
        self.debugLogging = debugLogging
        self.keyPath = keyPath
        
        // Token Generation
        guard FileManager.default.fileExists(atPath: keyPath) else {
            throw InitializationError.keyFileDoesNotExist
        }
        
        let (priv, pub) = KeyGenerator.generate(from: keyPath)
        self.publicKey = pub
        self.privateKey = priv
        
        try self.generateToken()
    }
    
    internal func generateToken() throws {
        let JWTheaders = JWTHeader(alg: "ES256", cty: nil, crit: nil, kid: self.keyId)
        let payload = APNSJWTPayload(iss: self.teamId)
        let signer = JWTSigner(algorithm: ES256(key: self.privateKey))
        let jwt = JWT(header: JWTheaders, payload: payload)
        let signed = try jwt.sign(using: signer)
        guard let token = String(bytes: signed, encoding: .utf8) else {
            throw TokenError.tokenWasNotGeneratedCorrectly
        }
        self.token = token
        self.tokenExpiration = Date(timeInterval: 3500, since: Date())
    }
    
}
