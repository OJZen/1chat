//
//  DeviceNotSupportedView.swift
//  1chat
//
//  Created by OJZen on 2025/2/10.
//

import SwiftUI

struct DeviceNotSupportedView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "iphone.slash")
                .font(.system(size: 64))
                .foregroundStyle(.primary, .tertiary)
            
            VStack(spacing: 4) {
                Text("device not supported")
                    .font(.title)
                    .fontWeight(.semibold)
                Text("sorry, 1chat can only run on devices that support Metal 3.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

#Preview {
    DeviceNotSupportedView()
}
