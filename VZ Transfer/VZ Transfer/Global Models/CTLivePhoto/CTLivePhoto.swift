//
//  CTLivePhoto.swift
//  contenttransfer
//
//  Created by Sun, Xin on 12/21/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import Photos

/**
 Instance object for live photo. This object contains all the properties using for live photo.
 
 Live photo is a mixed media that combine a static image with a short .MOV video file as resource.
 
 When transfer live photo, transfer will both transfer image and video part and then when importing, combine them together as live photo.
 - note: This object is available on iOS version 9.1 and above.
 */
@available(iOS 9.1, *)
public class CTLivePhoto: NSObject {
    // MARK: - Private properties
    private var asset: PHAsset!
    private var resources: [PHAssetResource]!
    
    // MARK: - Public properties
    /**
     Identifier for live photo object. **Read only**
     
     This property will return localIdentifier of PHAsset object assoicated with this object.
     */
    @objc public var identifier: String {
        get {
            return self.asset.localIdentifier
        }
    }
    /** Name of file for live photo. Name will be the name of image resource.*/
    @objc public var name: String? = nil
    /** Name of video file for live photo.*/
    @objc public var videoName: String? = nil
    /** Encrypted file name using base64. This is required for cross platform.*/
    @objc public var encryptName: String? = nil
    /** Size of the file. This is total size, including photo and video resources.*/
    @objc public var size: Int64 = 0
    /** Size of the image file.*/
    @objc public var pureImageSize: Int64 = 0
    /** Size of the video file.*/
    @objc public var videoConponentSize: Int64 {
        get {
            return self.size - self.pureImageSize
        }
    }
    /**
     Information dictionary of live photo. This list will be used to create photo file list.
     
     List should be like below:
     ````
     {
        'Path' = image name using to identify the image during the transfer.
        'Size' = size of the file need to be sent/received.
        'Album' = Array of album names this image belongs to. This is optional, if no customer album, can be empty.
        'creationDate' = This is date of creation in image's metadata.
        'isFavorite' = Indicate that user select favourite for this image in their Photo app.
        'isLivePhoto' = true. This is mandentory for live photo, and value should always be true.
     }
     ````
     */
    @objc public var info: [String : Any]? = nil
    /** Get creation date of live photo. **Readonly** property.*/
    @objc public var creationDate: Date? {
        get {
            return self.asset.creationDate
        }
    }
    
    // MARK: - Initializer
    /**
     Initializer for live photo object.
     
     This method will calulate the size and encrypt the name for live photo.
     - parameters:
        - asset: PHAsset object associated with live photo.
     */
    @objc public init(with asset: PHAsset) {
        super.init()
        
        self.asset = asset
        self.resources = PHAssetResource.assetResources(for: self.asset)
        
        let fileName = self.asset.localIdentifier;
        // Get the name & size
        var pathExtension: String? = nil;
        for resource in self.resources {
            if resource.type == .photo {
                pathExtension = (resource.originalFilename as NSString).pathExtension
                if resource.hasKey("fileSize") {
                    self.pureImageSize = resource.value(forKey: "fileSize") as! Int64
                    self.size += resource.value(forKey: "fileSize") as! Int64
                }
            } else if resource.type == .pairedVideo {
                if resource.hasKey("fileSize") {
                    self.videoName = resource.originalFilename // video name
                    self.size += resource.value(forKey: "fileSize") as! Int64
                }
            }
        }
        
        guard fileName.count > 0, pathExtension != nil, pathExtension!.count > 0 else {
            print("No valid name for live photo object.")
            return
        }
        self.name = String.init(format: "%@.%@", fileName, pathExtension!)
        
        // Encrpt the name
        guard self.name != nil else {
            print("No valid name for live photo object.")
            return
        }
        self.encryptName = self.name!.encodeTo64()
    }
    
