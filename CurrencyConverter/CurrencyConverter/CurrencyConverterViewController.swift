//
//  CurrencyConverterViewController.swift
//  CurrencyConverter
//
//  Created by Benjamin Chris on 1/9/18.
//  Copyright © 2018 EnvisionWorld. All rights reserved.
//

import UIKit
import CHGInputAccessoryView

class CurrencyConverterViewController: UIViewController {

    @IBOutlet weak var viewIndicatorSource: UIView!
    @IBOutlet weak var viewIndicatorTarget: UIView!
    @IBOutlet weak var viewIndicatorExchangeRate: UIView!
    @IBOutlet weak var viewIndicatorAmount: UIView!
    @IBOutlet weak var buttonConvert: UIButton!
    @IBOutlet weak var textfieldSource: UITextField!
    @IBOutlet weak var textfieldTarget: UITextField!
    @IBOutlet weak var textfieldExchangeDate: UITextField!
    @IBOutlet weak var textfieldAmount: UITextField!
    @IBOutlet weak var labelResult: UILabel!
    
    @IBOutlet weak var constraintForTitleLabelTopSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintForExchangeDateTopSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintForAmountTopSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintForConvertButtonTopSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintForResultLabelTopSpace: NSLayoutConstraint!
    
    @IBOutlet weak var indicatorLoading: UIActivityIndicatorView!
    
    @IBOutlet weak var viewLoaderCover: UIView!
    
    @IBOutlet weak var labelBottom: UILabel!
    
