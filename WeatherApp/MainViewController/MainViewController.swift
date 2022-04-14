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
    @IBOutlet weak var checkWeatherBtn: UIButton!
    @IBOutlet weak var divisionPicker: UIPickerView!
    
    @IBOutlet weak var cons_divisionPickerBottom: NSLayoutConstraint!
    
    var safeAreaInset: UIEdgeInsets?
    
    // 行政區
    let divisions = ["基隆市","新北市","臺北市","桃園市","新竹縣","新竹市","苗栗縣","臺中市","彰化縣","南投縣","雲林縣","嘉義縣","嘉義市","臺南市","高雄市","屏東縣","宜蘭縣","花蓮縣","臺東縣","澎湖縣","金門縣","連江縣"]
    
    // 選擇的行政區
    var selectedDivision: String?

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
        }
    }
    
    func setView() {
        cons_divisionPickerBottom.constant = -divisionPicker.frame.height - safeAreaInset!.bottom
    }
    
    func setDelegate() {
        divisionPicker.delegate = self
        divisionPicker.dataSource = self
    }
    
}

extension MainViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return 22 }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { return divisions[row] }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) { selectedDivision = divisions[row] }
    
}
