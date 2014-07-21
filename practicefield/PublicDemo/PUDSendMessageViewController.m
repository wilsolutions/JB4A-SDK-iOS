//
//  PUDSendPageViewController.m
//  PublicDemo
//
//  Created by Matt Lathrop on 6/12/14.
//  Copyright (c) 2014 ExactTarget. All rights reserved.
//

#import "PUDSendMessageViewController.h"

// Controllers
#import "PUDPageContentViewController.h"

// Libraries
#import "ETPush.h"

// Models
#import "PUDMessageComposeTableData.h"

@interface PUDSendMessageViewController ()

@property (nonatomic, strong) UIView *buttonView;

@property BOOL viewMessageButtonHidden;

@property (nonatomic, strong) UIImageView *navBarSeparator;

@end

@implementation PUDSendMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     *  Handle layout differences between iOS 6 and 7
     */
    CGFloat heightDifference = 49;
    
    if (IOS_PRE_7_0) {
        heightDifference = 0;
    }
    
    /**
     *  Change size of page view controller
     */
    self.pageViewController.view.frame = CGRectMake(0,
                                                    44,
                                                    self.view.frame.size.width,
                                                    self.view.frame.size.height - heightDifference - 44);
    /**
     *  Create the view that will contain the buttons
     */
    self.buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    
    /**
     *  Match the color that's in the tab bar
     */
    self.buttonView.backgroundColor = [UIColor colorWithRed:0.0/255.0
                                                      green:156.0/255.0
                                                       blue:219.0/255.0
                                                      alpha:0.99];
    
    [self setupButtonView];
    
    /**
     *  Add the buttonView to the screen
     */
    if (IOS_PRE_7_0) {
        CGRect newFrame = self.buttonView.frame;
        newFrame.origin.y = 0;
        self.buttonView.frame = newFrame;
        [self.view addSubview:self.buttonView];
    }
    else {
        [self.pageViewController.view addSubview:self.buttonView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.viewMessageButtonHidden && [[NSUserDefaults standardUserDefaults] objectForKey:kPUDUserDefaultsPushUserInfo]) {
        [self.buttonView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self setupButtonView];
    }
}