    let exchangeDateInputPicker = UIDatePicker()
    let sourceTypeInputPicker = UIPickerView()
    let targetTypeInputPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initializeUI()
        configureInputs()
        ModelManager.manager.loadCurrencies { (succeeded, error) in
            self.viewLoaderCover.isHidden = true
            if !succeeded {
                if error != nil {
                    AppUtils.showSimpleAlertMessage(for: self, title: "Loading failed.", message: error!.localizedDescription)
                } else {
                    AppUtils.showSimpleAlertMessage(for: self, title: "Loading failed.", message: "Unexpected error!")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkOrientation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.checkOrientation()
    }

    func checkOrientation() {
        if UIDevice.current.orientation.isLandscape {
            self.labelBottom.isHidden = true
        } else {
            self.labelBottom.isHidden = false
        }
    }
    
    func initializeUI() {
        self.labelResult.text = ""
        self.buttonConvert.layer.cornerRadius = 10
        self.buttonConvert.isEnabled = false
        self.buttonConvert.backgroundColor = AppConfig.appConfigButtonDisabledColor
        self.deselectAllIndicators()
        self.indicatorLoading.stopAnimating()
        self.viewLoaderCover.isHidden = false
    }
    
    func deselectAllIndicators() {
        
        self.viewIndicatorSource.backgroundColor = AppConfig.appConfigIndicatorNormalColor
        self.viewIndicatorTarget.backgroundColor = AppConfig.appConfigIndicatorNormalColor
        self.viewIndicatorAmount.backgroundColor = AppConfig.appConfigIndicatorNormalColor
        self.viewIndicatorExchangeRate.backgroundColor = AppConfig.appConfigIndicatorNormalColor
        
    }

    @IBAction func onEditingDidBeginOnTextFields(_ sender: UITextField) {
        if sender == self.textfieldSource {
            self.viewIndicatorSource.backgroundColor = AppConfig.appConfigIndicatorSelectedColor
        } else if sender == self.textfieldTarget {
            self.viewIndicatorTarget.backgroundColor = AppConfig.appConfigIndicatorSelectedColor
        } else if sender == self.textfieldExchangeDate {
            self.viewIndicatorExchangeRate.backgroundColor = AppConfig.appConfigIndicatorSelectedColor
        } else if sender == self.textfieldAmount {
            self.viewIndicatorAmount.backgroundColor = AppConfig.appConfigIndicatorSelectedColor
            
            if self.textfieldTarget.text != "" && self.textfieldSource.text != "" && self.targetTypeInputPicker.selectedRow(inComponent: 0) == self.sourceTypeInputPicker.selectedRow(inComponent: 0) {
                AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please do not select same currenties for source and target.")
                self.textfieldSource.becomeFirstResponder()
                return
            }
        }
    }
    
    @IBAction func onEditingDidEndOnTextFields(_ sender: UITextField) {
        if sender == self.textfieldSource {
            self.viewIndicatorSource.backgroundColor = AppConfig.appConfigIndicatorNormalColor
        } else if sender == self.textfieldTarget {
            self.viewIndicatorTarget.backgroundColor = AppConfig.appConfigIndicatorNormalColor
        } else if sender == self.textfieldExchangeDate {
            self.viewIndicatorExchangeRate.backgroundColor = AppConfig.appConfigIndicatorNormalColor
        } else if sender == self.textfieldAmount {
            self.viewIndicatorAmount.backgroundColor = AppConfig.appConfigIndicatorNormalColor
        }
    }
    
    func configureInputs() {
        configureSourceTypeInput()
        configureExchangeDateInput()
        configureTargetTypeInput()
    }
    
    func configureSourceTypeInput() {
        
        self.sourceTypeInputPicker.delegate = self
        self.sourceTypeInputPicker.dataSource = self
        self.textfieldSource.inputView = self.sourceTypeInputPicker
        
        let inputAccessoryView = CHGInputAccessoryView.inputAccessoryView() as! CHGInputAccessoryView
        let nextItem = CHGInputAccessoryViewItem.button(withTitle: "Next")
        nextItem?.tag = 11
        inputAccessoryView.inputAccessoryViewDelegate = self
        inputAccessoryView.items = [CHGInputAccessoryViewItem.flexibleSpace(), nextItem!]
        self.textfieldSource.inputAccessoryView = inputAccessoryView
        
    }
    
    func configureTargetTypeInput() {
        
        self.targetTypeInputPicker.delegate = self
        self.targetTypeInputPicker.dataSource = self
        self.textfieldTarget.inputView = self.targetTypeInputPicker
        
        let inputAccessoryView = CHGInputAccessoryView.inputAccessoryView() as! CHGInputAccessoryView
        let nextItem = CHGInputAccessoryViewItem.button(withTitle: "Next")
        nextItem?.tag = 12
        inputAccessoryView.inputAccessoryViewDelegate = self
        inputAccessoryView.items = [CHGInputAccessoryViewItem.flexibleSpace(), nextItem!]
        self.textfieldTarget.inputAccessoryView = inputAccessoryView
    
    }
    
    func configureExchangeDateInput() {
        
        let inputAccessoryView = CHGInputAccessoryView.inputAccessoryView() as! CHGInputAccessoryView
        let nextItem = CHGInputAccessoryViewItem.button(withTitle: "Next")
        nextItem?.tag = 10
        inputAccessoryView.inputAccessoryViewDelegate = self
        inputAccessoryView.items = [CHGInputAccessoryViewItem.flexibleSpace(), nextItem!]
        self.textfieldExchangeDate.inputAccessoryView = inputAccessoryView
        
        self.exchangeDateInputPicker.maximumDate = Date()
        self.exchangeDateInputPicker.addTarget(self, action: #selector(onExchangeDateSelected), for: .valueChanged)
        self.exchangeDateInputPicker.datePickerMode = .date
        self.textfieldExchangeDate.inputView = exchangeDateInputPicker
    }
    
    @objc func onExchangeDateSelected(_ sender:UIDatePicker) {
        self.textfieldExchangeDate.text = sender.date.toString(format: "MMM d, yyyy")
        self.checkConvertAvailableStatus()
    }
    
    @IBAction func onEditingChangedOnAmountField(_ sender: Any) {
        self.checkConvertAvailableStatus()
    }
    
    func checkConvertAvailableStatus() {
        
        var available = true
        
        if self.textfieldSource.text == "" {
            available = false
        }
        
        if self.textfieldTarget.text == "" {
            available = false
        }
        
        if self.textfieldExchangeDate.text == "" {
            available = false
        }
        
        if self.textfieldAmount.text == "" {
            available = false
        }
        
        let amount = Double(self.textfieldAmount.text ?? "")
        if amount == nil {
            available = false
        }
        
        self.buttonConvert.isEnabled = available
        if available {
            self.buttonConvert.backgroundColor = AppConfig.appConfigIndicatorSelectedColor
        } else {
            self.buttonConvert.backgroundColor = AppConfig.appConfigButtonDisabledColor
        }
    
    }
    
    @IBAction func onConvert(_ sender: Any) {
        self.view.endEditing(true)
        self.indicatorLoading.startAnimating()
        self.view.isUserInteractionEnabled = false
        ModelManager.manager.exchange(source: self.textfieldSource.text ?? "",
                                      target: self.textfieldTarget.text ?? "",
                                      date: (self.textfieldExchangeDate.text ?? "").date(format: "MMM d, yyyy") ?? Date()) { (succeeded, rate, error) in
                                            self.view.isUserInteractionEnabled = true
                                            self.indicatorLoading.stopAnimating()
                                            if succeeded {
                                                let amount = rate * (Double(self.textfieldAmount.text ?? "0") ?? 0)
                                                self.labelResult.text = "\(self.textfieldAmount.text!) \(self.textfieldSource.text!) -> \(amount) \(self.textfieldTarget.text!) in \(self.textfieldExchangeDate.text!)"
                                            } else {
                                                if error != nil {
                                                    AppUtils.showSimpleAlertMessage(for: self, title: "Loading failed.", message: error!.localizedDescription)
                                                } else {
                                                    AppUtils.showSimpleAlertMessage(for: self, title: "Loading failed.", message: "Unexpected error!")
                                                }
                                            }
                                    }
    }
    
}

extension CurrencyConverterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ModelManager.manager.currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ModelManager.manager.currencies[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.sourceTypeInputPicker {
            self.textfieldSource.text = ModelManager.manager.currencies[self.sourceTypeInputPicker.selectedRow(inComponent: 0)]
        } else if pickerView == self.targetTypeInputPicker {
            self.textfieldTarget.text = ModelManager.manager.currencies[self.targetTypeInputPicker.selectedRow(inComponent: 0)]
        }
        self.checkConvertAvailableStatus()
    }
}

extension CurrencyConverterViewController: CHGInputAccessoryViewDelegate {
    
    func didTap(_ item: CHGInputAccessoryViewItem!) {
        if item.tag == 10 {
            self.textfieldExchangeDate.text = self.exchangeDateInputPicker.date.toString(format: "MMM d, yyyy")
            self.textfieldAmount.becomeFirstResponder()
            self.checkConvertAvailableStatus()
        } else if item.tag == 11 {
            if self.textfieldTarget.text != "" && self.targetTypeInputPicker.selectedRow(inComponent: 0) == self.sourceTypeInputPicker.selectedRow(inComponent: 0) {
                AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please do not select same currenties for source and target.")
                return
            }
            self.textfieldSource.text = ModelManager.manager.currencies[self.sourceTypeInputPicker.selectedRow(inComponent: 0)]
            self.textfieldTarget.becomeFirstResponder()
            self.checkConvertAvailableStatus()
        } else if item.tag == 12 {
            if self.textfieldSource.text != "" && self.targetTypeInputPicker.selectedRow(inComponent: 0) == self.sourceTypeInputPicker.selectedRow(inComponent: 0) {
                AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please do not select same currenties for source and target.")
                return
            }
            self.textfieldTarget.text = ModelManager.manager.currencies[self.targetTypeInputPicker.selectedRow(inComponent: 0)]
            self.textfieldExchangeDate.becomeFirstResponder()
            self.checkConvertAvailableStatus()
        }
    }
    
}

