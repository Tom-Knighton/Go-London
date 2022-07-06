//
//  GlobalViewModel.swift
//  Go London
//
//  Created by Tom Knighton on 04/06/2022.
//

import Foundation
import GoLondonSDK
import SwiftUI

@MainActor
public class GlobalViewModel {
    
    public var lradData: [StopPointAccessibility] = []
    public var lineRouteData: [LineRoutes] = []
    
    private var lineRoutesToCollect: [String] = []
    
    public static let shared = GlobalViewModel()
    
    
    //MARK: - Setup
    func setup(collectLineRoutes: [String] = GoLondon.defaultLineIds) async {
        
        self.lineRoutesToCollect = collectLineRoutes
        await setupLineRoutes()
        await setupLrad()
    }
    
    private func setupLineRoutes() async {
        let lastCachedRouteTime = await GLSDK.Meta.GetLastLineRouteModifiedTime()
        let lastCachedLocalInt = UserDefaults.standard.double(forKey: "lastCachedRoutesTime")
        let lastCachedLocal = Date(timeIntervalSince1970: lastCachedLocalInt)
        
        if lastCachedLocalInt == 0 {
            await getLineRouteData()
            return
        }
        
        if lastCachedLocalInt != 0,
           let lastCachedRouteTime,
           lastCachedRouteTime > lastCachedLocal {
            
            await self.getLineRouteData()
            return
        }
        
        if let data = UserDefaults.standard.data(forKey: "routeData"),
           let decompiled = try? JSONDecoder().decode([LineRoutes].self, from: data) {
            print("T: decompile success \(decompiled.count)")
            self.lineRouteData = decompiled
        } else {
            await self.getLineRouteData()
        }
        
    }
    
    private func setupLrad() async {
        let lastCachedAccessibility = await GLSDK.Meta.GetLastAccessibilityCacheTime()
        let lastCachedLocalInt = UserDefaults.standard.double(forKey: "lastCachedLradTime")
        let lastCachedLocal = Date(timeIntervalSince1970: lastCachedLocalInt)
        
        if lastCachedLocalInt == 0 {
            
            await getLradData()
            return
        }
        
        if lastCachedLocalInt != 0,
            let lastCachedAccessibility = lastCachedAccessibility,
            lastCachedAccessibility > lastCachedLocal {
        
            await getLradData()
            return
        }
        
        if let data = UserDefaults.standard.data(forKey: "lradData"),
           let decompiled = try? JSONDecoder().decode([StopPointAccessibility].self, from: data) {

            self.lradData = decompiled
        } else {
            
            await getLradData()
        }
    }
 
    //MARK: - Get Lines
    private func getLineRouteData() async {
        print("T: fetching from api: \(self.lineRoutesToCollect)")
        let data = await GLSDK.Lines.Routes(for: self.lineRoutesToCollect, fixCoordinates: true)
        self.lineRouteData = data
        
        let dataRepresentation = data.jsonEncode() ?? Data()
        UserDefaults.standard.set(dataRepresentation, forKey: "routeData")
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastCachedRoutesTime")
    }
    
    
    /// Returns a list of LineRoutes for the valid line ids, and saves them to cache if not already in cache
    /// - Parameter lineIds: The ids of the lines to collect routes for
    public func routesFor(_ lineIds: [String]) async -> [LineRoutes] {
        
        let linesAlreadyInCache = lineIds.allSatisfy({ lineId in
            let exists = self.lineRouteData.contains(where: { $0.lineId == lineId })
            print("T: line \(lineId) exists")
            return exists
        })
        
        // If all the lines requested already exist in cache, return the cached lines
        if linesAlreadyInCache {
            let existing = self.lineRouteData.filter { route in
                lineIds.contains(route.lineId ?? "")
            }
            print("T: Returning existingData \(existing.count)")
            return existing
        }
        
        
        var routeCache = self.lineRouteData.deepCopy()
        let existingCached = routeCache.filter { routes in lineIds.contains(where: { routes.lineId == $0 })}
        let remainingLineIds = lineIds.filter { id in existingCached.contains(where: { $0.lineId == id}) == false } // Get all remaining lineIds
        
        // For every line remaining, get the route and add to cache
        for lineId in remainingLineIds {
            if let route = await GLSDK.Lines.Routes(for: lineId, fixCoordinates: false) {
                routeCache.append(route)
            }
        }
        self.overwriteRouteData(to: routeCache)
        
        return self.lineRouteData
    }
    
    
    /// Returns the LineRoutes object for a specifed lineId, saving it in cache if not already there
    /// - Parameter lineId: The id of the line to collect routes for
    public func routesFor(_ lineId: String) async -> LineRoutes? {
        
        // If line already exists in cache, return it
        if let existingData = self.lineRouteData.first(where: { $0.lineId == lineId }) {
            print("T: Returning existingData \(existingData)")
            return existingData
        }
        
        // Otherwise, get line data from API, add to cache and return the line
        var routeCache = self.lineRouteData.deepCopy()
        if let route = await GLSDK.Lines.Routes(for: lineId, fixCoordinates: true) {
            routeCache.append(route)
            self.overwriteRouteData(to: routeCache)
            
            return route
        }
        
        return nil
    }
    
    //MARK: - Get Lrad
    private func getLradData() async {
        let data = await GLSDK.Meta.GetAccessibilityData()
        self.lradData = data
        
        let dataRepresentation = data.jsonEncode() ?? Data()
        UserDefaults.standard.set(dataRepresentation, forKey: "lradData")
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastCachedLradTime")
    }
    
    //MARK: - Update Route
    private func overwriteRouteData(to data: [LineRoutes]) {
        self.lineRouteData = data
        let dataRepresentation = data.jsonEncode() ?? Data()
        UserDefaults.standard.set(dataRepresentation, forKey: "routeData")
    }
}
