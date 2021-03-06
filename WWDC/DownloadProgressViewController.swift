//
//  DownloadProgressViewController.swift
//  WWDC
//
//  Created by Guilherme Rambo on 22/04/15.
//  Copyright (c) 2015 Guilherme Rambo. All rights reserved.
//

import Cocoa

class DownloadProgressViewController: NSViewController {

    var session: Session! {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet var downloadButton: NSButton!
    @IBOutlet var progressIndicator: NSProgressIndicator!
    
    var downloadFinishedCallback: () -> () = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI()
    {
        if let session = session {
            if session.hd_url != nil {
                view.hidden = false
                updateDownloadStatus()
            } else {
                view.hidden = true
            }
        } else {
            view.hidden = true
        }
    }
    
    private func updateDownloadStatus()
    {
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserverForName(VideoStoreStartedDownloadNotification, object: nil, queue: NSOperationQueue.mainQueue()) { note in
            if self.session.hd_url == nil {
                return
            }
            
            if let url = note.object as? String {
                if url != self.session.hd_url! {
                    return
                }
            } else {
                return
            }
            
            self.progressIndicator.hidden = false
            self.downloadButton.hidden = true
        }
        nc.addObserverForName(VideoStoreFinishedDownloadNotification, object: nil, queue: NSOperationQueue.mainQueue()) { note in
            if self.session.hd_url == nil {
                return
            }
            
            if let url = note.object as? String {
                if url != self.session.hd_url! {
                    return
                }
            } else {
                return
            }
            
            self.progressIndicator.hidden = true
            self.downloadButton.hidden = true
            
            self.downloadFinishedCallback()
        }
        nc.addObserverForName(VideoStoreDownloadProgressedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { note in
            if self.session.hd_url == nil {
                return
            }
            
            if let url = note.object as? String {
                if url != self.session.hd_url! {
                    return
                }
            } else {
                return
            }
            
            self.progressIndicator.hidden = false
            self.downloadButton.hidden = true
            
            if let info = note.userInfo {
                if let totalBytesExpectedToWrite = info["totalBytesExpectedToWrite"] as? Int {
                    self.progressIndicator.maxValue = Double(totalBytesExpectedToWrite)
                }
                if let totalBytesWritten = info["totalBytesWritten"] as? Int {
                    self.progressIndicator.doubleValue = Double(totalBytesWritten)
                }
            }
        }
        
        if VideoStore.SharedStore().isDownloading(session.hd_url!) {
            self.progressIndicator.hidden = false
            self.downloadButton.hidden = true
        } else {
            if VideoStore.SharedStore().hasVideo(session.hd_url!) {
                self.progressIndicator.hidden = true
                self.downloadButton.hidden = true
            } else {
                self.progressIndicator.hidden = true
                self.downloadButton.hidden = false
            }
        }
    }
    
    @IBAction func download(sender: NSButton) {
        if let url = session.hd_url {
            VideoStore.SharedStore().download(url)
        }
    }
}
