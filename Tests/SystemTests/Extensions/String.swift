//
//  File.swift
//  
//
//  Created by Łukasz Szyszkowski on 16/08/2021.
//

import Foundation
import CommonCrypto

extension String {
    func hmac(key: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key, key.count, self, self.count, &digest)
        return Data(digest).base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
}
