//
//  PhoneBook.h
//  WhereYouApp
//
//  Created by Gabriel Ortega on 3/21/12.
//
//  This is a class used to store only contacts that have a mobile phone number
//  It is not currently being used by the main controller

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

@interface PhoneBook : NSObject

@property (nonatomic) CFArrayRef contacts;
@property (nonatomic) ABAddressBookRef addressBook;
@property (nonatomic, strong) NSMutableArray *contactNamesArray;
@property (nonatomic, strong) NSMutableArray *contactPhoneNumbersArray;

- (id)init;
- (int)count;
- (NSString *)getContactNameAtIndex:(int)index;
- (NSString *)getContactPhoneNumberAtIndex:(int)index;

@end
