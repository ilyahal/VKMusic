//
//  VKAPIManagerNotifications.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 11.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

// Уведомления о событиях при авторизации
let VKAPIManagerDidAutorizeNotification = "VKAPIManagerDidAutorizeNotification" // Уведомление о том, что авторизация успешно пройдена
let VKAPIManagerDidUnautorizeNotification = "VKAPIManagerDidUnautorizeNotification" // Уведомление о том, что была произведена деавторизация
let VKAPIManagerAutorizationFailedNotification = "VKAPIManagerAutorizationFailedNotification" // Уведомление о том, что при авторизации была ошибка

// Уведомления о событиях при получения личных аудиозаписей
let VKAPIManagerDidGetAudioNotification = "VKAPIManagerDidGetAudioNotification" // Уведомление о том, что список личных аудиозаписей был получен
let VKAPIManagerGetAudioNetworkErrorNotification = "VKAPIManagerGetAudioNetworkErrorNotification" // Уведомление о том, что при получении личных аудиозаписей произошла ошибка при подключении к интернету
let VKAPIManagerGetAudioErrorNotification = "VKAPIManagerGetAudioErrorNotification" // Уведомление о том, что при получении личных аудиозаписей произошла ошибка

// Уведомления о событиях при получения искомых аудиозаписей
let VKAPIManagerDidSearchAudioNotification = "VKAPIManagerDidSearchAudioNotification" // Уведомление о том, что список искомых аудиозаписей был получен
let VKAPIManagerSearchAudioNetworkErrorNotification = "VKAPIManagerSearchAudioNetworkErrorNotification" // Уведомление о том, что при получении искомых аудиозаписей произошла ошибка при подключении к интернету
let VKAPIManagerSearchAudioErrorNotification = "VKAPIManagerSearchAudioErrorNotification" // Уведомление о том, что при получении искомых аудиозаписей произошла ошибка

// Уведомления о событиях при получения альбомов пользователя
let VKAPIManagerDidGetAlbumsNotification = "VKAPIManagerDidGetAlbumsNotification" // Уведомление о том, что список популярных альбомов был получен
let VKAPIManagerGetAlbumsNetworkErrorNotification = "VKAPIManagerGetAlbumsNetworkErrorNotification" // Уведомление о том, что при получении альбомов произошла ошибка при подключении к интернету
let VKAPIManagerGetAlbumsErrorNotification = "VKAPIManagerGetAlbumsErrorNotification" // Уведомление о том, что при получении альбомов произошла ошибка

// Уведомления о событиях при получения аудиозаписей из указанного альбома
let VKAPIManagerDidGetAudioForAlbumNotification = "VKAPIManagerDidGetAudioForAlbumNotification" // Уведомление о том, что список популярных альбомов был получен
let VKAPIManagerGetAudioForAlbumNetworkErrorNotification = "VKAPIManagerGetAudioForAlbumNetworkErrorNotification" // Уведомление о том, что при получении альбомов произошла ошибка при подключении к интернету
let VKAPIManagerGetAudioForAlbumErrorNotification = "VKAPIManagerGetAudioForAlbumErrorNotification" // Уведомление о том, что при получении альбомов произошла ошибка

// Уведомления о событиях при получения списка друзей
let VKAPIManagerDidGetFriendsNotification = "VKAPIManagerDidGetFriendsNotification" // Уведомление о том, что список друзей был получен
let VKAPIManagerGetFriendsNetworkErrorNotification = "VKAPIManagerGetFriendsNetworkErrorNotification" // Уведомление о том, что при получении друзей произошла ошибка при подключении к интернету
let VKAPIManagerGetFriendsErrorNotification = "VKAPIManagerGetFriendsErrorNotification" // Уведомление о том, что при получении друзей произошла ошибка

// Уведомления о событиях при получения списка групп
let VKAPIManagerDidGetGroupsNotification = "VKAPIManagerDidGetGroupsNotification" // Уведомление о том, что список групп был получен
let VKAPIManagerGetGroupsNetworkErrorNotification = "VKAPIManagerGetGroupsNetworkErrorNotification" // Уведомление о том, что при получении групп произошла ошибка при подключении к интернету
let VKAPIManagerGetGroupsErrorNotification = "VKAPIManagerGetGroupsErrorNotification" // Уведомление о том, что при получении групп произошла ошибка

// Уведомления о событиях при получения списка друзей
let VKAPIManagerDidGetAudioForOwnerNotification = "VKAPIManagerDidGetAudioForOwnerNotification" // Уведомление о том, что список аудиозаписей указанного пользователя был получен
let VKAPIManagerGetAudioForOwnerNetworkErrorNotification = "VKAPIManagerGetAudioForOwnerNetworkErrorNotification" // Уведомление о том, что при получении аудиозаписей указанного пользователя произошла ошибка при подключении к интернету
let VKAPIManagerGetAudioForOwnerAccessErrorNotification = "VKAPIManagerGetAudioForOwnerAccessErrorNotification" // Уведомление о том, что при получении аудиозаписей указанного пользователя произошла ошибка доступа
let VKAPIManagerGetAudioForOwnerErrorNotification = "VKAPIManagerGetAudioForOwnerErrorNotification" // Уведомление о том, что при получении аудиозаписей указанного пользователя произошла ошибка

// Уведомления о событиях при получения рекомендуемых аудиозаписей
let VKAPIManagerDidGetRecommendationsAudioNotification = "VKAPIManagerDidGetRecommendationsAudioNotification" // Уведомление о том, что список рекомендуемых аудиозаписей был получен
let VKAPIManagerGetRecommendationsAudioNetworkErrorNotification = "VKAPIManagerGetRecommendationsAudioNetworkErrorNotification" // Уведомление о том, что при получении рекомендуемых аудиозаписей произошла ошибка при подключении к интернету
let VKAPIManagerGetRecommendationsAudioErrorNotification = "VKAPIManagerGetRecommendationsAudioErrorNotification" // Уведомление о том, что при получении рекомендуемых аудиозаписей произошла ошибка

// Уведомления о событиях при получения популярных аудиозаписей
let VKAPIManagerDidGetPopularAudioNotification = "VKAPIManagerDidGetPopularAudioNotification" // Уведомление о том, что список популярных аудиозаписей был получен
let VKAPIManagerGetPopularAudioNetworkErrorNotification = "VKAPIManagerGetPopularAudioNetworkErrorNotification" // Уведомление о том, что при получении популярных аудиозаписей произошла ошибка при подключении к интернету
let VKAPIManagerGetPopularAudioErrorNotification = "VKAPIManagerGetPopularAudioErrorNotification" // Уведомление о том, что при получении популярных аудиозаписей произошла ошибка
