//
//  ViewController.swift
//  2chat
//
//  Created by Apple on 10/07/18.
//  Copyright © 2018 nrk. All rights reserved.
//

import UIKit
import StompClientLib
import SlackTextViewController

class ViewController: UIViewController, StompClientLibDelegate, UITableViewDataSource, UITableViewDelegate{
    
    let socket_url = "wss://2chat.duckdns.org/chat-socket/websocket"
    
    @IBOutlet weak var lblMessages: UILabel!
    @IBOutlet weak var txtMessage: UITextField!
    
    let socketClient = StompClientLib()
    
    @IBOutlet weak var tbvChat: UITableView!
    
    var chat = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(ViewController.description())
        
        
        tbvChat.reloadData()
        initTableView()
        let url = NSURL(string: socket_url)!
        socketClient.openSocketWithURLRequest(request: NSURLRequest(url: url as URL) , delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initTableView(){
        tbvChat.rowHeight = UITableViewAutomaticDimension
        tbvChat.estimatedRowHeight = 100
        tbvChat.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_message", for: indexPath)
        let lblMessage = cell.viewWithTag(1) as! UILabel
        lblMessage.text = chat[indexPath.row]
        return cell
    }
    

    @IBAction func btnSend(_ sender: Any) {
        var message = ""
        if !(txtMessage.text?.isEmpty)! {
            message = txtMessage.text!
            let json = ["user" : "ios",
                        "content" : message] as AnyObject
            socketClient.sendJSONForDict(dict: json, toDestination: "/topic/chat")
            txtMessage.text = ""
        }
        
    }
    
    func stompClient(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: AnyObject?, withHeader header: [String : String]?, withDestination destination: String) {
        print("stompClient")
        
        print(jsonBody!["content"] as! String)
        chat.append(jsonBody!["content"] as! String)
        tbvChat.reloadData()
    }
    
    func stompClientJSONBody(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: String?, withHeader header: [String : String]?, withDestination destination: String) {
        print("stompClientJSONBody")
        
    }
    
    func stompClientDidDisconnect(client: StompClientLib!) {
        print("stompClientDidDisconnect")
    }
    
    func stompClientDidConnect(client: StompClientLib!) {
        print("Socket is connected")
        // Stomp subscribe will be here!
        socketClient.subscribe(destination: "/topic/chat")
        // Note : topic needs to be a String object
    }
    
    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        print("serverDidSendReceipt")
    }
    
    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
        print("serverDidSendError")
    }
    
    func serverDidSendPing() {
        print("serverDidSendPing")
    }
}


