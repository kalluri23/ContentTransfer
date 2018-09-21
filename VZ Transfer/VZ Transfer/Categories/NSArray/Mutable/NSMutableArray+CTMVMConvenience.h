//
//  NSMutableArray+CTMVMConvenience.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/31/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (CTMVMConvenience)


/*!
 To insert or add new object into NSMutableArray with simple validations.
 
 It will check object should not be nil or null, before inserting into array to avoid un-neccessary crashes while creating new arrays through out app.
 @param anObject Object want to be added into array.
 */
- (void)addObjectWithValidations:(id)anObject;


@end
