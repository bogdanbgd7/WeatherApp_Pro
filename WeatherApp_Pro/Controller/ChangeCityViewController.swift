//
//  ChangeCityViewController.swift
//  WeatherApp_Pro
//
//  Created by Bogdan Ponocko on 09/08/2020.
//  Copyright © 2020 Bogdan Ponocko. All rights reserved.
//

import UIKit
import CoreLocation



//protocol here
protocol ChangeCityDelegate {
    func userEnteredANewCityName(city : String)
}

class ChangeCityViewController: UIViewController, UISearchBarDelegate, UITextFieldDelegate {
    
    var delegate : ChangeCityDelegate?
    let weatherDataModel = WeatherDataModel()

    var cities = ["Abc", "Bgd", "Cfggg", "Deutschland", "Estonia"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getWeatherButton.backgroundColor = .clear
        getWeatherButton.layer.cornerRadius = 11
        getWeatherButton.layer.borderWidth = 1
        getWeatherButton.layer.borderColor = UIColor.black.cgColor
        
        //search bar delegate
        searchCity.delegate? = self
        searchCity.returnKeyType = .done
        
        changeCityTextField.delegate? = self

        
    }
    
    @IBOutlet weak var getWeatherButton: UIButton!
    @IBOutlet weak var changeCityTextField: UITextField!
    @IBOutlet weak var searchCity: UISearchBar!
    
    
    @IBAction func getWeatherPressed(_ sender: Any) {
        
        let cityName = changeCityTextField.text!
        
        delegate?.userEnteredANewCityName(city: cityName)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    

}
