//
//  Picker.swift
//  SmartCar
//
//  Created by Robert Smith on 4/27/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import SwiftUI
import CANHack

class PickerObject: NSObject, ObservableObject, UIDocumentPickerDelegate {
    @Published var chosenSet: SignalSet<Message>?
    
    private var picker: UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.plain-text"], in: .import)
        picker.allowsMultipleSelection = false
        
        picker.delegate = self
        return picker
    }
    
    @Published var isPresented: Bool = false {
        didSet {
            if isPresented && rootVC.presentedViewController == nil {
                rootVC.present(picker, animated: true, completion: nil)
            } else if !isPresented && rootVC.presentedViewController != nil {
                rootVC.dismiss(animated: true)
            }
        }
    }
    var rootVC: UIViewController
        
    internal init(rootVC: UIViewController) {
        self.rootVC = rootVC
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        
        chosenSet = GVRetParser().parse(from: url)

    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        isPresented = false
    }
}

struct Picker: UIViewControllerRepresentable {
    @Binding var chosenSet: SignalSet<Message>?
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.plain-text"], in: .import)
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> PickerCoordinator {
        PickerCoordinator(picker: self)
    }
    
    class PickerCoordinator: NSObject, UIDocumentPickerDelegate {
        internal init(picker: Picker) {
            self.picker = picker
        }
        
        var picker: Picker
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            picker.chosenSet = GVRetParser().parse(from: url)
        }
    }
}


struct Picker_Previews: PreviewProvider {
    static var previews: some View {
//        Picker()
        EmptyView()
    }
}
