//
//  TableViewCellIdentifiers.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

/// Идентификаторы ячеек
struct TableViewCellIdentifiers {
    
    /// Ячейка с сообщением об отсутствии авторизации
    static let noAuthorizedCell = "NoAuthorizedCell"
    /// Ячейка с сообщением об ошибке при подключении к интернету
    static let networkErrorCell = "NetworkErrorCell"
    /// Ячейка с сообщением об ошибке доступа
    static let accessErrorCell = "AccessErrorCell"
    /// Ячейка с сообщением "Ничего не найдено"
    static let nothingFoundCell = "NothingFoundCell"
    /// Ячейка с сообщением о загрузке данных
    static let loadingCell = "LoadingCell"
    /// Ячейка для вывода аудиозаписи
    static let audioCell = "AudioCell"
    /// Ячейка для вывода загружаемой аудиозаписи
    static let activeDownloadCell = "ActiveDownloadCell"
    /// Ячейка для вывода оффлайн аудиозаписи
    static let offlineAudioCell = "OfflineAudioCell"
    /// Ячейка для добавления плейлиста
    static let addPlaylistCell = "AddPlaylistCell"
    /// Ячейка для вывода плейлиста
    static let playlistCell = "PlaylistCell"
    /// Ячейка для перехода к добавлению аудиозаписей в плейлист
    static let addAudioCell = "AddAudioCell"
    /// Ячейка для вывода аудиозаписи добавляемой в плейлист
    static let addToPlaylistCell = "AddToPlaylistCell"
    /// Ячейка для добавления альбома
    static let addAlbumCell = "AddAlbumCell"
    /// Ячейка для вывода альбома
    static let albumCell = "AlbumCell"
    /// Ячейка для вывода ссылки на другой экран
    static let moreCell = "MoreCell"
    /// Ячейка для вывода друга
    static let friendCell = "FriendCell"
    /// Ячейка для вывода группы
    static let groupCell = "GroupCell"
    /// Ячейка для вывода количества строк в таблице
    static let numberOfRowsCell = "NumberOfRowsCell"
    
}