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
        
        self.tabBarItem.image = UIImage(systemName: "folder")
        
        self.mcNearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "teste")
        self.mcNearbyServiceAdvertiser?.delegate = self
        self.serviceNearbyBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: "teste")
        self.serviceNearbyBrowser?.delegate = self
        self.mcSession = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .required)
        
        mcSession?.delegate = self
        
        //
        configureButtons()
        configureWriteButton()
    }
    
    func configureButtons() {
        let showDocumentsButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt))
        navigationItem.rightBarButtonItem = showDocumentsButton

    }
    
    func configureWriteButton() {
        view.addSubview(showMyFilesButton)
        showMyFilesButton.addTarget(self, action: #selector(showMyFilesAction), for: .touchUpInside)
        showMyFilesButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            showMyFilesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showMyFilesButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            showMyFilesButton.widthAnchor.constraint(equalToConstant: 200),
            showMyFilesButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func showConnectionPrompt() {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func showMyFilesAction() {
        let myFilesVC = MyFilesVC()
        navigationController?.pushViewController(myFilesVC, animated: true)        
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
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
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
        dismiss(animated: true)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        dismiss(animated: true)
    }
    
    
}

extension ViewController: MCBrowserViewControllerDelegate {
    
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        
    }
}
