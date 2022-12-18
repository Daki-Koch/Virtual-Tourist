//
//  SearchRequest.swift
//  Virtual Tourist
//
//  Created by David Koch on 18.12.22.
//

import Foundation

struct SearchRequest: Codable{
    let photos: PhotosDetails
    
    
    struct PhotosDetails: Codable{
        let page: Int
        let pages: Int
        let perpage: Int
        let total: Int
        let photo: [PhotoDetails]
        let stat: String
    }
    
    struct PhotoDetails: Codable{
        let id: String
        let owner: String
        let secret: String
        let server: String
        let farm: Int
        let title: String
        let ispublic: Int
        let isfriend: Int
        let isfamily: Int
    }
}

