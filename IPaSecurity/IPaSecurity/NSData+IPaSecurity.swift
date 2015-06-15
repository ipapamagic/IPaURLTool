//
//  NSData+IPaSecurity.swift
//  IPaSecurity
//
//  Created by IPa Chen on 2015/6/14.
//  Copyright (c) 2015年 IPaPa. All rights reserved.
//

import Foundation
import CommonCrypto
extension NSData {
    func DecryotWithAlgorighm(algorithm:CCAlgorithm, key:NSData) -> NSData
    {
        return DecryotWithAlgorighm(algorithm,mode:kCCModeCBC,padding:false,iv:nil,key:key)

    }
    func DecryotWithAlgorighm(algorithm:CCAlgorithm, mode:CCMode, padding:Bool, iv:NSData,key:NSData) -> NSData
    {
        
        return DecryotWithAlgorighm(algorithm:algorithm, mode:mode, padding:padding, iv:iv ,key:key, options:0)
    }
    func DecryotWithAlgorighm(algorithm:CCAlgorithm, mode:CCMode, padding:Bool, iv:NSData,key:NSData,options:CCModeOptions) -> NSData {
        return CipherWithOperation(kCCDecrypt, algorighm: algorithm, mode: mode, padding: padding, iv: iv, key: key, options: options)
    }
    func CipherWithOperation(operation:CCOperation, algorighm:CCAlgorithm, mode:CCMode, padding:Bool, iv:NSData, key:NSData, options:CCModeOptions) -> NSData
    {
        //check key size
        switch (algorithm) {
        case kCCAlgorithmAES128:
            if (key.length != kCCKeySizeAES128 && key.length != kCCKeySizeAES192 && key.length != kCCKeySizeAES256) {
                println("Encrypt Fail! key size not correct!")
                return nil
            }
        case kCCAlgorithmDES:
            if (key.length != kCCKeySizeDES) {
                println("Encrypt Fail! key size not correct!")
                return nil
            }
        case kCCAlgorithm3DES:
            if (key.length != kCCKeySize3DES) {
                println("Encrypt Fail! key size not correct!")
                return nil
            }
        case kCCAlgorithmCAST:
            if (key.length < kCCKeySizeMinCAST || key.length > kCCKeySizeMaxCAST) {
                println("Encrypt Fail! key size not correct!")
                return nil
            }
        case kCCAlgorithmRC4:
            if (key.length < kCCKeySizeMinRC4 || key.length > kCCKeySizeMaxRC4) {
                println("Encrypt Fail! key size not correct!")
                return nil
            }
        case kCCAlgorithmRC2:
            if (key.length < kCCKeySizeMinRC2 || key.length > kCCKeySizeMaxRC2) {
                println("Encrypt Fail! key size not correct!")
                return nil
            }
        case kCCAlgorithmBlowfish:
            if (key.length < kCCKeySizeMinBlowfish || key.length > kCCKeySizeMaxBlowfish) {
                println("Encrypt Fail! key size not correct!")
                return nil
            }
        default:
            break
        }
        var cryptorRef:CCCryptorRef
        //not support XTS mode
        status = CCCryptorCreateWithMode(operation,mode,algorithm,((padding) ?ccPKCS7Padding :ccNoPadding), iv.bytes,key.bytes,key.length,nil,0,0,options,&cryptorRef)
    
        if status != kCCSuccess {
            println("CCCryptor create fail!")
            return nil
        }
    
        let bufferSize:size_t = CCCryptorGetOutputLength(cryptorRef,self.length,true)
    
        let buffer = malloc(bufferSize * sizeof(uint8_t))
        var movedBytes:size_t = 0
        status = CCCryptorUpdate(cryptorRef,self.bytes,self.length,buffer,bufferSize,&movedBytes)
        if status != kCCSuccess {
            println("CCCryptor update fail!")
            free(buffer)
            return nil
        }
        var totalBytesWritten:size_t = movedBytes
        var ptr = buffer + movedBytes
        
        var remainingBytes:size_t = bufferSize - movedBytes
    
        //no padding and stream cipher ,don't need to call CCCryptorFinal
        status = CCCryptorFinal(cryptorRef, ptr, remainingBytes, &movedBytes)
        if status != kCCSuccess {
            println("CCCryptor Final fail!....%d",status)
            return nil
        }
        totalBytesWritten += movedBytes
        let retData = NSData(bytesNoCopy: buffer, length: totalBytesWritten, freeWhenDone: true)
        
        
        if (cryptorRef) {
            CCCryptorRelease(cryptorRef)
        }
    
    
        return retData
    }
    func EncryotWithAlgorighm(algorithm:CCAlgorithm, key:NSData) -> NSData
    {
        return EncryotWithAlgorighm(algorithm, mode:kCCModeCBC ,padding:false, iv:nil, key:key)
    }
    func EncryotWithAlgorighm(algorithm:CCAlgorithm, mode:CCMode, padding:Bool, iv:NSData, key:NSData) -> NSData
    {
        return EncryotWithAlgorighm(algorithm, mode:mode, padding:padding, iv:iv, key:key, options:0)
    }
    func EncryotWithAlgorighm(algorithm:CCAlgorithm, mode:CCMode, padding:Bool, iv:NSData, key:NSData, options:CCModeOptions) -> NSData
    {
        return CipherWithOperation(kCCEncrypt, algorighm:algorithm, mode:mode, padding:padding, iv:iv, key:key, options:options)
    }
    
