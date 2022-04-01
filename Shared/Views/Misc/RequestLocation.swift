//
//  RequestLocation.swift
//  Go London
//
//  Created by Tom Knighton on 23/03/2022.
//

import SwiftUI
import CoreLocation

struct RequestLocation: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Spacer()
            LottieView(name: "LottieLocation", loopMode: .loop)
                .frame(maxHeight: 200)
            Text("Go London needs access to your location in order to accurately provide you with the information you need to travel around London")
                .bold()
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            Button(action: askForLocation) {
                Text("Grant Access")
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .shadow(radius: 5)
            Button(action: { self.dismiss() })
            {
                Text("Not Now")
            }
            Spacer()
        }
    }

    func askForLocation() {
        print(PermissionsManager.GetStatus(of: LocationWhenInUsePermission()))
        if PermissionsManager.GetStatus(of: LocationWhenInUsePermission()) == .denied {
            if let bundleId = Bundle.main.bundleIdentifier,
               let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)")
            {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            PermissionsManager.RequestPermission(for: LocationWhenInUsePermission())
        }
    }
}

struct RequestLocation_Previews: PreviewProvider {
    static var previews: some View {
        RequestLocation()
    }
}
