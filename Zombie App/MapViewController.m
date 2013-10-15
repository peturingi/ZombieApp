//
//  MapViewController.m
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 14/10/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

#pragma mark - View Setup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Assuming that all subviews have loaded.
    gc = [GameController sharedInstance];
    [gc setDelegate:self];
    
    [self addObserver:gc forKeyPath:@"hp" options:NSKeyValueObservingOptionNew context:nil];
        
    
 }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - game controller delegate methods

-(void)updateElapsedTime:(NSInteger)elapsedTime{
    
    [[self eltLabel]setText:[NSString stringWithFormat:@"%ld", (long)elapsedTime]];
#warning not implemented

}
-(void)updatePlayerHealth{
#warning not implemented

}
-(void)updatePlayerScore{
#warning not implemented

}
-(void)updatePlayerSpeed{
#warning not implemented

}
@end
