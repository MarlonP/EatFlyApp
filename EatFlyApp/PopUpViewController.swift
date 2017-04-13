//
//  PopUpViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 30/03/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit

let myNotificationKey = "com.mp.notificationKey"

class PopUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var wholeNumbers = ["", "1", "2", "3", "4", "5"]
    var fractions = ["", "1/4", "1/3", "1/2"]
    var measurments = ["", "tablespoons","teaspoons" , "cups", "lbs"]
    var measurmentsText = ["", "tablespoons of","teaspoons of" , "cups of", "lbs of"]
    
    var amountTxt: String!
    var fraction: String!
    
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var amountTxtField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(doThisWhenNotify), name: NSNotification.Name(rawValue: myNotificationKey), object: nil)
        
        let picker: UIPickerView
        picker = UIPickerView(frame: CGRect(x: 0, y: 200, width: view.frame.width, height: 300))
        picker.backgroundColor = .white
        
        
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(PopUpViewController.amountDone))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(PopUpViewController.amountDone))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        amountTxtField.inputView = picker
        amountTxtField.inputAccessoryView = toolBar
        
    }
    
    func doThisWhenNotify() {
        
    }
    
    func amountDone() {
        
        print("Done")
        amountTxtField.resignFirstResponder()
        pickerView.isHidden = true
    }
    
    func amountCancel() {
        
        print("Done")
        amountTxtField.resignFirstResponder()
        amountTxtField.text = ""
        pickerView.isHidden = true
    }


    @IBAction func donePressed(_ sender: Any) {
        
        let item = RecipeItem()
        
        if nameTxtField.text != "" && amountTxtField.text != "" {
            item.itemName = nameTxtField.text
            item.amount = amountTxt
            
            recipe.append(item)
            fractions1.append(fraction)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: myNotificationKey), object: nil)
            
            dismiss(animated: true, completion: nil)
        } else {
            print("Error")
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 1){
            return fractions.count
        }
        
        if (component == 2){
            return measurments.count
        }
        
        return wholeNumbers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 1){
            return fractions[row]
        }
        
        if (component == 2){
            return measurments[row]
        }
        
        return wholeNumbers[row]
        
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        fraction = fractions[pickerView.selectedRow(inComponent: 1)]
        
        let pointSize: CGFloat = 14.0
        let string = "\(wholeNumbers[pickerView.selectedRow(inComponent: 0)]) \(fractions[pickerView.selectedRow(inComponent: 1)]) \(measurments[pickerView.selectedRow(inComponent: 2)])"
        
        let attribString = NSMutableAttributedString(string: string, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: pointSize), NSForegroundColorAttributeName: UIColor.black])
        attribString.addAttributes([NSFontAttributeName: UIFont.fractionFont(ofSize: pointSize)], range: (string as NSString).range(of: fraction))
        amountTxtField?.attributedText = attribString
        
        amountTxt = "\(wholeNumbers[pickerView.selectedRow(inComponent: 0)]) \(fractions[pickerView.selectedRow(inComponent: 1)]) \(measurmentsText[pickerView.selectedRow(inComponent: 2)])"
        
      
       
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        if (component == 1){
            return CGFloat(85.0)

        }
        
        if (component == 2){
            return CGFloat(200.0)

        }
        
        return CGFloat(70.0)

    }
    

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == self.amountTxtField){
            self.amountTxtField.text = ""
        }
    }
 
   

    

}
