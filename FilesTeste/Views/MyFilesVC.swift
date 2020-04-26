//
//  MyFilesVC.swift
//  FilesTeste
//
//  Created by Matheus Lima Ferreira on 4/25/20.
//  Copyright © 2020 Matheus Lima Ferreira. All rights reserved.
//

import MobileCoreServices

import UIKit

class MyFilesVC: UITableViewController {
    
    var listOfFiles = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Files"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        self.tabBarItem.image = UIImage(systemName: "house")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        configureNavButtons()
        getFilesName()
    }
    
    func getFilesName() {
        
        let filemanager = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        
        //        do {
        //            let items = try? fm.contentsOfDirectory(atPath: filemanager.absoluteString)
        //            for item in items! {
        //
        //                listOfFiles.append(item)
        //            }
        //            print("depois de ler os arquivos\(listOfFiles.count)")
        //        } catch  {
        //            print(error.localizedDescription)
        //        }
        
        
        
    }
    
    func configureNavButtons() {
        let showDocumentsButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showDocuments))
        navigationItem.rightBarButtonItem = showDocumentsButton
        
    }
    
    @objc func browseVC() {
        let browserVC = UIDocumentBrowserViewController(forOpeningFilesWithContentTypes: [kUTTypeItem as String])
        browserVC.delegate = self
        browserVC.allowsDocumentCreation = true
        browserVC.allowsPickingMultipleItems = false
        present(browserVC, animated: true)
    }
    
    @objc func showDocuments() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeItem as String], in: .import);
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.documentPickerMode
        present(documentPicker, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        
        cell.selectionStyle = .default
        
        cell.textLabel?.text = listOfFiles[indexPath.row]
        
        return cell
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfFiles.count
    }
    
    
    
    //        let file = "\(UUID().uuidString).txt"
    //        let contents = UIDevice.current.name
    //
    //        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    //        let fileURL = dir.appendingPathComponent(file)
    //
    //        do {
    //            try contents.write(to: fileURL, atomically: false, encoding: .utf8)
    //        } catch  {
    //            print("ERROR: \(error)")
    //        }
}


extension MyFilesVC: UIDocumentBrowserViewControllerDelegate {
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // When the user has chosen an existing document, a new `DocumentViewController` is presented for the first document that was picked.
        //        presentDocument(at: sourceURL)
        print(sourceURL.lastPathComponent)
        listOfFiles.append(sourceURL.lastPathComponent)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        
        print("quero criar um doc")
        let file = "\(UUID().uuidString).txt"
        let contents = UIDevice.current.name
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = dir.appendingPathComponent(file)
        
        do {
                    try contents.write(to: fileURL, atomically: false, encoding: .utf8)
                } catch  {
                    
                    print("ERROR: \(error)")
                }
    }
}


///Document picker delegate
extension MyFilesVC: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sandboxFileURL = dir.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        print(sandboxFileURL.lastPathComponent)
        DispatchQueue.main.async {
            self.listOfFiles.append(sandboxFileURL.lastPathComponent)
            self.tableView.reloadData()
        }
        //        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
        //            print("Already exist")
        //        } else {
        //            do{
        //                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
        //                print("Copied file!")
        //            } catch {
        //                print("ERROR to try copy: \(error)")
        //
        //            }
        //        }
    }
    
    
}



