//
//  Document.swift
//  FilesTeste
//
//  Created by Matheus Lima Ferreira on 4/25/20.
//  Copyright © 2020 Matheus Lima Ferreira. All rights reserved.
//

import UIKit

class Document: UIDocument {
    
    override func contents(forType typeName: String) throws -> Any {
        return Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        
    }
}
