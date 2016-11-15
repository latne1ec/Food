//
//  YPAPISample.m
//  YelpAPI

#import "YPAPISample.h"
#import "NSURLRequest+OAuth.h"

/**
 Default paths and search terms used in this example
 */
static NSString * const kAPIHost           = @"api.yelp.com";
static NSString * const kSearchPath        = @"/v2/search/";
static NSString * const kBusinessPath      = @"/v2/business/";
static NSString * const kSearchLimit       = @"7";

@implementation YPAPISample

#pragma mark - Public

- (void)queryVenues:(NSString *)term location:(NSString *)location coordinates:(NSString *)coordinates category:(NSString *)category completionHandler:(void (^)(NSMutableArray *venues, NSError *error))completionHandler {
    
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    
    __block bool finished;
    finished = false;
    
    location = @"Bernal Heights";
    
    //Make a first request to get the search results with the passed term and location
    NSURLRequest *searchRequest = [self _searchRequestWithTerm:term location:location coordinates:coordinates category:category];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:searchRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if (!error && httpResponse.statusCode == 200) {
            
            NSDictionary *searchResponseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSArray *businessArray = searchResponseJSON[@"businesses"];
            
            array = [[NSArray arrayWithArray:businessArray] mutableCopy];
            finished = true;
            
            completionHandler(array, nil);
            
        } else {
            
            NSLog(@"Error: %@", error);
        }
    }] resume];
}

- (NSArray *)queryTopBusinessInfoForTerm:(NSString *)term location:(NSString *)location completionHandler:(void (^)(NSDictionary *topBusinessJSON, NSError *error))completionHandler {

  //NSLog(@"Querying the Search API with term \'%@\' and location \'%@'", term, location);

    __block NSArray *array = [[NSArray alloc] init];
    
  //Make a first request to get the search results with the passed term and location
  NSURLRequest *searchRequest = [self _searchRequestWithTerm:term location:location coordinates:@"" category:@""];
  NSURLSession *session = [NSURLSession sharedSession];
  [[session dataTaskWithRequest:searchRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

    if (!error && httpResponse.statusCode == 200) {

      NSDictionary *searchResponseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
      NSArray *businessArray = searchResponseJSON[@"businesses"];
        
        array = [NSArray arrayWithArray:businessArray];

      if ([businessArray count] > 0) {
        NSDictionary *firstBusiness = [businessArray firstObject];
        NSString *firstBusinessID = firstBusiness[@"id"];
        //NSLog(@"%lu businesses found, querying business info for the top result: %@", (unsigned long)[businessArray count], firstBusinessID);

        [self queryBusinessInfoForBusinessId:firstBusinessID completionHandler:completionHandler];
      } else {
        completionHandler(nil, error); // No business was found
      }
    } else {
      completionHandler(nil, error); // An error happened or the HTTP response is not a 200 OK
    }
  }] resume];
    
    return array;
}

- (void)queryBusinessInfoForBusinessId:(NSString *)businessID completionHandler:(void (^)(NSDictionary *topBusinessJSON, NSError *error))completionHandler {

  NSURLSession *session = [NSURLSession sharedSession];
  NSURLRequest *businessInfoRequest = [self _businessInfoRequestForID:businessID];
  [[session dataTaskWithRequest:businessInfoRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (!error && httpResponse.statusCode == 200) {
      NSDictionary *businessResponseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

      completionHandler(businessResponseJSON, error);
    } else {
      completionHandler(nil, error);
    }
  }] resume];

}


#pragma mark - API Request Builders

/**
 Builds a request to hit the search endpoint with the given parameters.
 
 @param term The term of the search, e.g: dinner
 @param location The location request, e.g: San Francisco, CA

 @return The NSURLRequest needed to perform the search
 */
- (NSURLRequest *)_searchRequestWithTerm:(NSString *)term location:(NSString *)location coordinates:(NSString *)coordinates category:(NSString *)category {
    
    int offset = 0;
    int sort = 1;
    if ([category isEqualToString:@"restaurants"]) {
        offset = arc4random_uniform(20);
        sort = 1;
         NSLog(@"surprise! %d", offset);
    }
    
    NSLog(@"Coordinates: %@", coordinates);
    
    NSArray *myArray = [coordinates componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
    
    CLLocationDegrees lat = [[myArray objectAtIndex:0] doubleValue];
    CLLocationDegrees lon = [[myArray objectAtIndex:1] doubleValue];
    CLLocationCoordinate2D dasCoordinates;
    dasCoordinates.latitude = lat;
    dasCoordinates.longitude = lon;

    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(dasCoordinates, 10000, 10000);
    CLLocationCoordinate2D northEastCorner = CLLocationCoordinate2DMake(
                                                                        dasCoordinates.latitude - (region.span.latitudeDelta),
                                                                        dasCoordinates.longitude + (region.span.longitudeDelta)
                                                                        );
    CLLocationCoordinate2D southWestCorner = CLLocationCoordinate2DMake(
                                                                        dasCoordinates.latitude + (region.span.latitudeDelta),
                                                                        dasCoordinates.longitude - (region.span.longitudeDelta)
                                                                        );
    

    NSString *boundsString = [NSString stringWithFormat:@"%f,%f,%f,%f", northEastCorner.latitude, northEastCorner.longitude, southWestCorner.latitude, southWestCorner.longitude];
    
    NSLog(@"Bounds: %@", boundsString);
    
    NSString *newstring;
    
    newstring = boundsString.stringByRemovingPercentEncoding;
    
    
    //newstring = [boundsString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    
    NSDictionary *params = @{
                           @"term": term,
                           //@"location": location,
                           @"ll": coordinates,
                           //@"bounds" : newstring,
                           @"limit": kSearchLimit,
                           @"sort" : [NSString stringWithFormat:@"%d", sort],
                           @"category_filter" : category,
                           @"offset" : [NSString stringWithFormat:@"%d", offset],
                           };
    
  

   //NSLog(@"Hi: %@", [NSURLRequest requestWithHost:kAPIHost path:kSearchPath params:params]);
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithHost:kAPIHost path:kSearchPath params:params];
    NSURL *url = urlRequest.URL;
    NSString *urlString = [NSString stringWithFormat:@"%@", url];
    urlString = urlString.stringByRemovingPercentEncoding;
    //NSLog(@"URL String: %@", urlString);
    //NSURLRequest *dasRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    //NSLog(@"URL String: %@", dasRequest);
    
  return [NSURLRequest requestWithHost:kAPIHost path:kSearchPath params:params];
    
}

/**
 Builds a request to hit the business endpoint with the given business ID.
 
 @param businessID The id of the business for which we request informations

 @return The NSURLRequest needed to query the business info
 */
- (NSURLRequest *)_businessInfoRequestForID:(NSString *)businessID {

  NSString *businessPath = [NSString stringWithFormat:@"%@%@", kBusinessPath, businessID];
  return [NSURLRequest requestWithHost:kAPIHost path:businessPath];
}

@end