    func SHA256String() -> String
    {
        var digest:[uint8_t] = Array(count: CC_SHA256_DIGEST_LENGTH, repeatedValue: 0)
    
        CC_SHA256(bytes, length as CC_LONG, digest)
        var output:String = ""
        
        for var i:Int ; i < CC_SHA256_DIGEST_LENGTH ; i++ {
            output += String(format: "%02x", arguments: digest[i])
        }
        return output
    }
        
    func SHA1String() -> String
    {
        var digest:[uint8_t] = Array(count: CC_SHA1_DIGEST_LENGTH, repeatedValue: 0)
        
        CC_SHA1(bytes, length as CC_LONG, digest)
        var output:String = ""
        
        for var i:Int ; i < CC_SHA1_DIGEST_LENGTH ; i++ {
            output += String(format: "%02x", arguments: digest[i])
        }
        return output
    
    }
    func MD5String() -> String
    {
        var digest:[char] = Array(count: CC_MD5_DIGEST_LENGTH, repeatedValue: 0)
        
        CC_MD5( bytes, length as CC_LONG, digest ) // This is the md5 call
        var output:String = ""
        
        for var i:Int ; i < CC_MD5_DIGEST_LENGTH ; i++ {
            output += String(format: "%02x", arguments: digest[i])
        }
        return output
    }
    func HMACDataWithAlgorithm(algorithm:CCHmacAlgorithm, sectet:NSData) -> NSData
    {
        
        let cKey  = key.bytes
        let cData = bytes
    
        var dataSize:size_t = 0
    
        switch (algorithm) {
        case kCCHmacAlgSHA1:
            dataSize = CC_SHA1_DIGEST_LENGTH
        case kCCHmacAlgSHA256:
            dataSize = CC_SHA256_DIGEST_LENGTH
        case kCCHmacAlgMD5:
            dataSize = CC_MD5_DIGEST_LENGTH
        default:
            break
        }
    
        if (dataSize > 0) {
            var cHMAC = malloc(dataSize)
            CCHmac(algorithm, cKey, key.length, cData, length, cHMAC)
            let hmacData = NSData(bytes: cHMAC, length: dataSize)
            
            free(cHMAC)
            return hmacData
        }
        return nil
    
    }
    -(NSString*)HexString
    {
    
    char *bytes = (char*)self.bytes
    
    
    NSMutableString *hexString = [@"" mutableCopy]
    for (NSInteger idx = 0 idx < [self length]idx++)
    {
    [hexString appendFormat:@"%02.2hhx", bytes[idx]]
    }
    
    return hexString
    
    }
    //-(NSData*) HMAC_SHA1DataWithSecret:(NSData*)key
    //{
    //    const void *cKey  = key.bytes
    //    const void *cData = self.bytes
    //
    //    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH]
    //
    //    CCHmac(kCCHmacAlgSHA1, cKey, key.length, cData, self.length, cHMAC)
    //
    //    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)]
    //}
    //-(NSData*) HMAC_SHA256DataWithSecret:(NSData*)key
    //{
    //
    //    const void *cKey  = [key bytes]
    //    const void *cData = self.bytes
    //
    //    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH]
    //
    //    CCHmac(kCCHmacAlgSHA256, cKey, [key length], cData, self.length, cHMAC)
    //
    //    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)]
    //
    //}
    + (NSData*)dataFromHexString:(NSString*)string
    {
    if (string == nil) {
    return nil
    }
    NSMutableData *data= [[NSMutableData alloc] init]
    unsigned char whole_byte
    char byte_chars[3] = {'\0','\0','\0'}
int i
for (i=0 i < (string.length / 2) i++) {
    byte_chars[0] = [string characterAtIndex:i*2]
    byte_chars[1] = [string characterAtIndex:i*2+1]
    whole_byte = strtol(byte_chars, NULL, 16)
    [data appendBytes:&whole_byte length:1]
}
return data
}
-(NSData*)HKDFDataWithAlgorithm:(CCHmacAlgorithm)algorithm Info:(NSData*)info withLength:(NSUInteger)length Salt:(NSData*)salt
{
    // Step 1 of RFC 5869
    // Extract
    // Get sha256HMAC Bytes
    // Input: salt (message), IKM (input keyring material)
    // Output: PRK (pseudorandom key)
    NSData *PRK = [self HMACDataWithAlgorithm:algorithm sectet:salt]
    
    // Step 2 of RFC 5869.
    // Expand
    // Input: PRK from step 1, info, length.
    // Output: OKM (output keyring material).
    NSInteger iterations = ceil(length)
    NSMutableData *Tn = [NSMutableData data]
    NSMutableData *T = [NSMutableData data]
    for (NSInteger idx = 0idx < iterationsidx++) {
        [Tn appendData:info]
        const char value = idx+1
        [Tn appendBytes:&value length:sizeof(const char)]
        Tn = [[Tn HMACDataWithAlgorithm:algorithm sectet:PRK] mutableCopy]
        
        [T appendData:Tn]
    }
    return [T subdataWithRange:NSMakeRange(0, length)]
}

}