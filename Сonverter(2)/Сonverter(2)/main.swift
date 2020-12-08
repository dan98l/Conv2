//
//  main.swift
//  Сonverter(2)
//
//  Created by Daniil G on 08.12.2020.
//  Copyright © 2020 Daniil G. All rights reserved.
//

import Foundation

enum InfoCollageData {
    static let pathFile = "/Users/daniil/Documents/Sibers/Colors.csv"
}

struct ColorGroup: Encodable {
    var title: String?
    var colors: [String]?
    var isVip: Bool?
}

var csvString: String?

do {
    csvString = try String(contentsOfFile: InfoCollageData.pathFile)
} catch {
    print(error)
}

var title: [String] = []
var isVip: [String] = []
var color: [String] = []

if let csvString = csvString {
    var rows = csvString.components(separatedBy: "\n")
    rows.remove(at: 0)
    for row in rows {
        var separatedRows: [String] = row.components(separatedBy: ["\""])
        separatedRows = separatedRows.filter(){$0 != "\r"}
        separatedRows = separatedRows.filter(){$0 != ""}
        
        if let first = separatedRows.first {
            let сomponents: [String]  = first.components(separatedBy: [","])
            title.append(сomponents[0])
            isVip.append(сomponents[2])
        }
        
        if let last = separatedRows.last {
            var separatedLast: [String] = last.components(separatedBy: ["\r"])
            separatedLast = separatedLast.filter(){$0 != ""}
            
            if last == separatedRows.first {
                let col: [String] = last.components(separatedBy: [","])
                
                if let colorLast =  col.last {
                     var colorFinish = colorLast.replacingOccurrences(of: "\r", with: "", options: NSString.CompareOptions.literal, range:nil)
                    colorFinish = colorFinish.replacingOccurrences(of: " ", with: ", ", options: NSString.CompareOptions.literal, range:nil)
                     color.append(colorFinish)
                }
            } else {
                color.append(last)
            }
        }
    }
}

var colors = [String]()
var titleTmp = title.first
var isVipTemp: Bool? = true
var indexFor = 0

var colorGroup = [ColorGroup]()

for index in 0..<title.count  {
    indexFor += 1
    if title[index] == titleTmp {
        colors.append(color[index])
    } else {
        
        if isVip[index] == "1" {
            isVipTemp = true
        } else if isVip[index] == "0" {
            isVipTemp = nil
        }
        
        colorGroup.append(ColorGroup(title: title[index-1], colors: colors, isVip: isVipTemp))
        colors = []
        colors.append(color[index])
        titleTmp = title[index]
    }
}

if isVip[indexFor-1] == "1" {
   isVipTemp = true
} else if isVip[indexFor-1] == "0" {
   isVipTemp = false
}

colorGroup.append(ColorGroup(title: title[indexFor-2], colors: colors, isVip: isVipTemp))
colors = []
colors.append(color[indexFor-1])
titleTmp = title[indexFor-1]


let encoder = PropertyListEncoder()
encoder.outputFormat = .xml

let path = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)[0].appendingPathComponent("Colors.plist")

do {
    let data = try encoder.encode(colorGroup)
    try data.write(to: path)
} catch {
    print(error)
}
