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
    let divisions = ["基隆市","新北市","臺北市","桃園市","新竹縣","新竹市","苗栗縣","臺中市","彰化縣","南投縣","雲林縣","嘉義縣","嘉義市","臺南市","高雄市","屏東縣","宜蘭縣","花蓮縣","臺東縣","澎湖縣","金門縣","連江縣"]
    
    // 選擇的行政區
    var selectedDivision: String = "基隆市"

    override func viewDidLoad() {
        super.viewDidLoad()
        safeAreaInset = UIApplication.shared.windows.first?.safeAreaInsets
        // Do any additional setup after loading the view.
        
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
            getWeatherData { error in print(error) }
        }
    }
    
    func setView() {
        cons_divisionPickerBottom.constant = -divisionPicker.frame.height - safeAreaInset!.bottom
    }
    
    func setDelegate() {
        divisionPicker.delegate = self
        divisionPicker.dataSource = self
    }
    
    func getWeatherData(completion: @escaping((String?) -> Void)) {
        divisionLabel.text = divisions[self.divisionPicker.selectedRow(inComponent: 0)]
        
        var lowTempString: String?
        var highTempString: String?
        
        // 建立 URLRequest
        var request = URLRequest(url: URL(string: "https://opendata.cwb.gov.tw/api/v1/rest/datastore/F-C0032-001?Authorization=CWB-F833BDA4-8A19-4626-9A1D-1806F412FF3C&format=JSON&elementName=&sort=time&startTime=")!,timeoutInterval: Double.infinity)
        
        // API 請求方式
        request.httpMethod = "GET"
        
        // API 會自動切到副執行緒
        let task = URLSession.shared.dataTask(with: request) { [self] (getData, respond, error) in
            let decoder = JSONDecoder() // 建立 Json 格式的 Decoder
            if let weatherData = getData, let weather = try? decoder.decode(Weather.self, from: weatherData) {
                weather.records.location.forEach({ (location) in
                    guard location.locationName == self.selectedDivision else { return }
                    print(location.locationName)
                    location.weatherElement.forEach { (weatherElement) in
                        let data = weatherElement.time[2].parameter
                        switch weatherElement.elementName {
                        case "Wx": print("  天氣現象")
                            DispatchQueue.main.async {
                                self.weatherLabel.text = "\(data.parameterName)\(data.parameterUnit ?? "")"
                            }
                        case "MaxT": print("  最高溫")
                            highTempString = "\(data.parameterName) °C"
                        case "MinT": print("  最低溫")
                            lowTempString = "\(data.parameterName) °C"
                        case "CI": print("  舒適度")
                            DispatchQueue.main.async {
                                self.comfortableLabel.text = "\(data.parameterName)\(data.parameterUnit ?? "")"
                            }
                        case "PoP": print("  降雨機率")
                            DispatchQueue.main.async {
                                self.rainfallLabel.text = "\(data.parameterName) %"
                            }
                        default: break
                        }
                        
                        /*
                        weatherElement.time.forEach { (time) in
                            print("    \(time.startTime) ~ \(time.endTime)")
                            print("    \(time.parameter.parameterName)\(time.parameter.parameterUnit ?? "")")
                        }
                        */
                    }
                })
                
                DispatchQueue.main.async { [self] in
                    temperatureLabel.text = "\(lowTempString!) ~ \(highTempString!)"
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
