//
//  Result.swift
//
//  Created by Nirav Jain on 16/12/18.
//  Copyright © 2018 Nirav Jain. All rights reserved.
//

import Foundation

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

enum ServiceError: Error {
    case parseResponseFailed
}
