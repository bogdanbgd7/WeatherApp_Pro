//
//  ViewController.swift
//  WeatherApp_Pro
//
//  Created by Bogdan Ponocko on 06/08/2020.
//  Copyright © 2020 Bogdan Ponocko. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    func userEnteredANewCityName(city: String) {
        //print(city)
        
        let params : [String : String] = ["q" : city,
                                          "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)

    }
    
    //MARK: - Variables
    var locationManager: CLLocationManager!
    let weatherDataModel = WeatherDataModel()
    
    //MARK: - Outlets
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var minimumTempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var descrptionLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    
    //MARK: - Constants for openweathermap
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "39702fbf6ac94139452854d574861542"
    
    
    //hide home indicator
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //Slide in menu test
        //setupCard()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters //best accuracy for weather apps
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation() //asynchronus method
        }
        
        
        
    }
    
    
    //MARK: - Location Manager protocol methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        
        locationManager.stopUpdatingLocation()

        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        let latitude = String(userLocation.coordinate.latitude)
        let longitude = String(userLocation.coordinate.longitude)
        
        //parameters for openweathermap api which can be found in their documentation.
        let params : [String : String] = ["lat" : latitude,
                                          "lon" : longitude,
                                          "appid" : APP_ID]
        
        
        
        getWeatherData(url: WEATHER_URL, parameters: params)
    
        

//        let geocoder = CLGeocoder()
//        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
//            if (error != nil){
//                print("error in reverseGeocode")
//            }
//            let placemark = placemarks! as [CLPlacemark]
//            if placemark.count>0{
//                let placemark = placemarks![0]
//                print(placemark.locality!)
//                print(placemark.administrativeArea!)
//                print(placemark.country!)
//                print(placemark.postalCode!)
//                print(placemark.timeZone!)
//
//
//                self.cityLabel.text = "\(placemark.locality!), \(placemark.administrativeArea!), \(placemark.country!)"
//
//
//            }
//        }

    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
        
        let alert = UIAlertController(title: "Warning", message: "Location can not be retrieved.\nPlease check your internet connection.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    //MARK: - NETWORKING
    func getWeatherData(url: String, parameters: [String : String]){
        
        //import Alamofire and SwiftyJSON before doing this
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            
            response in
            
            if response.result.isSuccess{
                
                //print(response)
                //formating JSON data we got from our api response
                let weatherJSON : JSON = JSON(response.result.value!)
                
                self.updateWeatherData(json: weatherJSON)
                
            }
            else {
                
                print("Error: \(response.result.error)")
                self.cityLabel.text = "Connection issue."
                
            }
            
            
        }
        
    }
    
    
    
    //MARK: - JSON PARSING
    func updateWeatherData(json: JSON) {
        
        let tempResult = json["main"]["temp"].double
        let minimumTempResult = json["main"]["temp_min"].double
        let humidityResult = json["main"]["humidity"].int
        let weatherIconResult = json["weather"][0]["id"].int
        let descriptionResult = json["weather"][0]["description"].string
        let cityResult = json["name"].string
        let countryResult : String? = json["sys"]["country"].stringValue
        
        if cityResult == nil {
            
            print("city name value is nil.")
            
        }
            
       print(countryResult)
        
        
        weatherDataModel.temperature = Int(tempResult! - 273.15) //K - 273.15 = C
        weatherDataModel.minimumTemperature = Int(minimumTempResult! - 273.15)
        weatherDataModel.humidity = humidityResult!
        weatherDataModel.description = descriptionResult!
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherIconResult!)
        weatherDataModel.city = cityResult!
        weatherDataModel.country = countryResult!
        
        
        
        //update UI with WeatherDataModel values
        updateUIWithWeatherData()
            
        
        
    }
    
    //UI
    func updateUIWithWeatherData() {
        
        self.temperatureLabel.text = "\(weatherDataModel.temperature)°"
        self.minimumTempLabel.text = "\(weatherDataModel.minimumTemperature)°"
        self.humidityLabel.text = "\(weatherDataModel.humidity)"
        self.descrptionLabel.text = "\(weatherDataModel.description)"
        self.weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        self.cityLabel.text = "\(weatherDataModel.city)"
        self.countryLabel.text = "\(weatherDataModel.country)"
        
    }
    
    //Segue delegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityIdentifier" {
            
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
            
        }
    }
    
    //Slide in Controller TEST
    
