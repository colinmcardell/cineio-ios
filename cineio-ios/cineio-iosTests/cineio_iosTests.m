//
//  cineio_iosTests.m
//  cineio-iosTests
//
//  Created by Jeffrey Wescott on 6/3/14.
//  Copyright (c) 2014 cine.io. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <XCTAsyncTestCase/XCTAsyncTestCase.h>
#import "CineClient.h"

const NSString *StreamName = @"my stream";

@interface cineio_iosTests : XCTAsyncTestCase
{
    CineClient *_client;
    __block CineStream *_stream;
}
@end

@implementation cineio_iosTests

- (void)setUp
{
    [super setUp];
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"cineio-settings" ofType:@"plist"];
    NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:path];
    _client = [[CineClient alloc] initWithSecretKey:settings[@"CINE_IO_SECRET_KEY"]];
    
    [self prepare];
    [_client createStream:@{ @"name" : StreamName } withCompletionHandler:^(NSError* error, CineStream* stream) {
        if (error) {
            [self notify:kXCTUnitWaitStatusFailure];
        } else {
            XCTAssertEqualObjects(stream.name, StreamName);
            _stream = stream;
            [self notify:kXCTUnitWaitStatusSuccess];
        }
    }];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:5.0];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCreate
{
    XCTAssertNotNil(_stream);
    XCTAssertEqualObjects(_stream.name, StreamName);
}

- (void)testGet
{
    [self prepare];
    [_client getStream:_stream.streamId withCompletionHandler:^(NSError *error, CineStream *stream) {
        if (error) {
            [self notify:kXCTUnitWaitStatusFailure];
        } else {
            XCTAssertEqualObjects(stream.streamId, _stream.streamId);
            [self notify:kXCTUnitWaitStatusSuccess];
        }
    }];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:5.0];
}

- (void)testGetAllStreams
{
    [self prepare];
    [_client getStreamsWithCompletionHandler:^(NSError *error, NSArray *streams) {
        if (error) {
            [self notify:kXCTUnitWaitStatusFailure];
        } else {
            XCTAssert(streams.count > 0);
            BOOL found = false;
            for (CineStream *stream in streams) {
                found = found || ([stream.streamId isEqualToString:_stream.streamId]);
            }
            XCTAssert(found);
            [self notify:kXCTUnitWaitStatusSuccess];
        }
    }];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:5.0];
}

- (void)testUpdate
{
    [self prepare];
    [_client updateStream:@{ @"id" : _stream.streamId, @"name" : @"my other stream" } withCompletionHandler:^(NSError *error, CineStream *stream) {
        if (error) {
            [self notify:kXCTUnitWaitStatusFailure];
        } else {
            XCTAssertEqualObjects(stream.name, @"my other stream");
            [self notify:kXCTUnitWaitStatusSuccess];
        }
    }];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:5.0];
}

- (void)testDelete
{
    [self prepare];
    [_client deleteStream:_stream.streamId withCompletionHandler:^(NSError *error, NSHTTPURLResponse *response) {
        if (error || response.statusCode != 200) {
            [self notify:kXCTUnitWaitStatusFailure];
        } else {
            [self notify:kXCTUnitWaitStatusSuccess];
        }
    }];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:5.0];
}

@end
