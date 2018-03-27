//
//  DeviceMotion.swift
//  AtilzeConsumer
//
//  Created by Shree on 12/12/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import CoreMotion

protocol CoreMotionDelegate: NSObjectProtocol {
    func tracingDeviceMotion(deviceMotion: CMDeviceMotion)
    func tracingDeviceActivity(deviceActivity: CMMotionActivity)
}

//protocol CoreMotionDelegate {
//    func tracingDeviceMotion(deviceMotion: CMDeviceMotion)
//    func tracingDeviceActivity(deviceActivity: CMMotionActivity)
//}

class DeviceMotion: NSObject {
    static let deviceData = DeviceMotion()
    var motionManager : CMMotionManager?
    var activityManager : CMMotionActivityManager?
    
    weak var delegate: CoreMotionDelegate?

    override init() {
        
        super.init()
        self.motionManager = CMMotionManager()
        self.activityManager = CMMotionActivityManager()
    
        
        if motionManager?.isDeviceMotionAvailable ?? CMMotionManager().isDeviceMotionActive {
            motionManager?.deviceMotionUpdateInterval = 0.2
            motionManager?.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: { (deviceData: CMDeviceMotion!, error: Error!) in
                self.updateDeviceMotionData(deviceMotion: deviceData)
            })
        }
       
        if CMMotionActivityManager.isActivityAvailable() {
            activityManager?.startActivityUpdates(to: OperationQueue.current!, withHandler: { (deviceActivity: CMMotionActivity!) in
                self.deviceActivity(deviceActivityObj: deviceActivity)
            })
        }
        
//        if (motionManager?.isAccelerometerAvailable)! {
//            motionManager?.accelerometerUpdateInterval = 0.2
//            motionManager?.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (accelelerometerData: CMAccelerometerData!, error: Error!) in
//                self.updateAccelerometerData(acceleration: accelelerometerData.acceleration)
//            })
//        }
    }
    
    private func updateAccelerometerData(acceleration: CMAcceleration) {
//        if (acceleration.x >= 0.75) {
//            print("UIInterfaceOrientationLandscapeLeft") }
//        else if (acceleration.x <= -0.75) {
//            print("UIInterfaceOrientationLandscapeRight") }
//        else if (acceleration.y <= -0.75) {
//            print("UIInterfaceOrientationPortrait") }
//        else if (acceleration.y >= 0.75) {
//            print("UIInterfaceOrientationPortraitUpsideDown")}
//        else {
//           print("Consider same as last time")
//        }
        
    }
    
    private func updateDeviceMotionData(deviceMotion: CMDeviceMotion) {
        guard let delegate = self.delegate else {
            return
        }
        delegate.tracingDeviceMotion(deviceMotion: deviceMotion)
    }
    
    private func deviceActivity(deviceActivityObj: CMMotionActivity) {
        guard let delegate = self.delegate else {
            return
        }
        delegate.tracingDeviceActivity(deviceActivity: deviceActivityObj)
    }
}