//    enum CardState {
//        case expanded
//        case collapsed
//    }
//
//    var cardViewController:SlideInViewController!
//    var visualEffectView:UIVisualEffectView!
//
//    let cardHeight:CGFloat = 400
//    let cardHandleAreaHeight:CGFloat = 65
//
//    var cardVisible = false
//    var nextState:CardState {
//        return cardVisible ? .collapsed : .expanded
//    }
//
//    var runningAnimations = [UIViewPropertyAnimator]()
//    var animationProgressWhenInterrupted:CGFloat = 0
//
//
//    func setupCard() {
//        visualEffectView = UIVisualEffectView()
//        visualEffectView.frame = self.view.frame
//        self.view.addSubview(visualEffectView)
//
//        cardViewController = SlideInViewController(nibName: "SlideInMenu", bundle: nil)
//        self.addChild(cardViewController)
//        self.view.addSubview(cardViewController.view)
//
//        cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleAreaHeight, width: self.view.bounds.width, height: cardHeight)
//
//        cardViewController.view.clipsToBounds = true
//
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleCardTap(recognzier:)))
//        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleCardPan(recognizer:)))
//
//        cardViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
//        cardViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
//
//
//    }
//
//    @objc
//    func handleCardTap(recognzier:UITapGestureRecognizer) {
//        switch recognzier.state {
//        case .ended:
//            animateTransitionIfNeeded(state: nextState, duration: 0.9)
//        default:
//            break
//        }
//    }
//
//    @objc
//    func handleCardPan (recognizer:UIPanGestureRecognizer) {
//        switch recognizer.state {
//        case .began:
//            startInteractiveTransition(state: nextState, duration: 0.9)
//        case .changed:
//            let translation = recognizer.translation(in: self.cardViewController.handleArea)
//            var fractionComplete = translation.y / cardHeight
//            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
//            updateInteractiveTransition(fractionCompleted: fractionComplete)
//        case .ended:
//            continueInteractiveTransition()
//        default:
//            break
//        }
//
//    }
//
//    func animateTransitionIfNeeded (state:CardState, duration:TimeInterval) {
//        if runningAnimations.isEmpty {
//            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
//                switch state {
//                case .expanded:
//                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
//                case .collapsed:
//                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight
//                }
//            }
//
//            frameAnimator.addCompletion { _ in
//                self.cardVisible = !self.cardVisible
//                self.runningAnimations.removeAll()
//            }
//
//            frameAnimator.startAnimation()
//            runningAnimations.append(frameAnimator)
//
//
//            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
//                switch state {
//                case .expanded:
//                    self.cardViewController.view.layer.cornerRadius = 12
//                case .collapsed:
//                    self.cardViewController.view.layer.cornerRadius = 0
//                }
//            }
//
//            cornerRadiusAnimator.startAnimation()
//            runningAnimations.append(cornerRadiusAnimator)
//
//            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
//                switch state {
//                case .expanded:
//                    self.visualEffectView.effect = UIBlurEffect(style: .dark)
//                case .collapsed:
//                    self.visualEffectView.effect = nil
//                }
//            }
//
//            blurAnimator.startAnimation()
//            runningAnimations.append(blurAnimator)
//
//        }
//    }
//
//    func startInteractiveTransition(state:CardState, duration:TimeInterval) {
//        if runningAnimations.isEmpty {
//            animateTransitionIfNeeded(state: state, duration: duration)
//        }
//        for animator in runningAnimations {
//            animator.pauseAnimation()
//            animationProgressWhenInterrupted = animator.fractionComplete
//        }
//    }
//
//    func updateInteractiveTransition(fractionCompleted:CGFloat) {
//        for animator in runningAnimations {
//            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
//        }
//    }
//
//    func continueInteractiveTransition (){
//        for animator in runningAnimations {
//            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
//        }
//    }
    


}

