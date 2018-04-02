//
//  Result.swift
//  APNS
//
//  Created by Anthony Castelli on 4/1/18.
//

import Foundation

public enum APNSResult {
    case success(apnsId:String, deviceToken: String)
    case error(apnsId:String, deviceToken: String, error: APNSError)
    case networkError(error: Error)
}
