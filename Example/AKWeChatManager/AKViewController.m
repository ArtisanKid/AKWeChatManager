//
//  AKViewController.m
//  AKWeChatManager
//
//  Created by Freud on 01/20/2017.
//  Copyright (c) 2017 Freud. All rights reserved.
//

#import "AKViewController.h"
#import "AKWeChatManager.h"

@interface AKViewController ()

@end

@implementation AKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor darkGrayColor];
    button.frame = (CGRect){{0., 20.}, {CGRectGetWidth(self.view.bounds), 44.}};
    [button setTitle:@"登录" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(loginButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginButtonTouchUpInside:(UIButton *)sender {
    [AKWeChatManager loginSuccess:^(id<AKWeChatUserProtocol>  _Nonnull user) {
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

@end
