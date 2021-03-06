//
//  WeatherDataCodable.swift
//  WeatherApp
//
//  Created by Defalt Lee on 2022/4/14.
//

import Foundation

struct Weather: Codable {
    var records: records
}

struct records: Codable {
    var location: [location]
}

struct location: Codable {
    var locationName: String
    var weatherElement: [weatherElement]
}

struct weatherElement: Codable {
    var elementName: String
    var time: [time]
}

struct time: Codable {
    var startTime: String
    var endTime: String
    var parameter: parameter
}

struct parameter: Codable {
    var parameterName: String
    var parameterValue: String?
    var parameterUnit: String?
}
