//
//  Home.swift
//  SimpleColorPicker
//
//  Created by M H on 30/01/2022.
//

import SwiftUI

struct Home: View {
	@State private var showPicker: Bool = false
	@State private var selectedColor: Color = .white
	
    var body: some View {
		ZStack {
			
			Rectangle()
				.fill(selectedColor)
				.ignoresSafeArea()
			
			Button(action: {
				showPicker.toggle()
			}, label: {
				Text("Show Image Color Picker")
					.foregroundColor(selectedColor.isDarkColor ? .white : .black)
			}) // b
		} // z
		.imageColorPicker(showPicker: $showPicker, color: $selectedColor)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
