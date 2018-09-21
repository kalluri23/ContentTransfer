//
//  PhotoStoreOperationQueue.h
//  storePhotosTest
//
//  Created by Sun, Xin on 6/14/16.
//  Copyright © 2016 Sun, Xin. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 Operation queue for importing photos and videos into system photo app. Init the operation queue with dataset want to import, and call add operation method.
 
 Datasets is a dictionary of photo/video information. It can be multiple items or only one item.
 
 Multiple operation queue can work together for importing.
 */
@interface PhotoStoreOperationQueue : NSOperationQueue
/*!
 Initializer for opertaion queue.
 @param dataSet Array of dictionary contains the information of images, including image size, name, path and albums.
 @return PhotoStoreOperationQueue object.
 */
- (instancetype)initWithDataSet:(NSArray *)dataSet;
/*!
 Add the operation into the queue. This method will read dataset one by one to create NSInvocationOperation for them and push them into queue.
 
 After calling this method, operation will be executed automatically without any further method call.
 @param target Object want to handle the response.
 @param selector Selector method contains the logic working after the response.
 */
- (void)addOperationWithTarget:(id)target selector:(SEL)selector;

@end
