IPaSecurity
===========

IPaSecurity - Category of NSString and NSData

NSString+IPaSecurity

caculate SHA1,SHA256,MD5 string

-(NSString*) SHA1String;
-(NSString*) SHA256String;
-(NSString*) MD5String;

NSData+IPaSecurity

caculate SHA1,SHA256,MD5,Base64 string
create NSData with Base64 encoded string and with Hex string

-(NSString*)SHA1String;
-(NSString*)SHA256String;
-(NSString*)MD5String;
-(NSString*)Base64String;
+ (NSData*)dataWithBase64EncodedString:(NSString *)string;
+ (NSData*)dataFromHexString:(NSString*)string;
-(NSString*)HexString;
Use CommonCrypto

can do data encrypt and decrypt

-(NSData*)CipherWithOperation:(CCOperation)operation algorighm:(CCAlgorithm)algorithm mode:(CCMode)mode padding:(BOOL)padding iv:(NSData*)iv key:(NSData*)key options:(CCModeOptions)options;

can do Hash-based Message Authentication Code，HMAC
-(NSData*)HMACDataWithAlgorithm:(CCHmacAlgorithm)algorithm sectet:(NSData*)key;

can do  HMAC-based Extract-and-Expand Key Derivation Function (HKDF)

-(NSData*)HKDFDataWithAlgorithm:(CCHmacAlgorithm)algorithm Info:(NSData*)info withLength:(NSUInteger)length Salt:(NSData*)salt;
