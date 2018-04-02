//
//  APNS.swift
//  APNS
//
//  Created by Anthony Castelli on 4/1/18.
//

import Foundation
import Vapor

public final class APNS: ServiceType {
    
    var worker: Container
    var client: FoundationClient
    
    public static func makeService(for worker: Container) throws -> APNS {
        return try APNS(worker: worker)
    }
    
    public init(worker: Container) throws{
        self.worker = worker
        self.client = try FoundationClient.makeService(for: worker)
    }
    
    /// Send the message
    public func send(message: Message) throws -> Future<APNSResult> {
        let response = try self.client.respond(to: message.generateRequest(on: self.worker))
        return response.map(to: APNSResult.self) { response in
            guard let body = response.http.body.data, body.count != 0 else {
                return APNSResult.success(
                    apnsId: message.messageId,
                    deviceToken: message.deviceToken
                )
            }
            do {
                let decoder = JSONDecoder()
                let error = try decoder.decode(APNSError.self, from: body)
                return APNSResult.error(
                    apnsId: message.messageId,
                    deviceToken: message.deviceToken,
                    error: error
                )
            } catch _ {
                return APNSResult.error(
                    apnsId: message.messageId,
                    deviceToken: message.deviceToken,
                    error: APNSError.unknown
                )
            }
        }
    }
    
    public func sendRaw(message: Message) throws -> Future<Response> {
        return try self.client.respond(to: message.generateRequest(on: self.worker))
    }
    
}
