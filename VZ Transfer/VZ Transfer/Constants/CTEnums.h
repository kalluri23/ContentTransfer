//
//  CTEnums.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 9/12/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#ifndef CTEnums_h
#define CTEnums_h

/*! Enum for cancel mode.*/
typedef NS_ENUM(NSInteger, CTTransferCancelMode) {
    /*! Back button clicked.*/
    CTTransferCancelMode_Back,
    /*! Hamburger menu clicked (MVM only).*/
    CTTransferCancelMode_Hamburger,
    /*! Search button clicked. (MVM only)*/
    CTTransferCancelMode_Search,
    /*! Cancel button clicked.*/
    CTTransferCancelMode_Cancel,
    /*! User force to quit the app.*/
    CTTransferCancelMode_UserForceExit
};

/*! iTunes review status enumeration.*/
typedef NS_ENUM(NSInteger, CTItunesReviewStatus) {
    /*! Users have not yet give their review on store.*/
    CTItunesReviewStatus_NotYet,
    /*! User reviewed the app already.*/
    CTItunesReviewStatus_Reviewed,
    /*! User choose to never show review dialog again.*/
    CTItunesReviewStatus_Never
};

/*! Enum type for data type order in table view list.*/
typedef NS_ENUM(NSInteger, CTTransferItemsTableBreakDown) {
    /*! Index 0 in table view.*/
    CTTransferItemsTableBreakDown_Contacts = 0,
    /*! Index 1 in table view.*/
    CTTransferItemsTableBreakDown_Photos,
    /*! Index 2 in table view.*/
    CTTransferItemsTableBreakDown_Videos,
    /*! Index 3 in table view.*/
    CTTransferItemsTableBreakDown_Calenders,
    /*! Index 4 in table view.*/
    CTTransferItemsTableBreakDown_RemindersOrAudios,
    /*! Total index avaiable in table view.*/
    CTTransferItemsTableBreakDown_Total
};
#endif

