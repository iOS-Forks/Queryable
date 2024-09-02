//
//  CountChecker.swift
//  AIPoem
//
//  Created by andforce on 2023/6/28.
//

import Foundation
import CommonLibs
import PayLibs

public class CountChecker {
    public static let shared = CountChecker()
    private let MAX_COUNT = 5
    
    private init() {}
    
    public func getTodayCount() -> Int {
        
        let countKey = countKey()
        
        let count = UserDefaults.standard.integer(forKey: countKey)
        
        return count
    }
    
    public func updateTodayCount() {
        let currentCount = getTodayCount()
        
        UserDefaults.standard.setValue(currentCount + 1, forKey: countKey())
    }
    
    public func isLimit() -> Bool {
        
        let hasPayed = PayManager.shared.hasPayed()
        
        if hasPayed {
            return false
        } else {
            return getTodayCount() + 1 > MAX_COUNT
        }
    }
    
    private func countKey() -> String {
        let today = InternetTimeFetcher.shared.getInternetDate() ?? Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current  // 设置目标时区为当前时区
        dateFormatter.dateFormat = "yyyy-MM-dd"  // 设置日期格式
        
        let convertedDate = dateFormatter.string(from: today)
        
        return convertedDate
    }
}
