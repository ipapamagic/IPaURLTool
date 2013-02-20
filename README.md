IPaURLTool
==========

some tool for url connection


IPaURLConnection
=======================

Block-base NSURLConnection for IOS

you can easily use class method

+ (id)IPaURLConnectionWithURLString:(NSString*)URL
               cachePolicy:(NSURLRequestCachePolicy)cachePolicy
           timeoutInterval:(NSTimeInterval)timeoutInterval
                  callback:(void (^)(NSURLResponse *,NSData*))callback;

+ (id)IPaURLConnectionWithURLString:(NSString*)URL
               cachePolicy:(NSURLRequestCachePolicy)cachePolicy
           timeoutInterval:(NSTimeInterval)timeoutInterval
                  callback:(void (^)(NSURLResponse *,NSData*))callback
              failCallback:(void (^)(NSError*))failCallback;

+ (id)IPaURLConnectionWithURLString:(NSString*)URL
               cachePolicy:(NSURLRequestCachePolicy)cachePolicy
           timeoutInterval:(NSTimeInterval)timeoutInterval
                  callback:(void (^)(NSURLResponse *,NSData* ))callback
              failCallback:(void (^)(NSError*))failCallback
           receiveCallback:(void (^)(NSURLResponse *,NSData*,NSData* ))receiveCallback;




+ (id)IPaURLConnectionWithURLRequest:(NSURLRequest*)request
                         callback:(void (^)(NSURLResponse *,NSData*))callback
                     failCallback:(void (^)(NSError*))failCallback
                     receiveCallback:(void (^)(NSURLResponse *,NSData*,NSData*))receiveCallback;


to create NSURLConnection (if you use class method,you don't need to make [NSURLConnection start],it will automatically to do that)



IPaImageURLLoader
=======================

has only one method

-(void)loadImageWithURL:(NSString*)imgURL withCallback:(void (^)(UIImage*))callback;

load UIImage by url


IPaImageURL category for UIImageView and UIButton

some time you need to load an UIImage by url

these categories make it easier

when your UIButton or UIImageView are in UITableView

url may change before last image downloaded

these categories handle these jobs


@interface UIButton (IPaImageURL)
-(void)setImageURL:(NSString*)imageURL forState:(UIControlState)state;

-(void)setImageURL:(NSString*)imageURL forNormalAndOtherStates:(NSInteger)states;

if you need to set image the same as normalState

use '|' to set the state you want as Argument

ex: UIControlStateHighlighted | UIControlStateDisabled



