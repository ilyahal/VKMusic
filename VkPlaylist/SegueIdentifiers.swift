//
//  SegueIdentifiers.swift
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

/// Идентификаторы Segue
struct SegueIdentifiers {
    
    /// миниплеер -> полноэкранный плеер
    static let showPlayerSegue = "ShowPlaylistAudioSegue"
    /// Вкладка "Моя музыка" -> контейнер с музыкой
    static let showMyMusicTableViewControllerInContainerSegue = "ShowMyMusicTableViewControllerInContainerSegue"
    /// Вкладка "Загрузки" -> контейнер с загрузками
    static let showDownloadsTableViewControllerInContainerSegue = "ShowDownloadsTableViewControllerInContainerSegue"
    /// Вкладка "Поиск" -> контейнер с музыкой
    static let showSearchTableViewControllerInContainerSegue = "ShowSearchTableViewControllerInContainerSegue"
    /// Вкладка "Плейлисты" -> "Добавлением нового плейлиста"
    static let showEditPlaylistViewControllerForAddSegue = "ShowEditPlaylistViewControllerForAddSegue"
    /// Вкладка "Плейлисты" -> "Aудиозаписи плейлиста"
    static let showPlaylistAudioSegue = "ShowPlaylistAudioSegue"
    /// "Aудиозаписи плейлиста" -> контейнер с музыкой
    static let showPlaylistMusicTableViewControllerInContainerSegue = "ShowPlaylistMusicTableViewControllerInContainerSegue"
    /// "Aудиозаписи плейлиста" -> "Редактирование плейлиста"
    static let showEditPlaylistMusicTableViewControllerForEditSegue = "ShowEditPlaylistMusicTableViewControllerForEditSegue"
    /// Вкладка "Плейлисты" -> "Aудиозаписи альбома"
    static let showAlbumAudioSegue = "ShowAlbumAudioSegue"
    /// "Aудиозаписи альбома" -> контейнер с музыкой
    static let showAlbumMusicTableViewControllerInContainerSegue = "ShowAlbumMusicTableViewControllerInContainerSegue"
    /// "Редактирование плейлиста" -> контейнер с добавляемой музыкой
    static let showEditPlaylistMusicTableViewControllerInContainerSegue = "ShowEditPlaylistMusicTableViewControllerInContainerSegue"
    /// "Редактирование плейлиста" -> "Добавление аудиозаписей в плейлист"
    static let showAddPlaylistMusicViewControllerSegue = "ShowAddPlaylistMusicViewControllerSegue"
    /// "Добавление аудиозаписей в плейлист" -> контейнер с музыкой
    static let showAddPlaylistMusicTableViewControllerInContainerSegue = "ShowAddPlaylistMusicTableViewControllerInContainerSegue"
    /// Вкладка "Еще" -> контейнер с ссылками на другие страницы
    static let showMoreTableViewControllerInContainerSegue = "ShowMoreTableViewControllerInContainerSegue"
    /// Вкладка "Еще" -> "Список друзей"
    static let showFriendsViewControllerSegue = "ShowFriendsViewControllerSegue"
    /// "Список друзей" -> контейнер с друзьями
    static let showFriendsTableViewControllerInContainerSegue = "ShowFriendsTableViewControllerInContainerSegue"
    /// "Список друзей" -> "Аудиозаписи друга"
    static let showFriendAudioViewControllerSegue = "ShowFriendAudioViewControllerSegue"
    /// Вкладка "Еще" -> "Список групп"
    static let showGroupsViewControllerSegue = "ShowGroupsViewControllerSegue"
    /// "Список групп" -> контейнер с группами
    static let showGroupsTableViewControllerInContainerSegue = "ShowGroupsTableViewControllerInContainerSegue"
    /// "Список групп" -> "Аудиозаписи группы"
    static let showGroupAudioViewControllerSegue = "ShowGroupAudioViewControllerSegue"
    /// "Аудиозаписи друга/группы" -> контейнер с музыкой
    static let showOwnerMusicTableViewControllerInContainerSegue = "ShowOwnerMusicTableViewControllerInContainerSegue"
    /// Вкладка "Еще" -> "Рекомендации"
    static let showRecommendationsMusicViewControllerSegue = "ShowRecommendationsMusicViewControllerSegue"
    ///  -> "Рекомендации" -> контейнер с музыкой
    static let showRecommendationsMusicTableViewControllerInContainerSegue = "ShowRecommendationsMusicTableViewControllerInContainerSegue"
    /// Вкладка "Еще" -> "Популярное"
    static let showPopularMusicViewControllerSegue = "ShowPopularMusicViewControllerSegue"
    /// "Популярное" -> контейнер с музыкой
    static let showPopularMusicTableViewControllerInContainerSegue = "ShowPopularMusicTableViewControllerInContainerSegue"
    /// Вкладка "Еще" -> "Настройки"
    static let showSettingsSegue = "ShowSettingsSegue"

}