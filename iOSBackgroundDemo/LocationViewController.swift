//
//  LocationViewController.swift
//  iOSBackgroundDemo
//
//  Created by ZhaoFucheng on 16/4/4.
//  Copyright © 2016年 ZhaoFucheng. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let manager = CLLocationManager()
    
    // 保存位置信息的数组
    var locations = [MKPointAnnotation]()
    
    //延迟加载
    lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //开始更新位置
        locationManager.startUpdatingLocation()
        
        //地图追踪用户位置
        mapView.userTrackingMode = .Follow
    }

    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print(status)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        // 在地图上添加位置大头针
        let annotation = MKPointAnnotation()
        annotation.coordinate = newLocation.coordinate
        
        // 将位置信息添加到数组中
        locations.append(annotation)
        
        // 保持地图上只有100个大头针
        while locations.count > 100 {
            let annotationToRemove = locations.first!
            locations.removeAtIndex(0)
            
            mapView.removeAnnotation(annotationToRemove)
        }
        
        if UIApplication.sharedApplication().applicationState == .Active {
            mapView.showAnnotations(locations, animated: true)
        } else {
            NSLog("App is backgrounded. New location is %@", newLocation)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    //地图的显示区域即将发生改变的时候调用
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
    }
    
    //地图的显示区域已经发生改变的时候调用
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        userLocation.title = "我的位置"
        userLocation.subtitle = "这就是我的位置怎么了"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
