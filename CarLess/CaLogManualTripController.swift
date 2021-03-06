import UIKit
import CoreData

class CaLogManualTripController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: - UI Properties
    
    private var scrollView: UIScrollView!
    private var logEntryView: CaLogManualTripView!
    private var datePicker: UIDatePicker!
    private var modePicker: UIPickerView!
    private var categoryPicker: UIPickerView!
    private var spinnerView: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    private var categoryData: [Category?] = []
    private var distance: NSNumber? {
        get {
            if logEntryView.distanceTextField.text != nil {
                if let tempDistance = CaFormatter.distance.numberFromString(logEntryView.distanceTextField.text!) {
                    return tempDistance
                }
            }
            return nil
        }
    }
    
    private var mode: Mode? {
        get {
            if lastSelectedModeIndex >= 0 && lastSelectedModeIndex < Mode.allValues.count {
                return Mode.allValues[lastSelectedModeIndex]
            }
            return nil
        }
    }
    
    private var category: Category? {
        get {
            if lastSelectedCategoryIndex > 0 && lastSelectedCategoryIndex < categoryData.count {
                return categoryData[lastSelectedCategoryIndex]
            }
            return nil
        }
    }
    
    private var activeTextField: UITextField?
 
    private var trip: Trip?
    private var lastSelectedModeIndex = 0
    private var lastSelectedCategoryIndex = 0
    
    private struct Tag {
        static let DistanceField = 200
        static let ModePicker = 300
        static let CategoryPicker = 400
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logEntryView = CaLogManualTripView()
        
        scrollView = UIScrollView()
        scrollView.addSubview(logEntryView)
        view.addSubview(scrollView)
        
        logEntryView.saveButton.addTarget(self, action: "save", forControlEvents: UIControlEvents.TouchUpInside)
        
        spinnerView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        spinnerView.color = CaStyle.ActivitySpinnerColor
        spinnerView.hidesWhenStopped = true
        spinnerView.center = view.center
        view.addSubview(spinnerView)
        
        // Initialize category data; the first item is nil
        //
        categoryData.append(nil)
        for cat in Category.allValues {
            categoryData.append(cat)
        }
        
        // Dismiss the keyboard on view tap 
        //
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        logEntryView.addGestureRecognizer(tap)
        
        logEntryView.distanceTextField.tag = Tag.DistanceField
        
        datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.DateAndTime
        logEntryView.timestampTextField.inputView = datePicker
        datePicker.addTarget(self, action: "datePickerValueChanged", forControlEvents: UIControlEvents.ValueChanged)
        
        modePicker = UIPickerView()
        modePicker.dataSource = self
        modePicker.delegate = self
        modePicker.tag = Tag.ModePicker
        logEntryView.modeTextField.inputView = modePicker
        
        categoryPicker = UIPickerView()
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        categoryPicker.tag = Tag.CategoryPicker
        logEntryView.categoryTextField.inputView = categoryPicker
        
        // Set the text field delegates to self so that the view knows to where to
        // scroll so that the active text field is not covered when a keyboard
        // appears on the screen.
        //
        logEntryView.distanceTextField.delegate = self
        logEntryView.timestampTextField.delegate = self
        logEntryView.modeTextField.delegate = self
        logEntryView.categoryTextField.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        reset()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unregisterFromKeyboardNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logEntryView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - topLayoutGuide.length - bottomLayoutGuide.length)
        scrollView.frame = logEntryView.frame
        scrollView.contentSize = logEntryView.frame.size
    }
    
    // MARK: - View Actions
    
    func save() {

        if validate() {
            let trip = createTrip()
            preSave()
            let onFuelPriceFindSuccess = {(fuelPrice: EiaWeeklyFuelPrice) -> Void in
                trip.fuelPrice = fuelPrice.price
                trip.fuelPriceDate = fuelPrice.startDate
                trip.fuelPriceSeriesId = fuelPrice.seriesId
                CaDataManager.instance.save(trip: trip)
                self.trip = trip
                self.postSave()
            }
            let onFuelPriceFindError = {() -> Void in
                CaDataManager.instance.save(trip: trip)
                self.trip = trip
                self.postSave()
            }
            FuelPriceFinder.instance.fuelPrice(forDate: trip.startTimestamp, onSuccess: onFuelPriceFindSuccess, onError: onFuelPriceFindError)
       }
    }
    
    private func validate() -> Bool {

        return distance?.doubleValue > 0.0 && mode != nil
    }
    
    private func preSave() {
        
        view.alpha = CaConstants.SaveDisplayAlpha
        logEntryView.saveButton.enabled = false
        spinnerView.startAnimating()
    }
    
    private func postSave() {
        
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(CaConstants.SaveActivityDelay))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.spinnerView.stopAnimating()
            self.logEntryView.saveButton.enabled = true
            self.view.alpha = 1.0
            self.performSegueWithIdentifier(CaSegue.LogManualTripHomeToSummary, sender: self)
       }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == CaSegue.LogManualTripHomeToSummary {
            let vc = segue.destinationViewController as! LogManualTripSummaryController
            vc.trip = self.trip
        }
    }
    
    // MARK:- Helpers
    
    private func createTrip() -> Trip {
    
        let trip = CaDataManager.instance.initTrip()
        
        if let tempDistance = distance {
            trip.setDistance(tempDistance, hasUnitType: CaDataManager.instance.defaultDistanceUnit)
        } else {
            trip.setDistance(0.0, hasUnitType: CaDataManager.instance.defaultDistanceUnit)
        }
        trip.categoryType = category
        trip.logType = LogType.Manual
        trip.modeType = mode!
        trip.pending = false
        trip.startTimestamp = datePicker.date
        trip.endTimestamp = nil
        
        return trip
    }
    
    func reset() {
        
        trip = nil
        
        datePicker.date = NSDate()
        datePicker.maximumDate = datePicker.date.addDays(1)
        datePickerValueChanged()
        
        logEntryView.distanceTextField.text = nil
        logEntryView.distanceTextField.placeholder = "0.0 \(CaDataManager.instance.defaultDistanceUnit.rawValue.lowercaseString)s"
        
        lastSelectedModeIndex = 0
        logEntryView.modeTextField.text = Mode.allValues[lastSelectedModeIndex].description
        modePicker.selectRow(lastSelectedModeIndex, inComponent: 0, animated: false)
        
        lastSelectedCategoryIndex = 0
        logEntryView.categoryTextField.text = categoryData[lastSelectedCategoryIndex]?.description
        categoryPicker.selectRow(lastSelectedCategoryIndex, inComponent: 0, animated: false)
        
    }
    
    @IBAction
    func returnToManualLogEntryHome(segue: UIStoryboardSegue) {
        
        reset()
    }
    
    func datePickerValueChanged() {
        
        logEntryView.timestampTextField.text = CaFormatter.timestamp.stringFromDate(datePicker.date)
    }
    
    
    // MARK: - UIPicker DataSource Methods
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return pickerView.tag == Tag.ModePicker ?
            Mode.allValues.count : categoryData.count
    }
    
    // MARK: - UIPicker Delegate Methods
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pickerView.tag == Tag.ModePicker ?
            Mode.allValues[row].description :
            categoryData[row]?.description
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == Tag.ModePicker {
            logEntryView.modeTextField.text = Mode.allValues[row].description
            lastSelectedModeIndex = row
            
        } else {
            logEntryView.categoryTextField.text = categoryData[row]?.description
            lastSelectedCategoryIndex = row
        }
    }
    
    // MARK: - UITextField Delegate Methods
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
 
        if textField.tag == Tag.DistanceField {
            let textFieldText = textField.text == nil ? "" : textField.text!
            return CaFormatter.distance.numberFromString("\(textFieldText)\(string)") != nil
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeTextField = nil
    }
    
    // MARK: - Keyboard
    
    func registerForKeyboardNotifications() {
        
        let center:  NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unregisterFromKeyboardNotifications() {
        
        let center:  NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        center.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info.objectForKey(UIKeyboardFrameBeginUserInfoKey)?.CGRectValue as CGRect!).size
        
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = contentInsets;
        
        var tempRect = self.view.frame
        tempRect.size.height -= keyboardSize.height;
        if activeTextField != nil {
            let containsPoint = CGRectContainsPoint(tempRect, activeTextField!.frame.origin)
            if !containsPoint {
                scrollView.scrollRectToVisible(activeTextField!.frame, animated: true)
            }
        }
    }

    func keyboardWillBeHidden(notification: NSNotification) {
        
        let contentInsets = UIEdgeInsets(top: topLayoutGuide.length, left: 0.0, bottom: bottomLayoutGuide.length, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
        activeTextField?.resignFirstResponder()
    }

}
