#import <UIKit/UIKit.h>

#define LastLoginUsernameKey @"LastLoginUsername"
#define LastLoginPasswordKey @"LastLoginPassword"

@interface User
+ (void)performLoginWithUsernameOrEmail:(NSString *)username password:(NSString *)password;
@end

@interface LoginViewController
- (UITextField *)passwordTextField;
@end

%hook LoginRegisterViewController
- (void)viewDidAppear:(BOOL)animated
{
	// run the original code
	%orig;

	// get the user defaults
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];

	// get saved username and password
	NSString *username = [standardUserDefaults objectForKey:LastLoginUsernameKey];
	NSString *password = [standardUserDefaults objectForKey:LastLoginPasswordKey];

	// if they are both there, go for it
	if (username.length > 0 && password.length > 0)
		[%c(User) performLoginWithUsernameOrEmail:username password:password];
}
%end

%hook Manager
- (void)logout
{
	// remove the saved password
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	[standardUserDefaults removeObjectForKey:LastLoginPasswordKey];

	// run the original code
	%orig;
}
%end

%hook LoginViewController
- (void)loginDidSucceed:(id)sender
{
	// get the password
	NSString *password = [self passwordTextField].text;

	// save it to disk
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	[standardUserDefaults setObject:password forKey:LastLoginPasswordKey];

	// run the original code
	%orig;
}
%end

%hook User
%end