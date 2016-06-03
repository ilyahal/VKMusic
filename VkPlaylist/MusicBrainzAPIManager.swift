//
//  MusicBrainzAPIManager.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 03.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation
import Alamofire
import SWXMLHash
import SwiftyJSON
import AlamofireImage

/// Класс выполняет поиск обложки для аудиозаписи с указанным названием и исполнителем
class MusicBrainzAPIManager {
    
    /// Инициализация с названием и исполнителем аудиозаписи, для которой нужно получить обложку
    init(title: String, artist: String) {
        track = (title: title, artist: artist)
    }
    
    /// Аудиозапись для которой выполняется поиск обложки
    private let track: (title: String, artist: String)
    
    /// Отменено ли выполнение получения обложки
    private var isCanceled = false
    
    /// Массив запросов на получение URL обложки альбома
    private var requestGetArtworkURLArray = [Request]()
    /// Массив запросов на получение обложки альбома
    private var requestGetArtworkArray = [Request]()
    /// Была ли получена обложка альбома
    private var isGetted = false
    
    /// Обложка альбома была получена
    private func didGetArtwork(artwork: Image, withCompletionHandler completion: (Image) -> Void) {
        if !isCanceled {
            if artwork.size.height != artwork.size.width {
                return
            }
            
            isGetted = true
            
            for request in requestGetArtworkURLArray {
                request.cancel()
            }
            requestGetArtworkURLArray.removeAll()
            
            for request in requestGetArtworkArray {
                request.cancel()
            }
            requestGetArtworkArray.removeAll()
            
            completion(artwork)
        }
    }
    
    
    /// Отменить получение обложки альбома
    func cancel() {
        isCanceled = true
        
        for request in requestGetArtworkURLArray {
            request.cancel()
        }
        requestGetArtworkURLArray.removeAll()
        
        for request in requestGetArtworkArray {
            request.cancel()
        }
        requestGetArtworkArray.removeAll()
    }
    
    
    /// Получить обложку альбома
    func getArtwork(completion: (Image) -> Void) {
        isCanceled = false
        
        Alamofire.request(.GET, urlForTrack()).response { request, response, data, error in
            let xml = SWXMLHash.parse(data!)
            
            if let releaseList = self.getReleaseListInXMLData(xml) {
                let MBIDArray = self.getMBIDArrayForReleaseList(releaseList)
                
                if !MBIDArray.isEmpty {
                    for MBID in MBIDArray {
                        self.requestGetArtworkURLArray.append(Alamofire.request(.GET, self.urlForMBID(MBID)).responseJSON { response in
                            if let JSON = response.result.value {
                                if let artworkURL = self.urlArtworkForJSON(JSON) {
                                    if !self.isGetted && !self.isCanceled {
                                        self.requestGetArtworkArray.append(Alamofire.request(.GET, artworkURL).responseImage { response in
                                            if let image = response.result.value {
                                                self.didGetArtwork(image, withCompletionHandler: completion)
                                            }
                                        })
                                    }
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    /// URL запрос для указанной аудиозаписи
    private func urlForTrack() -> NSURL {
        
        // http://musicbrainz.org/ws/2/recording?query=#_TRACK_TITLE_#%20ANDartist:#_ARTIST_NAME_#
        
        let request = track.title + " ANDartist:" + track.artist
        let clearRequest = request.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! // Заменяем все недопустимые символы в поисковом запросе
        
        let urlString = String(format: "http://musicbrainz.org/ws/2/recording?query=%@", clearRequest)
        let url = NSURL(string: urlString)
        
        return url!
    }
    
    /// Попытка получить список релизов для указанного URL
    private func getReleaseListInXMLData(xml: XMLIndexer) -> XMLIndexer? {
        for recording in xml["metadata"]["recording-list"]["recording"] {
            
            // Получаем имя исполнителя
            let XMLartistName = recording["artist-credit"]["name-credit"]["artist"]["name"].element?.text
            
            if let XMLartistName = XMLartistName {
                if XMLartistName.lowercaseString == track.artist.lowercaseString {
                    return recording["release-list"]["release"]
                }
            }
        }
        
        return nil
    }
    
    /// Получение массива MBIDов для указанного списка релизов
    private func getMBIDArrayForReleaseList(releaseList: XMLIndexer) -> [String] {
        var MBIDArray = [String]()
        
        for release in releaseList {
            if let XMLreleaseMBID = release.element?.attributes["id"] {
                MBIDArray.append(XMLreleaseMBID)
            }
        }
        
        return MBIDArray
    }
    
    /// Получение URL для указанного MBID
    private func urlForMBID(MBID: String) -> NSURL {
        
        // http://coverartarchive.org/release/#_MBID_#/
        
        let urlString = String(format: "http://coverartarchive.org/release/%@/", MBID)
        let url = NSURL(string: urlString)
        
        return url!
    }
    
    /// Получение ссылки на обложку альбома
    private func urlArtworkForJSON(clearJSON: AnyObject) -> NSURL? {
        let json = JSON(clearJSON)
        
        if let images = json["images"].array {
            for image in images {
                var isFront = false // Лицевая ли часть
                
                if let types = image["types"].array {
                    if types.isEmpty {
                        isFront = true
                    } else {
                        for type in types {
                            if let _type = type.string {
                                if _type == "Front" {
                                    isFront = true
                                    break
                                }
                            }
                        }
                    }
                }
                
                if isFront {
                    if let thumbnails = image["thumbnails"].array {
                        for thumbnail in thumbnails {
                            if let large = thumbnail["large"].string {
                                return NSURL(string: large)
                            } else if let small = thumbnail["small"].string {
                                return NSURL(string: small)
                            }
                        }
                    }
                    
                    if let _image = image["image"].string {
                        return NSURL(string: _image)
                    }
                }
            }
        }
        
        return nil
    }
    
}