- (void)setupButtonView {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kPUDUserDefaultsPushUserInfo]) {
        self.viewMessageButtonHidden = NO;
        
        /**
         *  Create the view last message button
         */
        UIButton *sendMessageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, (self.view.frame.size.width / 2) - 0.5, 43)];
        [sendMessageButton addTarget:self action:@selector(sendMessageNowButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [sendMessageButton setTitle:@"SEND MESSAGE" forState:UIControlStateNormal];
        [sendMessageButton setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
        sendMessageButton.titleLabel.font = [UIFont boldSystemFontOfSize:10.0];
        
        CGFloat halfImageViewWidth = sendMessageButton.imageView.frame.size.width / 2;
        sendMessageButton.titleEdgeInsets = UIEdgeInsetsMake(44 - halfImageViewWidth - 4, -sendMessageButton.imageView.frame.size.width, 0, 0);
        sendMessageButton.imageEdgeInsets = UIEdgeInsetsMake(-12, sendMessageButton.frame.size.width / 2 - halfImageViewWidth, 0, 0);
        [self.buttonView addSubview:sendMessageButton];
        
        /**
         *  Create the separator view
         */
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 0.5, 0, 1, 43)];
        separatorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self.buttonView addSubview:separatorView];
        
        /**
         *  Create the send message button
         */
        UIButton *viewMessageButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) + 1, sendMessageButton.frame.origin.y, sendMessageButton.frame.size.width, sendMessageButton.frame.size.height)];
        [viewMessageButton addTarget:self action:@selector(viewLastMessageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [viewMessageButton setTitle:@"VIEW MESSAGE" forState:UIControlStateNormal];
        [viewMessageButton setImage:[UIImage imageNamed:@"view"] forState:UIControlStateNormal];
        
        viewMessageButton.titleLabel.font = sendMessageButton.titleLabel.font;
        viewMessageButton.backgroundColor = sendMessageButton.backgroundColor;
        viewMessageButton.titleEdgeInsets = sendMessageButton.titleEdgeInsets;
        viewMessageButton.imageEdgeInsets = sendMessageButton.imageEdgeInsets;
        viewMessageButton.showsTouchWhenHighlighted = sendMessageButton.showsTouchWhenHighlighted;
        [self.buttonView addSubview:viewMessageButton];
    }
    else {
        self.viewMessageButtonHidden = YES;
        
        /**
         *  Create the view last message button
         */
        UIButton *sendMessageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        [sendMessageButton addTarget:self action:@selector(sendMessageNowButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [sendMessageButton setTitle:@"SEND MESSAGE" forState:UIControlStateNormal];
        [sendMessageButton setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
        sendMessageButton.titleLabel.font = [UIFont boldSystemFontOfSize:10.0];
        
        CGFloat halfImageViewWidth = sendMessageButton.imageView.frame.size.width / 2;
        sendMessageButton.titleEdgeInsets = UIEdgeInsetsMake(44 - halfImageViewWidth - 4, -sendMessageButton.imageView.frame.size.width, 0, 0);
        sendMessageButton.imageEdgeInsets = UIEdgeInsetsMake(-12, sendMessageButton.frame.size.width / 2 - sendMessageButton.imageView.frame.size.width * 3, 0, 0);
        [self.buttonView addSubview:sendMessageButton];
    }
}

#pragma mark - methods required by abstract base class

- (NSString *)htmlPrefix {
    return @"<html style=\"margin:10px; font-size:16px; word-wrap: break-word;\"><font color=\"black\" face=\"Avenir Next\">";
}

- (NSArray *)pageHtml {
    return @[[self basicHtml],
             [self tagHtml],
             [self noTagHtml],
             [self openDirectHtml],
             [self customKeysHtml],
             [self locationHtml]];
}

#pragma mark - button handling

- (void)viewLastMessageButtonTapped:(UIButton *)sender {
    [self performSegueWithIdentifier:kPUDSegueMessagesToLastReceivedPush sender:self];
}

- (void)sendMessageNowButtonTapped:(UIButton *)sender {
    if (![ETPush isPushEnabled]) {
        NSString *message = @"Please enable Push Notifications inside the Settings app in order to send messages.";
        [[[UIAlertView alloc] initWithTitle:@"Push Not Enabled" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else {
        [self performSegueWithIdentifier:kPUDSegueMessagesToMessageDetail sender:self];
    }
}

#pragma mark - page content

- (NSString *)basicHtml {
    
    NSString *ret = @"<b >Sending a Message - Basic</b><hr>"
    "<ul>"
    "<li>Open the Preferences tab to add your name.</li><br/>"
    "<li>Wait 15 minutes to ensure your settings have been registered.</li><br/>"
    "<li>Tap the Send Message above to create a message and send it to this device.</li><br/>"
    "</ul>";
    
    return ret;
}

- (NSString *)tagHtml {
    
    NSString *ret = @"<b>Sending a Message - Tag Selected in Preferences</b><hr/>"
    "Tags allow you to target customers who have specified they want certain types of notifications but not others.  For example, an interest in one sports team, but not another.<br/>"
    "<br/>"
    "You can send a message by selecting the particular tag (or group) who should receive the message.<br/>"
    "<ul>"
    "<li>Open the Preferences tab to select tags for your favorite NFL or Football Club team.</li><br/>"
    "<li>Wait 15 minutes to ensure your settings have been registered.</li><br/>"
    "<li>Tap Send Message to send a message to this device and choose one of the tags you selected in Preferences.</li><br/>"
    "<li>Within a minute you should receive the message.</li><br/>"
    "</ul>";
    
    return ret;
}

- (NSString *)noTagHtml {
    
    NSString *ret = @"<b>Sending a Message - Tag Not Selected in Preferences</b><hr/>"
    "Tags allow you to target customers who have specified they want certain types of notifications but not others.  For example, an interest in one sports team, but not another.<br/>"
    "<br/>"
    "If you target a particular group, but the customer has not expressed interest in that group, they will not receive a message.<br/>"
    "<br/>"
    "You can test that here if you select certain teams in Preferences, but then send to a team you have not selected.  Then you will not receive a message.<br/>"
    "<ul>"
    "<li>Open the Preferences tab to select tags for your favorite NFL or Football Club team.</li><br/>"
    "<li>Wait 15 minutes to ensure your settings have been registered.</li><br/>"
    "<li>Tap Send Message to send a message to this device and choose one of the tags you have NOT selected in Preferences.</li><br/>"
    "<li>You will not receive a message since the message is intended only for those who have selected that tag.</li><br/>"
    "</ul>";
    
    return ret;
}

- (NSString *)openDirectHtml {
    
    NSString *ret = @"<b>Sending a Message - Specify OpenDirect URL</b><hr/>"
    "An OpenDirect URL allows you to specify a particular web page to view when a customer clicks on the notification received.<br/>"
    "<ul>"
    "<li>Verify that Push Notifications are enabled for this app.</li><br/>"
    "<li>Tap Send Message to send a message to this device and then enter an URL in the OpenDirect field.</li><br/>"
    "<li>Within a minute, you should receive a message.</li><br/>"
    "<li>When you click on the notification, the web page you entered when you sent the message will be opened.</li><br/>"
    "</ul>";
    
    return ret;
}

- (NSString *)customKeysHtml {
    
    NSString *ret = @"<b>Sending a Message - Custom Keys</b><hr/>"
    "Custom Keys allow you to direct the app to perform certain functions when the customer clicks on the notification.<br/>"
    "<br/>"
    "We have setup a discount code as the Custom Key for this app.<br/>"
    "<ul>"
    "<li>Verify that Push Notifications are enabled for this app.</li><br/>"
    "<li>Tap Send Message to send a message to this device and select one of the Custom Keys specified in the drop down list.</li><br/>"
    "<li>Within a minute, you should receive a message.</li><br/>"
    "<li>When you click on this message, special processing within the app based on the value of that custom key will be performed.</li><br/>"
    "</ul>";
    
    return ret;
}

- (NSString *)locationHtml {
    
    NSString *ret = @"<b>Sending a Message - Location</b><hr/>"
    "<ul>"
    "<li>Verify that Location Notifications are enabled for this app.</li><br/>"
    "<li>Visit any of the team stadiums listed in Preferences under the NFL or FC team tag sections.</li><br/>"
    "<li>Within a minute you should receive a message welcoming you to that stadium.</li><br/>"
    "</ul>";
    
    return ret;
}

@end
