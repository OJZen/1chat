//
//  ContentView.swift
//  1chat
//
//  Created by OJZen on 2025/2/10.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appManager: AppManager
    @Environment(\.modelContext) var modelContext
    @Environment(LLMEvaluator.self) var llm
    @State var showOnboarding = false
    @State var showSettings = false
    @State var showChats = false
    @State var currentThread: Thread?
    @FocusState var isPromptFocused: Bool

    var body: some View {
        Group {
            if appManager.userInterfaceIdiom == .pad || appManager.userInterfaceIdiom == .mac || appManager.userInterfaceIdiom == .vision {
                // iPad
                NavigationSplitView {
                    ChatsListView(currentThread: $currentThread, isPromptFocused: $isPromptFocused)
                    #if os(macOS)
                    .navigationSplitViewColumnWidth(min: 240, ideal: 240, max: 320)
                    #endif
                } detail: {
                    ChatView(currentThread: $currentThread, isPromptFocused: $isPromptFocused, showChats: $showChats, showSettings: $showSettings)
                }
            } else {
                // iPhone
                ChatView(currentThread: $currentThread, isPromptFocused: $isPromptFocused, showChats: $showChats, showSettings: $showSettings)
            }
        }
        .environmentObject(appManager)
        .environment(llm)
        .task {
            if appManager.numberOfVisits == 1 {
                showOnboarding.toggle()
            } else {
                isPromptFocused = true
            }
            // load the model
            _ = try? await llm.load()
        }
        .if(appManager.userInterfaceIdiom == .phone) { view in
            view
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if !showChats && gesture.startLocation.x < 20 && gesture.translation.width > 100 {
                                appManager.playHaptic()
                                showChats = true
                            }
                        }
                )
        }
        .sheet(isPresented: $showChats) {
            ChatsListView(currentThread: $currentThread, isPromptFocused: $isPromptFocused)
                .environmentObject(appManager)
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(currentThread: $currentThread)
                .environmentObject(appManager)
                .environment(llm)
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showOnboarding, onDismiss: dismissOnboarding) {
            OnboardingView(showOnboarding: $showOnboarding)
        }
        #if !os(visionOS)
        .tint(appManager.appTintColor.getColor())
        #endif
        .fontDesign(appManager.appFontDesign.getFontDesign())
        .environment(\.dynamicTypeSize, appManager.appFontSize.getFontSize())
        .fontWidth(appManager.appFontWidth.getFontWidth())
        .onAppear {
            appManager.incrementNumberOfVisits()
        }
    }
    
    func dismissOnboarding() {
        isPromptFocused = true
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    ContentView()
}
