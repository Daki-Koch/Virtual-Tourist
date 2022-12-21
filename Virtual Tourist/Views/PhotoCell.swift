//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by David Koch on 18.12.22.
//

import Foundation
import UIKit

class PhotoCell: UICollectionViewCell{
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
//    func setCell(photo: Photo){
//        
//        if let image = photo.image {
//            DispatchQueue.main.async {
//                self.imageView.image = UIImage(data: image)
//            }
//            
//        } else {
//            
//            downloadImage(photo: photo)
//            
//        }
//        
//    }
//    
//    func downloadImage(photo: Photo){
//        
//        if let urlString = photo.imageUrl{
//            FlickrClient.getImageUrl(urlString: urlString) { photoData, error in
//                if let error = error{
//                    print(error.localizedDescription)
//                    return
//                }
//                guard let data = photoData else{
//                    print("No data could be found.")
//                    return
//                }
//                
//                DispatchQueue.main.async {
//                    self.imageView.image = UIImage(data: data)
//                    self.saveImageToCoreData(photo: photo, photoData: data)
//                }
//            }
//        }
//        
//    }
//    
//    func saveImageToCoreData(photo: Photo, photoData: Data){
//        
//        do{
//            photo.image = photoData
//            try dataController.shared.viewContext.save()
//        } catch {
//            print(error.localizedDescription)
//        }
//        
//    }
}
