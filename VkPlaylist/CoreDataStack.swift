//
//  CoreDataStack.swift
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