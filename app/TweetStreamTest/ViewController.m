//
//  ViewController.m
//  TweetStreamTest
//
//  Created by Noto Kaname on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@interface ViewController ()

@end

@implementation ViewController
{
    __weak IBOutlet UILabel *_responseLabel;
    __strong ACAccountStore* _accountStore;
    __strong NSString* _userID;
    __weak NSURLConnection* _connection;
    __strong NSMutableData* _dataTwitterStream;
}

- (void) getTwitterAccounts {
	// Create an account store object.
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	
	// Create an account type that ensures Twitter accounts are retrieved.
	ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	// Request access from the user to use their Twitter accounts.
	[accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
		if(granted) {
			// Get the list of Twitter accounts.
            __weak NSArray* accountsArray = [accountStore accountsWithAccountType:accountType];
            
            /*
            for (NSObject* account in accountsArray ) {
                NSLog(@"account=%@", account );
            }
            */
            
            _userID =  ((ACAccount*)[accountsArray objectAtIndex:0]).identifier;
            
            
		}else {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"認証が却下されました。" message:@"アプリの認証が却下されました設定画面から確認してください。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
        }
	}];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self getTwitterAccounts];
    
}

- (void)viewDidUnload
{
    _responseLabel = nil;
    [super viewDidUnload];
    [self getTwitterAccounts];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)firedStopStream:(id)sender {
 
    [_connection cancel];
}

- (IBAction)firedStream:(id)sender
{
	_accountStore = [[ACAccountStore alloc] init];
	ACAccount *twitterAccount = [_accountStore accountWithIdentifier:_userID ];
    
	// Prepare tweet message.
//	NSDate *now = [NSDate date];
//	NSString *tweetMessage = [NSString stringWithFormat:@"Hello!\n%@", [now description]];
    
	// Create a request, which in this example, posts a tweet to the user's timeline.
	// This example uses version 1 of the Twitter API.
	// This may need to be changed to whichever version is currently appropriate.
	TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://stream.twitter.com/1/statuses/filter.json"]
                                                 parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"#instagram",@"track"
                                                             ,nil]
                                              requestMethod:TWRequestMethodPOST];
	
	// Set the account used to post the tweet.
	[postRequest setAccount:twitterAccount];

    NSURLRequest* request = [postRequest signedURLRequest];
    
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - 
#pragma mark NSURLConnection delegate methods

/*
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    
}
*/

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if( error == nil ){

    }else{
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _dataTwitterStream = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
//    [_dataTwitterStream appendData:data];
    
    char* utf8String = malloc([data length]+1);
    [data getBytes:utf8String length:[data length] ];
    utf8String[[data length]] = '\0';
    NSString* resultString = [NSString stringWithUTF8String:utf8String];
    NSLog(@"resultString=%@",resultString);
    free(utf8String);
    
    
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
{
    _dataTwitterStream = nil;
    /*
    NSError* error = nil;
    NSObject* obj = [NSJSONSerialization JSONObjectWithData:_dataTwitterStream options:0 error:&error];
    
    if( error == nil ){
        NSLog(@"obj=%@", obj );
        
    }
    */
}





@end
