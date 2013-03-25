IPaURLTool
==========

some tool for url connection


IPaURLConnection
=======================

Block-base NSURLConnection for IOS

you can easily use class method


+ (id)URLConnectionWithURLString:(NSString*)URL
               cachePolicy:(NSURLRequestCachePolicy)cachePolicy
           timeoutInterval:(NSTimeInterval)timeoutInterval
                  callback:(void (^)(NSURLResponse *,NSData*))callback
              failCallback:(void (^)(NSError*))failCallback;




to create NSURLConnection (if you use class method,you don't need to make [NSURLConnection start],it will automatically to do that)

you can set delegate IPaURLConnection.connectionDelegate to catch other callback from NSURLConnection



you can manually create IPaURLConnection with -(id)initWithRequest:(NSURLRequest *)request

set callback manually
IPaURLConnection.FinishCallback is a block object,it'll call when connection is done
IPaURLConnection.FailCallback is a block object,it'll call when something wrong

IPaURLConnection.response is response when connection is started

IPaURLConnection.receiveData is result data



IPaHTTPDownloadConnection
=======================

IPaHTTPDownloadConnection is just like IPaURLConnection  with the same parent IPaConnectionBase

initial it with
-(id)initWithDownloadURLString:(NSString *)URL toFilePath:(NSString*)filePath cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval;

if the filePath exist, it will resume download 

you can add an observer at progress, if you want to update UI for progress update




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



