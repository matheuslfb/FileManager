//
//  Manager.swift
//  FilesTeste
//
//  Created by Matheus Lima Ferreira on 4/25/20.
//  Copyright © 2020 Matheus Lima Ferreira. All rights reserved.
//

import Foundation

class Manager {
    
    let file = "\(UUID().uuidString).txt"
    let contents = "Texto de teste!"
    
    let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//    let fileURL = dir.appendPathComponent(file)
    
    init() {
//       let fileURL = URL(string: dir.appendPathComponent(file))
        
        do {
            try contents.write(to: dir.appendPathComponent(file), atomically: false, encoding: .utf8)
        } catch  {
            print("Error \(error)")
        }
        
    }
}
