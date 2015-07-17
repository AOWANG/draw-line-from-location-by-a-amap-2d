//
//  BaseMapViewController.m
//  SearchV3Demo
//
//  Created by songjian on 13-8-14.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "MainViewController.h"
#import "MAMutablePolyline.h"
#import "MAMutablePolylineRenderer.h"
#import "StatusView.h"
#import "TipView.h"

@interface MainViewController()

@property (nonatomic, strong)CLLocationManager *locationManager;

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) StatusView *statusView;
@property (nonatomic, strong) TipView *tipView;
@property (nonatomic, strong) UIButton *locationBtn;
@property (nonatomic, strong) UIImage *imageLocated;
@property (nonatomic, strong) UIImage *imageNotLocate;

@property (nonatomic, assign) BOOL isRecording;

@property (nonatomic, strong) MAMutablePolyline *mutablePolyline;
@property (nonatomic, strong) MAMutablePolylineRenderer *render;

@property (nonatomic, assign) NSUInteger locationCount;

@end


@implementation MainViewController

#pragma mark - MapView Delegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (!updatingLocation)
    {
        return;
    }
    
    if (self.isRecording)
    {
        if (userLocation.location.horizontalAccuracy < 80 && userLocation.location.horizontalAccuracy > 0)
        {
            [self.tipView showTip:[NSString stringWithFormat:@"has got %ld locations",self.locationCount++]];
            
            [self.mutablePolyline appendPoint: MAMapPointForCoordinate(userLocation.location.coordinate)];
            
            [self.mapView setZoomLevel:15 animated:YES];
            
            [self.render setNeedsDisplay];
        }
    }
        
    [self.statusView showStatusWith:userLocation.location];
}

- (MAOverlayPathRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAMutablePolyline class]])
    {
        MAMutablePolylineRenderer *renderer = [[MAMutablePolylineRenderer alloc] initWithOverlay:overlay];
        self.render = renderer;
        return renderer;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView  didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated
{
    if (mode == MAUserTrackingModeNone)
    {
        [self.locationBtn setImage:self.imageNotLocate forState:UIControlStateNormal];
    }
    else
    {
        [self.locationBtn setImage:self.imageLocated forState:UIControlStateNormal];
    }
}

#pragma mark - Handle Action

- (void)actionRecordAndStop
{
    self.isRecording = !self.isRecording;
    
    if (self.isRecording)
    {
        [self.tipView showTip:@"Start recording"];
        self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"icon_stop.png"];
    }
    else
    {
        self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"icon_play.png"];
        [self.tipView showTip:@"0 locations"];
        self.locationCount = 0;
        
        [self.mutablePolyline.pointArray removeAllObjects];
    }
}

- (void)actionLocation
{
    if (self.mapView.userTrackingMode == MAUserTrackingModeFollow)
    {
        [self.mapView setUserTrackingMode:MAUserTrackingModeNone];
    }
    else
    {
        [self.mapView setUserTrackingMode:MAUserTrackingModeFollow];
    }
}

#pragma mark - Initialization

- (void)initStatusView
{
    self.statusView = [[StatusView alloc] initWithFrame:CGRectMake(5, 35, 150, 150)];
    
    [self.view addSubview:self.statusView];
}

- (void)initTipView
{
    self.locationCount = 0;
    
    self.tipView = [[TipView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height*0.95, self.view.bounds.size.width, self.view.bounds.size.height*0.05)];
    
    [self.view addSubview:self.tipView];
}

- (void)initMapView
{
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager requestAlwaysAuthorization];
    }
    
    /* set the mapview location config */
    self.mapView.showsUserLocation = true;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    self.mapView.distanceFilter = 10;
    self.mapView.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
}

- (void)initNavigationBar
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_play.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(actionRecordAndStop)];
    self.isRecording = NO;
}

- (void)initOverlay
{
    self.mutablePolyline = [[MAMutablePolyline alloc] initWithPoints:@[]];
}

- (void)initLocationButton
{
    self.imageLocated = [UIImage imageNamed:@"location_yes.png"];
    self.imageNotLocate = [UIImage imageNamed:@"location_no.png"];
    
    self.locationBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(self.view.bounds)*0.8, 50, 50)];
    self.locationBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.locationBtn.backgroundColor = [UIColor whiteColor];
    self.locationBtn.layer.cornerRadius = 5;
    [self.locationBtn addTarget:self action:@selector(actionLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.locationBtn setImage:self.imageNotLocate forState:UIControlStateNormal];
    
    [self.view addSubview:self.locationBtn];
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"My Route"];
    
    [self initNavigationBar];
    
    [self initMapView];
    
    [self initOverlay];
    
    [self initStatusView];
    
    [self initTipView];
    
    [self initLocationButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.mapView addOverlay:self.mutablePolyline];
    
    self.mapView.visibleMapRect = MAMapRectMake(220880104, 101476980, 272496, 466656);
}

@end
