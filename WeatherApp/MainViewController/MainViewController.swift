//
//  MainViewController.swift
//  WeatherApp
//
//  Created by Defalt Lee on 2022/4/14.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var divisionLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var comfortableLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var rainfallLabel: UILabel!
    @IBOutlet weak var checkWeatherBtn: UIButton!
    @IBOutlet weak var divisionPicker: UIPickerView!
    
    @IBOutlet weak var cons_divisionPickerBottom: NSLayoutConstraint!
    
    var safeAreaInset: UIEdgeInsets?
    
    // 行政區
    let divisions = ["基隆市","新北市","臺北市",
                     "桃園市","新竹縣","新竹市","苗栗縣",
                     "臺中市","彰化縣","南投縣",
                     "雲林縣","嘉義縣","嘉義市","臺南市",
                     "高雄市","屏東縣",
                     "宜蘭縣","花蓮縣","臺東縣",
                     "澎湖縣","金門縣","連江縣"]
    
    // 選擇的行政區
    var selectedDivision: String = "基隆市"

    override func viewDidLoad() {
        super.viewDidLoad()
        safeAreaInset = UIApplication.shared.windows.first?.safeAreaInsets
        
        setView()
        setDelegate()
    }

    @IBAction func checkWeatherBtnClick(_ sender: UIButton) {
        if cons_divisionPickerBottom.constant == -divisionPicker.frame.height - safeAreaInset!.bottom {
            UIView.animate(withDuration: 1) { [self] in
                cons_divisionPickerBottom.constant = 0
                self.view.layoutIfNeeded()
            }
        } else {
            getWeatherData { error in print(error as Any) }
        }
    }
    
    func setView() {
        cons_divisionPickerBottom.constant = -divisionPicker.frame.height - safeAreaInset!.bottom
        
        divisionLabel.text = "天氣預報"
        weatherLabel.text = ""
        comfortableLabel.text = ""
        temperatureLabel.text = ""
        rainfallLabel.text = ""
    }
    
    func setDelegate() {
        divisionPicker.delegate = self
        divisionPicker.dataSource = self
    }
    
    func getWeatherData(completion: @escaping((String?) -> Void)) {
        divisionLabel.text = divisions[self.divisionPicker.selectedRow(inComponent: 0)]
        
        var Wx:     String = ""
        var MinT:   String = ""
        var MaxT:   String = ""
        var CI:     String = ""
        var PoP:    String = ""
        
        var request = URLRequest(url: URL(string: "https://opendata.cwb.gov.tw/api/v1/rest/datastore/F-C0032-001?Authorization=CWB-F833BDA4-8A19-4626-9A1D-1806F412FF3C&format=JSON&elementName=&sort=time&startTime=")!,timeoutInterval: Double.infinity)
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { [self] (getData, respond, error) in
            let decoder = JSONDecoder() // 建立 Json 格式的 Decoder
            if let weatherData = getData, let weather = try? decoder.decode(Weather.self, from: weatherData) {
                weather.records.location.forEach({ (location) in
                    guard location.locationName == self.selectedDivision else { return }
                    print(location.locationName)
                    location.weatherElement.forEach { (weatherElement) in
                        let data = weatherElement.time[2].parameter
                        
                        switch weatherElement.elementName {
                        case "Wx":
                            Wx = "\(data.parameterName)\(data.parameterUnit ?? "")"
                        case "MaxT":
                            MaxT = "\(data.parameterName) °C"
                        case "MinT":
                            MinT = "\(data.parameterName) °C"
                        case "CI":
                            CI = "\(data.parameterName)\(data.parameterUnit ?? "")"
                        case "PoP":
                            PoP = "\(data.parameterName) %"
                        default: break
                        }
                    }
                })
                
                DispatchQueue.main.async { [self] in
                    weatherLabel.text = Wx
                    temperatureLabel.text = "\(MinT) ~ \(MaxT)"
                    comfortableLabel.text = CI
                    rainfallLabel.text = PoP
                }
                    
                completion(nil)
            } else {
                completion("error")
            }
        }
        task.resume()
    }
    
}

extension MainViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return 22 }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { return divisions[row] }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) { selectedDivision = divisions[row] }
    
}
