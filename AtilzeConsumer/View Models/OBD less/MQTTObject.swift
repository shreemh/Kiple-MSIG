//
//  MQTTObject.swift
//  AtilzeConsumer
//
//  Created by Cognitive on 12/01/18.
//  Copyright © 2018 Cognitive. All rights reserved.
//

import UIKit
import Moscapsule

class MQTTObject: NSObject {
    struct Topics {
        var gpsData : String
        var tripSummary : String
        var alert : String
    }
    
    static let sharedInstance: MQTTObject = MQTTObject()
    var topics : Topics = Topics(gpsData: "", tripSummary: "", alert: "")
    
    // MARK: - MQTT
    func mqttTripSummary(dict : [String : Any], topic : String) {
        
        DispatchQueue.main.async {
            // flushPendingData()
            // MQTT
            if Model.shared.mqttClient == nil {
                let userName  = Utility.getMQTTUserName()
                self.topics = Topics(gpsData: "api/\(userName)/OBDless/Data/GPS", tripSummary: "api/\(userName)/OBDless/Data/TripSummary", alert: "api/\(userName)/OBDless/Data/Alert")
                Model.shared.mqttClient = MQTT.newConnection(Model.shared.mqttConfig!)
                Model.shared.mqttClient?.subscribe(self.topics.gpsData, qos: 0)
                Model.shared.mqttClient?.subscribe(self.topics.tripSummary, qos: 0)
                Model.shared.mqttClient?.subscribe(self.topics.alert, qos: 0)
            }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                Model.shared.mqttClient?.publish(jsonData, topic: self.topics.tripSummary, qos: 0, retain: false) { (res,_) in
                    
                    print(" ******* mqttTripSummary ******* ☺️")
                    print("res ======= \(res)")
                   
                    // 0 == success
                    if res.rawValue != 0 {
                       self.mqttTripSummary(dict: dict, topic: topic)
                    }
                }
                
            } catch {
                print("ERROR")
            }
        }
    }
    
    func mqttAlert(dict : [String : Any], topic : String) {
        //  flushPendingData()
        DispatchQueue.main.async {
            // MQTT
            if Model.shared.mqttClient == nil {
                let userName  = Utility.getMQTTUserName()
                self.topics = Topics(gpsData: "api/\(userName)/OBDless/Data/GPS", tripSummary: "api/\(userName)/OBDless/Data/TripSummary", alert: "api/\(userName)/OBDless/Data/Alert")
                Model.shared.mqttClient = MQTT.newConnection(Model.shared.mqttConfig!)
                Model.shared.mqttClient?.subscribe(self.topics.gpsData, qos: 0)
                Model.shared.mqttClient?.subscribe(self.topics.tripSummary, qos: 0)
                Model.shared.mqttClient?.subscribe(self.topics.alert, qos: 0)
            }
            print("dict == \(dict)")
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                Model.shared.mqttClient?.publish(jsonData, topic: topic, qos: 0, retain: false) { (res, _) in
                    print(" ****** mqttAlert ******* ☺️")
                    print("res ======= \(res)")
                    if res.rawValue != 0 {
                        self.mqttAlert(dict: dict, topic: topic)
                    }
                    Model.shared.mqttConfig?.onPublishCallback = {_ in
                        //  print("published ****")
                    }
                    Model.shared.mqttConfig?.onMessageCallback = {_ in
                        //  print("MQTT Message received")
                    }
                    Model.shared.mqttConfig?.onPublishCallback = { messageId in
                        //  print("published")
                    }
                    Model.shared.mqttConfig?.onMessageCallback = { mqttMessage in
                        // print("MQTT Message received")
                    }
                }
            } catch {
                print("ERROR")
            }
        }
    }
    
    func mqttStopAlert(dict : [String : Any], topic : String) {
        // flushPendingData()
        // MQTT
        DispatchQueue.main.async {
            if Model.shared.mqttClient == nil {
                let userName  = Utility.getMQTTUserName()
                self.topics = Topics(gpsData: "api/\(userName)/OBDless/Data/GPS", tripSummary: "api/\(userName)/OBDless/Data/TripSummary", alert: "api/\(userName)/OBDless/Data/Alert")
                Model.shared.mqttClient = MQTT.newConnection(Model.shared.mqttConfig!)
                Model.shared.mqttClient?.subscribe(self.topics.gpsData, qos: 0)
                Model.shared.mqttClient?.subscribe(self.topics.tripSummary, qos: 0)
                Model.shared.mqttClient?.subscribe(self.topics.alert, qos: 0)
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                Model.shared.mqttClient?.publish(jsonData, topic: topic, qos: 0, retain: false) { (res, _) in
                    print(" ******* mqttStopAlert ******* ☺️")
                    print("res ======= \(res)")
                    if res.rawValue != 0 {
                        self.mqttStopAlert(dict: dict, topic: topic)
                    }
                }
            } catch {
                print("ERROR")
            }
        }
    }
    
    func mqttGPSData(dict : [String : Any]) {
        DispatchQueue.main.async {
            // flushPendingData()
            // MQTT
            if Model.shared.mqttClient == nil {
                let userName  = Utility.getMQTTUserName()
                self.topics = Topics(gpsData: "api/\(userName)/OBDless/Data/GPS", tripSummary: "api/\(userName)/OBDless/Data/TripSummary", alert: "api/\(userName)/OBDless/Data/Alert")
                Model.shared.mqttClient = MQTT.newConnection(Model.shared.mqttConfig!)
                Model.shared.mqttClient?.subscribe(self.topics.gpsData, qos: 0)
                Model.shared.mqttClient?.subscribe(self.topics.tripSummary, qos: 0)
                Model.shared.mqttClient?.subscribe(self.topics.alert, qos: 0)
            }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                Model.shared.mqttClient?.publish(jsonData, topic: self.topics.gpsData, qos: 0, retain: false) { (res,_) in
                    print(" ******* mqttGPSData ******* ☺️")
                    print("res ======= \(res)")
                    if res.rawValue != 0 {
                        self.mqttGPSData(dict: dict)
                    }
                }
                Model.shared.mqttConfig?.onSubscribeCallback = {res in
                    print("Subscribed")
                }
                Model.shared.mqttConfig?.onPublishCallback = { messageId in
                    print("published")
                }
                Model.shared.mqttConfig?.onMessageCallback = { mqttMessage in
                    print("MQTT Message received")
                    //   self.Model.shared.mqttClient?.disconnect()
                }
            } catch {
                print("Error")
            }
        }
    }
    
    func flushPendingData() {
        DispatchQueue.main.async {
            if let mqttInfo = UserDefaults.standard.object(forKey: "VW.Consumer.MQTTInfo") as? [String : Any] {
                // MQTT
                let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
                let port: Int = mqttInfo["port"] as? Int ?? 0
                let portInt32 : Int32 = Int32(port)
                let host : String = mqttInfo["host"] as? String ?? ""
                let userName : String = mqttInfo["username"] as? String ?? ""
                let password : String = mqttInfo["password"] as? String ?? ""
                
                Model.shared.mqttConfig = MQTTConfig(clientId: clientID, host: host, port: portInt32, keepAlive: 100)
                Model.shared.mqttConfig?.mqttAuthOpts = MQTTAuthOpts(username: userName, password: password)
                Model.shared.mqttClient = nil
            }
        }
        
        let start : [String: Any] = UserDefaults.standard.object(forKey: "VW.Consumer.Start") as? [String : Any] ?? [String : Any]()
        let alertsArray : [[String : Any]] = UserDefaults.standard.object(forKey: "VW.Consumer.Incidents") as? [[String : Any]] ?? [[String : Any]]()
        
        var GPSData : [String : Any] = UserDefaults.standard.object(forKey: "VW.Consumer.GPSData") as? [String : Any] ?? [String : Any]()
        var GPSDataArray = GPSData["gpsData"] as? [[String : Any]] ?? [[String : Any]]()
        if  Model.shared.gspDictArray.count > 0 {
            GPSDataArray.append(contentsOf: Model.shared.gspDictArray)
            Model.shared.gspDictArray.removeAll()
        }
        if GPSDataArray.count > 0 {
            GPSData["gpsData"] = GPSDataArray
        }
        
        let stop : [String: Any] = UserDefaults.standard.object(forKey: "VW.Consumer.Stop") as? [String : Any] ?? [String : Any]()
        let summary : [String: Any] = UserDefaults.standard.object(forKey: "VW.Consumer.Summary") as? [String : Any] ?? [String : Any]()
        
        if !start.isEmpty {
            UserDefaults.standard.removeObject(forKey: "VW.Consumer.Start")
            mqttAlert(dict: start, topic: topics.alert)
        }
        if !GPSData.isEmpty {
            UserDefaults.standard.removeObject(forKey: "VW.Consumer.GPSData")
            mqttGPSData(dict: GPSData)
        }
        for (_, data) in alertsArray.enumerated() {
            UserDefaults.standard.removeObject(forKey: "VW.Consumer.Incidents")
            mqttAlert(dict: data, topic: topics.alert)
        }
        if !stop.isEmpty {
            UserDefaults.standard.removeObject(forKey: "VW.Consumer.Stop")
            mqttStopAlert(dict: stop, topic: topics.alert)
        }
        if !summary.isEmpty {
            UserDefaults.standard.removeObject(forKey: "VW.Consumer.Summary")
            mqttTripSummary(dict: summary, topic: topics.tripSummary)
        }
        
    }
}
