//
//  CTBannerOverlay.swift
//  contenttransfer
//
//  Created by Sun, Xin on 8/14/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit

/** Protocol for banner overlay delegate.*/
@objc public protocol CTBannerOverlayDelegate {
    /** This method will be called when user clicked banner image.*/
    @objc optional func bannerDidClicked(_ sender: UIButton)
}

/**
 Overlay class for finish view to show banner images. Position will be defined in a xib file shared the same name of this class.
 
 To use this overlay, first use loadBannerView() to get overlay instance and call attachOverlay() to add overlay to the parent view, then setup the which banner image want to show using proper banner number, then called assignBanner().
 
 If banner is clickable, just simply implements the CTBannerOverlayDelegate on parent view controller.
 */
public class CTBannerOverlay: UIView {
    
    // MARK: - Static parameters & structs
    /**
     Banner images for cloud app.
     - Note: Images are pre-installed in app bundle, not download through Internet.
     */
    struct CTBanners {
        /** Banner image.*/
        static let banner: UIImage = UIImage.getImageFromBundle(withImageName: "Banner")
    }

    // MARK: - Properties
    /** Image view to contain the banner image.*/
    @IBOutlet weak var bannerImageView: UIImageView!
    /** Sub-title label for overlay*/
    @IBOutlet weak var subTitleLbl: CTRomanFontLabel!
    /** Constaints for container view height.*/
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    /**
     Banner image to show, available number is -1,1,2,3,4, rest of the number will not take, and banner 1 will be showed as default.
     - Important: After banner number value assigned, assginBanner() method has to be called, otherwise no banner image will be assigned to image view.
     */
    @objc public var showBannerNumber: Int = 1
    /** Delegate for banner overlay.*/
    @objc public var delegate: CTBannerOverlayDelegate? = nil
    
    // MARK: - Initializer
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        if (CTDeviceMarco.isiPhone6AndAbove()) {
            // iPhone 6 & 6s screen size, use equal width & height for the banner.
            self.imageViewHeight.constant = self.bannerImageView.frame.size.width
        } else if (CTDeviceMarco.isiPhone5Serial()) {
            self.imageViewHeight.constant -= 100.0
            // Adapt image scale
            self.bannerImageView.contentMode = .scaleAspectFill
        } else if (CTDeviceMarco.isiPhone4AndBelow()) {
            self.imageViewHeight.constant -= 230.0
            // Adapt image scale
            self.bannerImageView.contentMode = .scaleAspectFill
        }
    }
    /**
     Load the banner view from nib file. This method will call loadNibNamed() method to load CTCloudBannerOverlay, and object instance will be return.
     - returns: CTCloudBannerOverlay object.
     */
    @objc static public func loadBannerView() -> CTBannerOverlay? {
        guard let bannerOverlay = VZViewUtility.bundleForFramework().loadNibNamed(String(describing: CTBannerOverlay.self), owner: nil)?.last as? CTBannerOverlay
            else {
            return nil
        }
        
        return bannerOverlay
    }
    
    // MARK: - Public methods
    /**
     Assign the specified banner image to image view. Default value will be banner #1. If given number is not valid or not given, banner 1 will be assigned to image view. -1 means random pick on image.
     */
    @objc public func assignBanner() {
        if (CTDeviceMarco.isiPhone4AndBelow()) {
            // Banner will always show #2 when screen size is 2.
            showBannerNumber = 1
        }
        switch showBannerNumber {
        case 1:
            self.bannerImageView.image = CTBanners.banner
            break;
        default:
            self.bannerImageView.image = CTBanners.banner
            break
        }
    }
    /**
     Attached the overlay to specific view with position given.
     - parameters:
        - view: Parent view to contain the overlay.
        - topView: Top position related to view on the top.
        - top: Top padding in pixels.
        - bottomView: Bottom position related to view on the bottom.
        - bottom: Bottom padding in pixels.
        - leftView: Leading position related to view on the left.
        - left: Leading in pixels.
        - rightView: Trailing position related to view on the right.
        - right: Trailing in pixels.
     */
    @objc public func attachOverlay(_ view: UIView, topTo topView: UIView, withSize top: CGFloat, bottomTo bottomView: UIView, withSize bottom: CGFloat, leftTo leftView: UIView, withSize left: CGFloat, rightTo rightView: UIView, withSize right: CGFloat) {
        // Attached overlay as subview.
        view.addSubview(self)
        
        // Setup constaints
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Top
        let topConstains = NSLayoutConstraint.init(item: self, attribute: .top, relatedBy: .equal, toItem: topView, attribute: .bottom, multiplier: 1.0, constant: top)
        // Bottom
        let bottomConstains = NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: bottomView, attribute: .top, multiplier: 1.0, constant: bottom)
        // Leading
        let leadingConstains = NSLayoutConstraint.init(item: self, attribute: .leading, relatedBy: .equal, toItem: leftView, attribute: .leading, multiplier: 1.0, constant: left)
        // Trailing
        let trailingConstains = NSLayoutConstraint.init(item: self, attribute: .trailing, relatedBy: .equal, toItem: rightView, attribute: .trailing, multiplier: 1.0, constant: right)
        
        view.addConstraints([topConstains, bottomConstains, leadingConstains, trailingConstains])
    }
    
    // MARK: - Actions
    @IBAction func bannerClicked(_ sender: UIButton) {
        if (self.delegate != nil) {
            self.delegate!.bannerDidClicked?(sender)
        }
    }

}
