### Easy to use Objective-C libaray for working with open directory;

It's written to use either blocks or delegation based on your needs. 

####Connect to a OD Server
```objective-c
ODManger *manager = [ODManager new];
manager.nodeStatusUpdateHandler = ^(OSStatus status){
    NSLog(@"Status Change:[%d] %@",status, nodeStatusDescription(status));
};
manager.diradmin = @"diradmin";
manager.diradminPassword=@"testpassword";

manager.directoryServer=@"127.0.0.1";
[manager authenticate];
```

####Create a user
```objective-c
ODUser* user = [ODUser new];
user.userName = @"holcom";
user.firstName = @"heldon";
user.lastName = @"comelor";
user.emailDomain = @"mysite.com";
user.primaryGroup = @"20";
user.passWord = @"dummypassword";
```
####Add a user to server
```objective-c
[_manager addUser:user error:&error];
```

####Add a list of users to a server
```objective-c
ODRecordList* list = [ODRecordList new];

// user1,user2, and user3 are all populated ODUser objects
list.users = @[user1,user2,user3];

[_manager addListOfUsers:list progress:^(NSString *message, double progress) {
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
 	   // this block gets called after each user is added. 
	   // Use it to update your User Inteface
	}];
} reply:^(NSError *error) {
    // this block gets called on completion
}];
```
#### add a user to a group
```objective-c
// jdoe is the user's record name and wkgroup is the group record name

[_manager addUser:@"jdoe" toGroup:@"wkgroup" error:&error]

```

these methods all have the reverse of "remove"
see the ODManager header for a full list of avaliable commands