//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by David Koch on 17.12.22.
//

import Foundation
import UIKit

class FlickrClient{
    
    struct Api {
        static let key: String = "ef4815afb060398a9045c15cc78c1b53"
        static let secret: String = "f8f7ee2306368b91"
    }
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services"
        static let imageUrlBase = "https://live.staticflickr.com"
        

        case searchWithCoordinates(Double, Double, Int)
        case imageUrl(serverId: String, id: String, secret: String)
        var stringValue: String{
            switch self{
            case .searchWithCoordinates(let lat, let long, let page): return Endpoints.base + "/rest/?method=flickr.photos.search&api_key=\(Api.key)&lat=\(lat)&lon=\(long)&per_page=20&page=\(page)&format=json&nojsoncallback=1"
            case .imageUrl(let serverId, let id, let secret): return Endpoints.imageUrlBase + "/\(serverId)/\(id)_\(secret).jpg"
            }
                
        }
        
        var url: URL{
            return URL(string: stringValue)!
        }
    }
    
    class func getImageUrl(serverId: String, id: String, secret: String, completion: @escaping (UIImage?, Error?) -> Void?) {
        let request = URLRequest(url: Endpoints.imageUrl(serverId: serverId, id: id, secret: secret).url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            do {
                //let imageData = try JSONDecoder().decode(UIImage.self, from: data)
                let imageData = UIImage(data: data)
                DispatchQueue.main.async {
                    
                    completion(imageData, nil)
                    
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
        }
        task.resume()
    }
    
    class func getImageCollectionRequest(latitute: Double, longitude: Double, page: Int, completion: @escaping ([SearchRequest.PhotoDetails], Error?) -> Void?) {
        let request = URLRequest(url: Endpoints.searchWithCoordinates(latitute, longitude, page).url)
    
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion([], error)
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion([], error)
                }
                return
            }
            do {
                let imageData = try JSONDecoder().decode(SearchRequest.self, from: data)
                print(imageData)
                DispatchQueue.main.async {
                    completion(imageData.photos.photo, nil)
                    
                }
            } catch {
                DispatchQueue.main.async {
                    completion([], error)
                }
                return
            }
        }
        task.resume()
    }
}