    // MARK: - Instance methods
    /**
     Check if live photo object is a valid one or not.
     
     When it's valid live photo that can be transfer, file name and size should exist and resource should exist and greater than 1. (One for photo, one for video)
     - returns: Bool value indicate the result.
     */
    @objc public func isValidLivePhoto() -> Bool {
        return self.name != nil && self.size > 0 && self.pureImageSize > 0 && self.resources.count > 1
    }
    /**
     Generate the information dictionary for current live photo object. List will be stored in info property of object.
     - seeAlso: info
     */
    @objc public func generateDict() {
        // FIXME: Need to support all the effect for live photos.
        if (self.info == nil) {
            self.info = [String: Any]()
            // Path
            self.info!["Path"] = self.encryptName
            // Resource
            self.info!["Resource"] = self.videoName
            // Size
            self.info!["Size"] = String.init(format: "%d", self.size)
            // Add creation date
            if self.asset.creationDate != nil {
                let createDateStr = NSDate.string(from: self.asset.creationDate!)
                if createDateStr != nil && createDateStr!.count > 0 {
                    self.info!["creationDate"] = createDateStr!
                }
            }
            // Add is fovorite
            if (asset.isFavorite) {
                self.info!["isFavorite"] = self.asset.isFavorite
            }
            // Flag for live photo
            self.info!["isLivePhoto"] = true
        }
    }
    /**
     Update the dictionary with existing one.
     
     This method will turn a normal static image dictionary into live photo dictionary using current live photo properties.
     
     New dictionary will be stored in info property.
     - parameters:
        - dict: Original dictionary for static photo.
     */
    @objc public func updateDict(for dict: [String: Any]) {
        self.info = dict
        guard self.info != nil else {
            fatalError("Info dictionary must exist here. Check code.")
        }
        // Path
        self.info!["Path"] = self.encryptName
        // Resource
        self.info!["Resource"] = self.videoName
        // Update size to include video resource
        self.info!["Size"] = String.init(format: "%d", self.size)
        // Flag for live photo
        self.info!["isLivePhoto"] = true
    }
    /**
     Get data of image resource for live photo.
     - note: Process of request resource data is asychronized. So this method is also async, result will be return from completion block.
     - parameters:
        - completion: Completion block to return the result of data fetch.
        - data: Data for image resource. If error happened during request, nil will be returned.
     */
    @objc public func getImageData(completion: @escaping (_ data: Data?)->(Swift.Void)) {
        let photoResource = self.getImageResource()
        if photoResource != nil {
            var imageData = Data()
            PHAssetResourceManager.default().requestData(for: photoResource!, options: nil, dataReceivedHandler: { (receivedData) in
                imageData.append(receivedData)
            }, completionHandler: { (error) in
                if error != nil {
                    print("Error when reading image data from resource: \(error!.localizedDescription)")
                    completion(nil)
                } else {
                    print("Image data for live photo: \(imageData.count)")
                    completion(imageData)
                }
            })
        } else {
            print("Should be discarded.")
            completion(nil)
        }
    }
    /**
     Get data of video resource for live photo.
     - note: Process of request resource data is asychronized. So this method is also async, result will be return from completion block.
     - parameters:
        - completion: Completion block to return the result of data fetch.
        - data: Data for image resource. If error happened during request, nil will be returned.
     */
    @objc public func getVideoData(completion: @escaping (_ data: Data?)->(Swift.Void)) {
        let videoResource = self.getVideoResource()
        if videoResource != nil {
            var videoData = Data()
            PHAssetResourceManager.default().requestData(for: videoResource!, options: nil, dataReceivedHandler: { (receivedData) in
                videoData.append(receivedData)
            }, completionHandler: { (error) in
                if error != nil {
                    print("Error when reading video data from resource: \(error!.localizedDescription)")
                    completion(nil)
                } else {
                    print("Video data for live photo: \(videoData.count)")
                    completion(videoData)
                }
            })
        } else {
            print("Should be discarded.")
            completion(nil)
        }
    }
    /**
     Update the file size from static image to live photo.
     
     This image will fetch the video resource and add the size to the original image resource.
     - parameter newImageSize: New size of image needs to be updated.
     */
    @objc public func updateFileSize(newImageSize: Int64) {
        let photoResource = self.getImageResource()
        if photoResource != nil {
            let originalImageSize: Int64 = photoResource!.value(forKey: "fileSize") as! Int64
            if originalImageSize != newImageSize { // If image has different size after inserted creation date metadata
                self.size += newImageSize - originalImageSize
                self.info!["Size"] = String.init(format: "%d", self.size)
            }
        } else {
            print("Should keep the old file size.")
        }
    }
    /**
     Get resource of image for live photo.
     - returns: PHAssetResource for image. Nil if nothing found.
     */
    @objc public func getImageResource() -> PHAssetResource? {
        return self.getResource(.photo)
    }
    /**
     Get resource of video for live photo.
     - returns: PHAssetResource for video. Nil if nothing found.
     */
    @objc public func getVideoResource() -> PHAssetResource? {
        return self.getResource(.pairedVideo)
    }
    
    // MARK: - Class methods
    /**
     Check if current info dic represents a live photo object or not.
     - parameter info: Info dic for photo object.
     - returns: Bool value indicate the result.
     */
    @objc public static func isCurrentImageLivePhoto(_ info: [String: Any]) -> Bool {
        return info["isLivePhoto"] != nil && info["isLivePhoto"] as! Bool
    }
    
    // MARK: - Convenients
    private func getResource(_ type: PHAssetResourceType) -> PHAssetResource? {
        let filteredResources = self.resources.filter { (resource) -> Bool in
            return resource.type == type
        }
        
        if filteredResources.count >= 1 {
            return filteredResources[0] // Should always be 1 item in array
        } else {
            print("> No resource found for live photo: \(type)")
            return nil
        }
    }
    
}
