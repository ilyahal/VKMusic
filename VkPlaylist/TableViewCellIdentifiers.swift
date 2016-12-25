//
//  TableViewCellIdentifiers.swift
//  VkPlaylist
//
//  MIT License
//
//  Copyright (c) 2016 Ilya Khalyapin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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