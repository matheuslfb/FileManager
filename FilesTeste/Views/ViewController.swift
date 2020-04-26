//
//  ViewController.swift
//  FilesTeste
//
//  Created by Matheus Lima Ferreira on 4/25/20.
//  Copyright © 2020 Matheus Lima Ferreira. All rights reserved.
//

import MobileCoreServices
import MultipeerConnectivity
import UIKit

class ViewController: UIViewController {
    
    var listOfSharedFiles = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    
    var peerID = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCAdvertiserAssistant?
    
    var mcNearbyServiceAdvertiser: MCNearbyServiceAdvertiser?
    var serviceNearbyBrowser: MCNearbyServiceBrowser?
    
    
    let showMyFilesButton = CustomButton(backgroundColor: .systemGreen, title: "Show My Files")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "P2P - \(UIDevice.current.name)"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .systemGreen
        
        ///table view
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tabBarItem.title = "Shared Files"
        
        self.mcNearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "teste")
        self.mcNearbyServiceAdvertiser?.delegate = self
        self.serviceNearbyBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: "teste")
        self.serviceNearbyBrowser?.delegate = self
        self.mcSession = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .required)
        
        mcSession?.delegate = self
        
        //
        configureButtons()
    }
    
    func configureButtons() {
        let myFilesButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showMyFilesAction))
        let showDocumentsButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showConnectionPrompt))
        navigationItem.rightBarButtonItem = showDocumentsButton
        navigationItem.leftBarButtonItem = myFilesButton
    }
    
    @objc func showConnectionPrompt() {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func showMyFilesAction() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeItem as String], in: .import);
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.documentPickerMode
        present(documentPicker, animated: true)
    }
    
    func sendFile(data: String) {
        guard let mcSession = mcSession  else { return }
        if mcSession.connectedPeers.count  > 0 {
            if let _data = data.data(using: .utf8) {
                do {
                    try mcSession.send(_data, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch  {
                    let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
                }
            }
        }
    }
    
    private func startHosting(action: UIAlertAction) {
        guard let mcSession = mcSession  else { return }
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "teste", discoveryInfo: nil, session: mcSession)
        self.mcNearbyServiceAdvertiser?.startAdvertisingPeer()
        mcAdvertiserAssistant?.start()
    }
    
    private func joinSession(action: UIAlertAction) {
        guard let mcSession = mcSession  else { return }
        
        self.serviceNearbyBrowser?.delegate = self
        self.serviceNearbyBrowser?.startBrowsingForPeers()
        let mcBrowser = MCBrowserViewController(serviceType: "teste", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
}

extension ViewController: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected: \(peerID.displayName) ")
        case .connecting:
            print("Connecting...: \(peerID.displayName) ")
        case .notConnected:
            print("Not connected: \(peerID.displayName) ")
        @unknown default:
            print("Unknow state received: \(peerID.displayName) ")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let file = String(data: data, encoding: .utf8) {            
            print(file)
            DispatchQueue.main.async {
                self.listOfSharedFiles.append(file)
                self.tableView.reloadData()
            }
        }
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfSharedFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "SharedFileCell")
        
        cell.selectionStyle = .default
        
        cell.textLabel?.text = listOfSharedFiles[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            listOfSharedFiles.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = listOfSharedFiles[indexPath.row]
        
        guard let mcSession = mcSession  else { return }
        if mcSession.connectedPeers.count  > 0 {
            if let _data = file.data(using: .utf8) {
                do {
                    try mcSession.send(_data, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch  {
                    let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
                }
            }
        }
    }
    
    
}

extension ViewController: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        guard let mcSession = mcSession else { return }
        
        print("didReceiveInvitationFromPeer: \(peerID.displayName)")
        invitationHandler(true, mcSession)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("didNotStartAdvertisingPeer: \(error)")
    }
    
    
}

extension ViewController: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("found peer: \(peerID.displayName)")
        guard let mcSession = mcSession else { return }
        browser.invitePeer(peerID, to: mcSession, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lostPeer: \(peerID.displayName)")
    }
    
    
}

extension ViewController: MCBrowserViewControllerDelegate {
    
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
}

///Document picker delegate
extension ViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sandboxFileURL = dir.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        print(sandboxFileURL.lastPathComponent)
        DispatchQueue.main.async {
            
            
            self.listOfSharedFiles.append(sandboxFileURL.lastPathComponent)
            self.tableView.reloadData()
        }
    }
    
    
}

