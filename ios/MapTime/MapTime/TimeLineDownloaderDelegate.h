//
//  TimeLineDownloaderDelegate.h
//  MapTime
//
//  Created by Nicholas Angeli on 02/11/2012.
//  Copyright (c) 2012 MapTime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimeLine.h"
#import "TimePoint.h"

@interface TimeLineDownloaderDelegate : NSObject <NSURLConnectionDataDelegate>
{
    NSMutableData *timeLineData;
    NSMutableArray *timeLines;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

-(void)connectionDidFinishLoading:(NSURLConnection *)connection;

-(void)parseXML:(NSData *)xml;

@end