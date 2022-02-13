//
//  CustomColorPicker.swift
//  SimpleColorPicker
//
//  Created by M H on 30/01/2022.
//

import SwiftUI
import PhotosUI

// MARK: extensions
extension View {
	func imageColorPicker(showPicker: Binding<Bool>, color: Binding<Color>) -> some View {
		return self
			.fullScreenCover(isPresented: showPicker,onDismiss: {
				
			}, content: {
				Helper(showPicker: showPicker, color: color)
				
			})
	}
}
// MARK: custom view for color picker
struct Helper: View {
	@Binding var showPicker: Bool
	@Binding var color: Color
	
	// image picker
	@State var showImagePicker: Bool = false
	@State var imageData: Data = .init(count: 0)
	
	var body: some View {
		NavigationView{
			VStack(spacing: 10) {
				// image picker view
				GeometryReader{ proxy in
					VStack(spacing: 12) {
						if let image = UIImage(data: imageData) {
							Image(uiImage: image)
								.resizable()
								.scaledToFit()
								.frame(width: proxy.size.width, height: proxy.size.height)
						} else {
							Image(systemName: "plus")
								.font(.system(size: 35))
							Text("Tap to add Image")
								.font(.system(size: 14, weight: .light))
						} // if
					} // v
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
					.contentShape(Rectangle())
					.onTapGesture {
						// show color picker
						showImagePicker.toggle()
					}
				} // gr
				ZStack(alignment: .top) {
					
					// selected color
					Rectangle()
						.fill(color)
						.frame(height: 90)
					
					// only the button from color picker
					CustomColorPicker(color: $color)
						.frame(width: 100, height: 50, alignment: .topLeading)
						.clipped()
						.offset(x: 15)
				} // z
				
			} // v
			.ignoresSafeArea(.container, edges: .bottom)
			.navigationTitle("Image Color Picker")
			.navigationBarTitleDisplayMode(.inline)
			// MARK: close button
			.toolbar(content: {
				Button("Close") {
					showPicker.toggle()
				} // b
			})
			.sheet(isPresented: $showImagePicker, onDismiss: {
				
			}, content: {
				ImagePicker(showPicker: $showImagePicker, imageData: $imageData)
			})
		} // navv
	}
}

// MARK: image picker
struct ImagePicker: UIViewControllerRepresentable {
	
	@Binding var showPicker: Bool
	@Binding var imageData: Data
	
	func makeCoordinator() -> Coordinator {
		return Coordinator(parent: self)
	}
	
	func makeUIViewController(context: Context) -> PHPickerViewController {
		var config = PHPickerConfiguration()
		config.selectionLimit = 1
		
		let picker = PHPickerViewController(configuration: config)
		picker.delegate = context.coordinator
		
		return picker
	} // f
	func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
		
	} // f
	
	// fetching selected image
	class Coordinator: NSObject, PHPickerViewControllerDelegate {
		var parent: ImagePicker
		
		init(parent: ImagePicker) {
			self.parent = parent
		}
		func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
			// image limit 1
			if let first = results.first {
				first.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: {[self] result, error in
					guard let image = result as? UIImage else {
						parent.showPicker.toggle()
						return
					}
					parent.imageData = image.jpegData(compressionQuality: 1) ?? .init(count: 0)
					
					// close picker
					parent.showPicker.toggle()
				})
			} else {
				parent.showPicker.toggle()
			}
		} // f
	} // cl
} // str

// MARK: custom color picker
struct CustomColorPicker: UIViewControllerRepresentable {
	@Binding var color: Color
	
	func makeCoordinator() -> Coordinator {
		return Coordinator(parent: self)
	}
	
	func makeUIViewController(context: Context) -> UIColorPickerViewController {
		let picker = UIColorPickerViewController()
		picker.supportsAlpha = false
		picker.selectedColor = UIColor(color)
		
		// connect delegate
		picker.delegate = context.coordinator
		
		// remove title
		picker.title = ""
		
		return picker
	} // f
	func updateUIViewController(_ uiViewController: UIColorPickerViewController, context: Context) {
		// change tint color
		uiViewController.view.tintColor = color.isDarkColor ? .white : .black
	} // f
}

// MARK: delegate methods
class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
	var parent: CustomColorPicker
	
	init(parent: CustomColorPicker) {
		self.parent = parent
	}
	
	func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
		// update color
		parent.color = Color(viewController.selectedColor)
	} // f
	
	func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
		parent.color = Color(color)
	} // f
}

// MARK: extension to find if color is dark or light
extension Color {
	var isDarkColor: Bool {
		return UIColor(self).isDarkColor
	}
}

extension UIColor {
	var isDarkColor: Bool {
		var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
		self.getRed(&r, green: &g, blue: &b, alpha: &a)
		let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
		return lum < 0.5
	}
}
