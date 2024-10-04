//
//  ContentView.swift
//  moodswitch
//
//  Created by Sam Richard on 10/2/24.
//

import GameplayKit
import SpriteKit
import SwiftUI

struct ContentView: View {

    let context = MSGameContext()

    var body: some View {
        ZStack {
            SpriteView(scene: context.scene, debugOptions: [])
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .edgesIgnoringSafeArea(.all)
        }
        .statusBarHidden()
    }
}

#Preview {
    ContentView()
}

