//
//    Copyright (c) 2014 Max Sokolov (http://maxsokolov.net)
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy of
//    this software and associated documentation files (the "Software"), to deal in
//    the Software without restriction, including without limitation the rights to
//    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//    the Software, and to permit persons to whom the Software is furnished to do so,
//    subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "GKQuery.h"

@interface GKQuery ()

@property (nonatomic, strong) NSOperationQueue *backgroundQueue;

@end

@implementation GKQuery

+ (GKQuery *)query {

    return [[GKQuery alloc] init];
}

- (id)init {

    self = [super init];
    if (self) {

        self.backgroundQueue = [[NSOperationQueue alloc] init];
        self.sensor = YES;
    }
    return self;
}

- (void)performQuery {

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[self queryURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
    [NSURLConnection sendAsynchronousRequest:request queue:self.backgroundQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (connectionError) {

            [self handleQueryError:connectionError];
            return;
        }
        
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

        if (error) {

            [self handleQueryError:error];
            return;
        }

        if ([[json objectForKey:@"status"] isEqualToString:@"OK"] ||
            [[json objectForKey:@"status"] isEqualToString:@"ZERO_RESULTS"]) {

            [self handleQueryResponse:json];
            return;
        }
        
        // OVER_QUERY_LIMIT, REQUEST_DENIED, INVALID_REQUEST etc.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[json objectForKey:@"status"] forKey:NSLocalizedDescriptionKey];
        [self handleQueryError:[NSError errorWithDomain:@"com.googlekit" code:0 userInfo:userInfo]];
    }];
}

- (void)cancelQuery {

    [self.backgroundQueue cancelAllOperations];
}

#pragma mark - Methods to override

- (NSURL *)queryURL {

    return nil;
}

- (void)handleQueryError:(NSError *)error {

    return;
}

- (void)handleQueryResponse:(NSDictionary *)response {

    return;
}

@end