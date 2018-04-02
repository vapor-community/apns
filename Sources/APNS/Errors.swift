//
//  Errors.swift
//  APNS
//
//  Created by Anthony Castelli on 4/1/18.
//

import Foundation

public enum APNSError: String, Codable {
    case badCollapseId = "BadCollapseId"
    case badDeviceToken = "BadDeviceToken"
    case badExpirationDate = "BadExpirationDate"
    case badMessageId = "BadMessageId"
    case badPriority = "BadPriority"
    case badTopic = "BadTopic"
    case badPath = "BadPath"
    case badCertificate = "BadCertificate"
    case badCertificateEnvironment = "BadCertificateEnvironment"
    case deviceTokenNotForTopic = "DeviceTokenNotForTopic"
    case duplicateHeaders = "DuplicateHeaders"
    case idleTimeout = "IdleTimeout"
    case missingDeviceToken = "MissingDeviceToken"
    case missingTopic = "MissingTopic"
    case payloadEmpty = "PayloadEmpty"
    case payloadTooLarge = "PayloadTooLarge"
    case topicDisallowed = "TopicDisallowed"
    case expiredProviderToken = "ExpiredProviderToken"
    case forbidden = "Forbidden"
    case invalidProviderToken = "InvalidProviderToken"
    case missingProviderToken = "MissingProviderToken"
    case methodNotAllowed = "MethodNotAllowed"
    case unregistered = "Unregistered"
    case tooManyProviderTokenUpdates = "TooManyProviderTokenUpdates"
    case tooManyRequests = "TooManyRequests"
    case internalServerError = "InternalServerError"
    case serviceUnavailable = "ServiceUnavailable"
    
    case shutdown = "Shutdown"
    case unknown = "unknown"
    
    public var description: String {
        return self.rawValue
    }
}

public enum TokenError: Error {
    case invalidAuthKey
    case invalidTokenString
    case wrongTokenLength
    case tokenWasNotGeneratedCorrectly
}

public enum SimpleError: Error {
    case string(message: String)
}

public enum InitializationError: Error, CustomStringConvertible {
    case noAuthentication
    case noTopic
    case certificateFileDoesNotExist
    case keyFileDoesNotExist
    
    public var description: String {
        switch self {
        case .noAuthentication: return "APNS Authentication is required. You can either use APNS Auth Key authentication (easiest to setup and maintain) or the old fashioned certificates way"
        case .noTopic: return "No APNS topic provided. This is required."
        case .certificateFileDoesNotExist: return "Certificate file could not be found on your disk. Double check if the file exists and if the path is correct"
        case .keyFileDoesNotExist: return "Key file could not be found on your disk. Double check if the file exists and if the path is correct"
        }
    }
}
