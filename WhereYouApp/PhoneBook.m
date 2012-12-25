//
//  PhoneBook.m
//  WhereYouApp
//
//  Created by Gabriel Ortega on 3/21/12.
//

#import "PhoneBook.h"

@implementation PhoneBook
@synthesize contacts, addressBook, contactNamesArray, contactPhoneNumbersArray;


- (id)init
{
    
    addressBook = ABAddressBookCreate();
    ABRecordRef source = nil;
    contacts = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, ABPersonGetSortOrdering());
    contactNamesArray = [NSMutableArray new];
    contactPhoneNumbersArray = [NSMutableArray new];
    NSLog(@"%ld", CFArrayGetCount(contacts));
    
    
    // This iterates through the users address book
    for (CFIndex i=0; i<CFArrayGetCount(contacts); i++)
    {
        // This will give us strings for the contacts name
        CFStringRef firstName = ABRecordCopyValue(CFArrayGetValueAtIndex(contacts, i), kABPersonFirstNameProperty);
        CFStringRef lastName = ABRecordCopyValue(CFArrayGetValueAtIndex(contacts, i), kABPersonLastNameProperty);
        
        ABMultiValueRef phones = ABRecordCopyValue(CFArrayGetValueAtIndex(contacts, i), kABPersonPhoneProperty);
        NSString *mobile;
        NSString *mobileLabel;
        
        // This will iterate through all the numbers stored in phones.  
        // If the label of one of those numbers matches the mobile label we add
        //   the name and number of the contact to its respective array.
        for (CFIndex j=0; j<ABMultiValueGetCount(phones);j++)
        {
            mobileLabel = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phones, j);
            
            if ([mobileLabel isEqualToString:@"_$!<Mobile>!$_"])
            {
                mobile = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phones, j);
                [contactPhoneNumbersArray addObject:mobile];
                
                NSString *fullContactName = [NSString stringWithFormat:@"%@ %@", (__bridge NSString *)firstName, (__bridge NSString *)lastName];
                [fullContactName stringByReplacingOccurrencesOfString:@"\0" withString:@""]; // remove "(NULL)" 
                [contactNamesArray addObject:fullContactName];
            }
        } // ends phone for loop
    } // ends loop for address book
    NSLog(@"Name Array count: %u", [contactNamesArray count]);
    NSLog(@"Phone Array count: %u", [contactPhoneNumbersArray count]);
    return self;
}

- (int)count
{
    return [contactNamesArray count];
}

- (NSString *)getContactNameAtIndex:(int)index
{
    return [contactNamesArray objectAtIndex:index];
}

- (NSString *)getContactPhoneNumberAtIndex:(int)index
{
    return [contactPhoneNumbersArray objectAtIndex:index];
}
@end
