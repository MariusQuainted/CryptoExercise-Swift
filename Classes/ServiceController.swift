//
//  ServiceController.swift
//  CryptoExercise
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/4/18.
//
//
/*

 File: ServiceController.h
 File: ServiceController.m
 Abstract: Responsible for connection UI and providing an interface to
 executing a connect request.

 Version: 1.2

 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 Copyright (C) 2008-2009 Apple Inc. All Rights Reserved.

 */

import UIKit

@objc(ServiceController)
class ServiceController: UIViewController, CryptoClientDelegate, NSNetServiceDelegate {
    var service: NSNetService? {
        willSet {
            willSetService(newValue)
        }
        didSet {
            didSetService(oldValue)
        }
    }
    var cryptoClient: CryptoClient?
    @IBOutlet var serviceLabel: UILabel!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var statusLog: UITextView!
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        serviceLabel.text = self.service?.name
        connectButton.enabled = false
        spinner.startAnimating()
        statusLog.text = "Resolving service..."
    }
    
    private func willSetService(aService: NSNetService?) {
        self.service?.stop()
    }
    private func didSetService(oldValue: NSNetService?) {
        self.service?.delegate = self
        // Attempt to resolve the self.service. A value of 0.0 sets an unlimited time to resolve it. The user can
        // choose to cancel the resolve by selecting another self.service in the table view.
        self.service?.resolveWithTimeout(0.0)
    }
    
    func netServiceDidResolveAddress(sender: NSNetService) {
        spinner.stopAnimating()
        self.spinner.hidden = true
        self.statusLog.text? += " Done\n"
        self.connectButton.enabled = true
    }
    
    func cryptoClientDidReceiveError(cryptoClient: CryptoClient) {
        self.navigationController?.popViewControllerAnimated(true)
        self.cryptoClient = nil
    }
    
    @IBAction func connect() {
        statusLog.text = "Resolving service... Done\n"
        spinner.startAnimating()
        self.spinner.hidden = false
        self.connectButton.enabled = false
        self.statusLog.text? += "Connecting..."
        
        let thisClient = CryptoClient(service: self.service, delegate: self)
        self.cryptoClient = thisClient
        self.cryptoClient!.runConnection()
    }
    
    func cryptoClientDidCompleteConnection(cryptoClient: CryptoClient) {
        self.statusLog.text? += " Done\n"
    }
    
    func cryptoClientWillBeginReceivingData(cryptoClient: CryptoClient) {
        self.statusLog.text? += "Receiving data..."
    }
    
    func cryptoClientDidFinishReceivingData(cryptoClient: CryptoClient) {
        self.statusLog.text? += " Done\n"
    }
    
    func cryptoClientWillBeginVerifyingData(cryptoClient: CryptoClient) {
        self.statusLog.text? += "Verifying blob..."
    }
    
    func cryptoClientDidFinishVerifyingData(cryptoClient: CryptoClient, verified: Bool) {
        self.statusLog.text? += (verified ? " Verified!" : " Failed!")
        spinner.stopAnimating()
        self.spinner.hidden = true
        self.connectButton.enabled = true
        self.cryptoClient = nil
    }
    
    
}