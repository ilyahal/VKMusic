//
//  CoreDataStack.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 26.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import CoreData

/// Стэк CoreData
class CoreDataStack {
    
    let modelName = "VKPlaylist"
    
    
    /// Временная память для работы с объектами
    lazy var context: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType) // Инициализируем контекст
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator // Присваиваем контексту координатор с указанной моделью
        
        return managedObjectContext
    }()
    
    /// Мост между моделью и хранилищем
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel) // Инизиализируем координатор для указанной модели
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.modelName) // Создаем URL для доступа к модели
        let options = [
            NSMigratePersistentStoresAutomaticallyOption : true // Автоматически попытаться переместить имеющуюся версию хранилища
        ]
        
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options) // Добавляем к координатору базу данных с указанными параметрами конфигурации
        } catch {
            print("Error adding persistent store.")
        }
        
        return coordinator
    }()
    
    /// Модель
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(self.modelName, withExtension: "momd")! // Получаем URL базы данных
        
        return NSManagedObjectModel(contentsOfURL: modelURL)! // Инициализируем и возвращаем модель
    }()
    
    /// Место для сохранения базы данных
    private lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        return urls[urls.count - 1]
    }()
    
    
    /// Попытка сохранить контекст
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
                abort()
            }
        }
    }
    
}