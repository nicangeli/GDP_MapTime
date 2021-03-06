//
//  TimeLineDownloaderDelegate.m
//  MapTime
//
//  Created by Nicholas Angeli on 02/11/2012.
//  Copyright (c) 2012 MapTime. All rights reserved.
//

#import "TimeLineDownloaderDelegate.h"
#import "TBXML.h"
#import "MBProgressHUD.h"


@implementation TimeLineDownloaderDelegate

-(id)init
{
    self = [super init];
    if(self != nil) {
        timeLineData = [[NSMutableData alloc] init];
        timeLines = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"TIMELINE RESPONSE");
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"TIMELINE DATA RECEIVED");
    [timeLineData appendData:data];

}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"TIMELINE ERROR");
    [self postErrorNotification];

}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Finished Downloading");

    [self parseXML:timeLineData];
    
    [self postFinishedNotification];
}

-(NSMutableArray *)getTimeLines
{
    return timeLines;
}

-(void)parseXML:(NSData *)xml
{
    TBXML *tbxml = [TBXML newTBXMLWithXMLData:xml error:nil];
    TBXMLElement * rootXMlElement = tbxml.rootXMLElement;
       
    if(rootXMlElement) {
        [self traverseElement:rootXMlElement->firstChild];
        
    }
    
}

-(void)traverseElement:(TBXMLElement *)element
{
    // should have the first child element of <timelines>, i.e. should be a timeline object
    do {
        
        if([[TBXML elementName:element] isEqualToString:@"timeline"]) { // sanity check, should always be
            NSString *name = [TBXML valueOfAttributeNamed:@"timelineName" forElement:element];
            TimeLine *tl = [[TimeLine alloc] initWithName:name];
            //NSLog(@"Timeline found with name: %@", [tl getName]);
            [self traverseTimeLineElement:element->firstChild withTimeLineObject:tl];
            [timeLines addObject:tl];
            NSLog(@"I am adding an object");
            
        }
        
    } while((element = element->nextSibling));
}

-(void)traverseTimeLineElement:(TBXMLElement *)element withTimeLineObject:(TimeLine *)timeLine
{
    // we should now just have one timeline object
    do {
        
        if([[TBXML elementName:element] isEqualToString:@"timepoint"]) { 
            TBXMLElement *name = [TBXML childElementNamed:@"name" parentElement:element];
            TBXMLElement *description = [TBXML childElementNamed:@"description" parentElement:element];
            TBXMLElement *sourceName = [TBXML childElementNamed:@"sourceName" parentElement:element];
            TBXMLElement *sourceURL = [TBXML childElementNamed:@"sourceURL" parentElement:element];
            TBXMLElement *year = [TBXML childElementNamed:@"year" parentElement:element];
            TBXMLElement *yearUnitID = [TBXML childElementNamed:@"yearUnitID" parentElement:element];
            TBXMLElement *month = [TBXML childElementNamed:@"month" parentElement:element];
            TBXMLElement *day = [TBXML childElementNamed:@"day" parentElement:element];
            TBXMLElement *yearInBC = [TBXML childElementNamed:@"yearInBC" parentElement:element];
            
            NSString *timePointname = [TBXML textForElement:name];
            NSString *timePointDescription = [TBXML textForElement:description];
            NSString *timePointSourceName = [TBXML textForElement:sourceName];
            NSString *timePointSourceURL = [TBXML textForElement:sourceURL];
            NSString *timePointYear = [TBXML textForElement:year];
            NSString *timePointYearUnitId = [TBXML textForElement:yearUnitID];
            NSString *timePointMonth = [TBXML textForElement:month];
            NSString *timePointDay = [TBXML textForElement:day];
            NSString *timePointYearInBC = [TBXML textForElement:yearInBC];
            
            TimePoint *timePoint = [[TimePoint alloc] init];
            [timePoint setName:timePointname];
            [timePoint setDescription:timePointDescription];
            [timePoint setSourceName:timePointSourceName];
            [timePoint setSourceURL:timePointSourceURL];
            [timePoint setYear:timePointYear];
            [timePoint setYearUnitID:timePointYearUnitId];
            [timePoint setMonth:timePointMonth];
            [timePoint setDay:timePointDay];
            [timePoint setYearInBC:timePointYearInBC];
            
            //NSLog(@"Adding TimePoint to timeline %@", timeLine);
            [timeLine addTimePoint:timePoint];
        }
        
    } while((element = element->nextSibling));
}

/*
 Notification Methods
 */

-(void)postFinishedNotification
{
    NSLog(@"I am sending a finished notification");
    NSString *notificationName = @"TimeLinesDownloaded";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
    
}

-(void)postErrorNotification
{
    NSLog(@"I am sending a error notification");
    NSString *notificationName = @"ErrorNotification";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}


@end
