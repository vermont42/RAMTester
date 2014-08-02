//
//  ViewController.m
//  RAMTester
//
//  Created by Josh Adams on 4/6/14.
//  Copyright (c) 2014 Josh Adams. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIView *combinedButton;
@property (strong, nonatomic) IBOutlet UIButton *dictButton;
@property (strong, nonatomic) IBOutlet UIButton *dataButton;
@property (strong, nonatomic) IBOutlet UIButton *arrayButton;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@end

@implementation ViewController
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"Received memory warning.");
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self testData];
    //[self testDictionary];
    //[self testArray];
    //[self testCombined];
}

static const float ANIMATION_DURATION = 0.5;
static const int ANIMATION_DELAY = 0.0;

- (void)updateUI
{
    self.arrayButton.enabled = NO;
    self.dictButton.enabled = NO;
    self.dataButton.enabled = NO;
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         self.statusLabel.alpha = 1.0;
                     } completion:nil];
}

static const long PAUSE_INTERVAL = 100000;
static const double PAUSE_DURATION = .5;

- (IBAction)testCombined {
    [self updateUI];
    NSMutableArray *array = [NSMutableArray new];
    NSMutableData *data = [NSMutableData new];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dispatch_queue_t testQ = dispatch_queue_create("combined test queue", NULL);
    dispatch_async(testQ, ^{
        for (long i = 0;; i++)
        {
            [array addObject:@"foo"];
            [data appendBytes:&i length:sizeof(long)];
            [dict setObject:@"foo" forKey:[NSString stringWithFormat:@"%ld", i]];
            //if (i % PAUSE_INTERVAL == 0)
            //{
            //    [NSThread sleepForTimeInterval:PAUSE_DURATION];
            //}
        }
    });
}

- (IBAction)testArray
{
    [self updateUI];
    NSMutableArray *array = [NSMutableArray new];
    dispatch_queue_t testQ = dispatch_queue_create("NSMutableArray test queue", NULL);
    dispatch_async(testQ, ^{
        for (long i = 0;; i++)
        {
            [array addObject:@"foo"];
            //if (i % PAUSE_INTERVAL == 0)
            //{
            //    [NSThread sleepForTimeInterval:PAUSE_DURATION];
            //}
        }
    });
}

- (IBAction)testData
{
    [self updateUI];
    NSMutableData *data = [NSMutableData new];
    dispatch_queue_t testQ = dispatch_queue_create("NSData test queue", NULL);
    dispatch_async(testQ, ^{
        for (long i = 0;; i++)
        {
            [data appendBytes:&i length:sizeof(long)];
            //if (i % PAUSE_INTERVAL == 0)
            //{
            //    [NSThread sleepForTimeInterval:PAUSE_DURATION];
            //}
        }
    });
}

- (IBAction)testDictionary
{
    [self updateUI];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dispatch_queue_t testQ = dispatch_queue_create("NSDictionary test queue", NULL);
    dispatch_async(testQ, ^{
        for (long i = 0;; i++)
        {
            [dict setObject:@"foo" forKey:[NSString stringWithFormat:@"%ld", i]];
            //if (i % PAUSE_INTERVAL == 0)
            //{
            //    [NSThread sleepForTimeInterval:PAUSE_DURATION];
            //}
        }
    });
}
@end
