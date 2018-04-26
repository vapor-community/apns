//
//  Message.swift
//  APNS
//
//  Created by Anthony Castelli on 4/1/18.
//

import Foundation
import Vapor

/// Push notification delivery priority
public enum Priority: Int {
    /// Send the push message at a time that takes into account power considerations for the device.
    /// Notifications with this priority might be grouped and delivered in bursts. They are
    /// throttled, and in some cases are not delivered.
    case energyEfficient = 5
    
    /// Send the push message immediately. Notifications with this priority must trigger an
    /// alert, sound, or badge on the target device. It is an error to use this priority for a
    /// push notification that contains only the content-available key.
    case immediately = 10
}

public struct Message {
    /// APNS Developer profile info
    public let profile: Profile
    
    /// APNS Message UUID
    public let messageId: String = UUID().uuidString
    
    /// APNS message payload
    public let payload: Payload
    
    /// Message delivery priority
    public let priority: Priority
    
    /// Multiple notifications with the same collapse identifier are displayed to the user as a
    /// single notification. The value of this key must not exceed 64 bytes. For more information,
    /// see Quality of Service, Store-and-Forward, and Coalesced Notifications.
    public var collapseIdentifier: String?
    
    ///
    public var threadIdentifier: String?
    
    /// A UNIX epoch date expressed in seconds (UTC). This header identifies the date when the
    /// notification is no longer valid and can be discarded. If this value is nonzero, APNs stores
    /// the notification and tries to deliver it at least once, repeating the attempt as needed if
    /// it is unable to deliver the notification the first time. If the value is 0, APNs treats the
    /// notification as if it expires immediately and does not store the notification or attempt to
    /// redeliver it.
    public var expirationDate: Date?
    
    /// The device token to send the message to
    public let deviceToken: String
    
    /// Use the development or production servers
    public let development: Bool
    
    /// Creates a new message
    public init(priority: Priority = .immediately, profile: Profile, deviceToken: String, payload: Payload, on container: Container, development: Bool = false) throws {
        self.profile = profile
        self.priority = priority
        self.payload = payload
        self.deviceToken = deviceToken
        self.development = development
    }
    
    internal func generateRequest(on container: Container) throws -> Request {
        let request = Request(using: container)
        request.http.method = .POST
        
        request.http.headers.add(name: .connection, value: "Keep-Alive")
        request.http.headers.add(name: HTTPHeaderName("authorization"), value: "bearer \(self.profile.token ?? "")")
        request.http.headers.add(name: HTTPHeaderName("apns-id"), value: self.messageId)
        request.http.headers.add(name: HTTPHeaderName("apns-priority"), value: "\(self.priority.rawValue)")
        request.http.headers.add(name: HTTPHeaderName("apns-topic"), value: self.profile.topic)
        
        if let expiration = self.expirationDate {
            request.http.headers.add(name: HTTPHeaderName("apns-expiration"), value: String(expiration.timeIntervalSince1970.rounded()))
        }
        if let collapseId = self.collapseIdentifier {
            request.http.headers.add(name: HTTPHeaderName("apns-collapse-id"), value: collapseId)
        }
        if let threadId = self.threadIdentifier {
            request.http.headers.add(name: HTTPHeaderName("thread-id"), value: threadId)
        }
        if self.profile.tokenExpiration <= Date() {
            try self.profile.generateToken()
        }
        
        let encoder = JSONEncoder()
        request.http.body = try HTTPBody(data: encoder.encode(PayloadContent(payload: self.payload)))
        
        if self.development {
            guard let url = URL(string: "https://api.development.push.apple.com/3/device/\(self.deviceToken)") else {
                throw MessageError.invalidURL
            }
            request.http.url = url
        } else {
            guard let url = URL(string: "https://api.push.apple.com/3/device/\(self.deviceToken)") else {
                throw MessageError.invalidURL
            }
            request.http.url = url
        }
        
        return request
    }
}
