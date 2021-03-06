
import UIKit

class CaVehicleController: UIViewController {
    
    // MARK: - Properties
    
    private var _vehicle: Vehicle?
    
    var vehicle: Vehicle? {
        get {
            return _vehicle
        }
        set {
            _vehicle = newValue
        }
    }
    
    private var doneBarButton: UIBarButtonItem!
    private var cancelBarButton: UIBarButtonItem!
    private var instructionsLabel: UILabel!
    private var yearTextField: UITextField!
    private var makeTextField: UITextField!
    private var modelTextField: UITextField!
    private var optionsTextField: UITextField!
    private var combMpgValueLabel: UILabel!
    private var combMpgLabel: UILabel!
    private var yearLabel: UILabel!
    private var makeLabel: UILabel!
    private var modelLabel: UILabel!
    private var optionsLabel: UILabel!
    
    private var yearPickerView: UIPickerView!
    private var makePickerView: UIPickerView!
    private var modelPickerView: UIPickerView!
    private var optionsPickerView: UIPickerView!
    
    private var yearPickerDelegate: VehicleYearPickerDelegate!
    private var makePickerDelegate: VehicleMakePickerDelegate!
    private var modelPickerDelegate: VehicleModelPickerDelegate!
    private var optionsPickerDelegate: VehicleOptionsPickerDelegate!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setComponents()
        setConstraints()
        initializeYearPicker()
        initializeMakePicker()
        initializeModelPicker()
        initializeOptionsPicker()
        establishPickerDependencies()
        getVehicle()
        setMpgDisplayForVehicle(vehicle)
    }
    
    override func viewDidAppear(animated: Bool) {

        if !CaNetworkManager.isNetworkConnected() {
            doneBarButton.enabled = false
            view.userInteractionEnabled = false
            view.alpha = 0.65
        } else {
            doneBarButton.enabled = true
            view.userInteractionEnabled = true
            view.alpha = 1.0
        }
    }
    
    private func getVehicle() {
        
        vehicle = CaDataManager.instance.defaultVehicle
        if vehicle == nil {
            yearPickerDelegate.load()
        } else {
            yearPickerDelegate.load(selectYear: vehicle!.year)
            makePickerDelegate.load(year: vehicle!.year, selectMake: vehicle!.make)
            modelPickerDelegate.load(year: vehicle!.year, make: vehicle!.make, selectModel: vehicle!.model)
            optionsPickerDelegate.load(year: vehicle!.year, make: vehicle!.make, model: vehicle!.model, selectOption: vehicle!.epaVehicleId)
        }
    }
    
    func setMpgDisplayForVehicle(vehicle: Mpg?) {
        
        if vehicle?.combinedMpg == nil {
            combMpgLabel.hidden = true
            combMpgValueLabel.hidden = true
        } else {
            combMpgLabel.hidden = false
            combMpgValueLabel.hidden = false
            combMpgValueLabel.text = "\(vehicle!.combinedMpg!)"
        }
    }
    
    // MARK: - Picker Initializations
    
    private func establishPickerDependencies() {
        
        optionsPickerDelegate.parentComponent = modelPickerDelegate
        modelPickerDelegate.parentComponent = makePickerDelegate
        makePickerDelegate.parentComponent = yearPickerDelegate
    }
    
    private func initializeYearPicker() {
        
        yearPickerView = UIPickerView()
        yearPickerDelegate = VehicleYearPickerDelegate(pickerView: yearPickerView, textField: yearTextField, label: yearLabel)
        
        yearPickerView.dataSource = yearPickerDelegate
        yearPickerView.delegate = yearPickerDelegate
        
        let toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.Default
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: yearPickerDelegate, action: Selector("done"))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: yearPickerDelegate, action: Selector("cancel"))
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolbar.userInteractionEnabled = true
        
        yearTextField.inputView = yearPickerView
        yearTextField.inputAccessoryView = toolbar
    }
    
    private func initializeMakePicker() {
        
        makePickerView = UIPickerView()
        makePickerDelegate = VehicleMakePickerDelegate(pickerView: makePickerView, textField: makeTextField, label: makeLabel)
        
        makePickerView.dataSource = makePickerDelegate
        makePickerView.delegate = makePickerDelegate
        
        let toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.Default
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: makePickerDelegate, action: Selector("done"))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: makePickerDelegate, action: Selector("cancel"))
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolbar.userInteractionEnabled = true
        
        makeTextField.inputView = makePickerView
        makeTextField.inputAccessoryView = toolbar
    }
    
    private func initializeModelPicker() {
        
        modelPickerView = UIPickerView()
        modelPickerDelegate = VehicleModelPickerDelegate(pickerView: modelPickerView, textField: modelTextField, label: modelLabel)
        
        modelPickerView.dataSource = modelPickerDelegate
        modelPickerView.delegate = modelPickerDelegate
        
        let toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.Default
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: modelPickerDelegate, action: Selector("done"))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: modelPickerDelegate, action: Selector("cancel"))
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolbar.userInteractionEnabled = true
        
        modelTextField.inputView = modelPickerView
        modelTextField.inputAccessoryView = toolbar
    }
    
    private func initializeOptionsPicker() {
        
        optionsPickerView = UIPickerView()
        optionsPickerDelegate = VehicleOptionsPickerDelegate(pickerView: optionsPickerView, textField: optionsTextField, label: optionsLabel, viewController: self)
        
        optionsPickerView.dataSource = optionsPickerDelegate
        optionsPickerView.delegate = optionsPickerDelegate
        
        let toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.Default
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: optionsPickerDelegate, action: Selector("done"))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: optionsPickerDelegate, action: Selector("cancel"))
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolbar.userInteractionEnabled = true
        
        optionsTextField.inputView = optionsPickerView
        optionsTextField.inputAccessoryView = toolbar
    }
    
    // MARK: - Actions
    
    func save() {
        
        let selectedOptions = optionsPickerDelegate.selectedItem
        let epaVehicle = self.optionsPickerDelegate.vehicle

        // No changes made; don't save
        if selectedOptions?.value == vehicle?.epaVehicleId {
            exit()
        }
        
        if selectedOptions == nil || epaVehicle == nil {
            NSLog("Vehicle did not pass validation; cannot save it. selectedOptions = \(selectedOptions), epaVehicle = \(epaVehicle)")
            return
        }
        
        let defaultVehicleReferenceCount = CaDataManager.instance.countTripsUsedByVehicle(vehicle)
        if vehicle == nil || defaultVehicleReferenceCount > 0 {
            // If the default vehicle does not already exist then create it with
            // the scene's settings. Or, if the default vehicle does exist and it
            // is being referenced by trips then create a new vehicle instance
            // and set this new instance as the default vehicle.
            vehicle = CaDataManager.instance.initVehicle()
            epaVehicle!.setPropertiesForVehicle(vehicle!)
            CaDataManager.instance.save(vehicle: vehicle!)
            CaDataManager.instance.saveDefaultSetting(vehicle: vehicle)
        } else {
            // Update the current default vehicle with the new values. We can do
            // this because it is not yet being referenced by any trips.
            epaVehicle!.setPropertiesForVehicle(vehicle!)
            CaDataManager.instance.save(vehicle: vehicle!)
        }
        exit()
    }
    
    func cancel() {
        
        yearPickerDelegate.reset()
        exit()
    }
    
    private func exit() {
        performSegueWithIdentifier(CaSegue.VehicleToSettings, sender: self)
    }
    
    // MARK: - View Construction
    
    private func setComponents() {
        
        view.backgroundColor = CaStyle.ViewBgColor
        navigationController?.navigationBar.barTintColor = CaStyle.NavBarBgTintColor
        navigationController?.navigationBar.tintColor = CaStyle.NavBarTintColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: CaStyle.NavBarTitleColor]
        
        navigationItem.title = "Vehicle"
        
        doneBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "save")
        navigationItem.rightBarButtonItem = doneBarButton
        
        cancelBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel")
        navigationItem.leftBarButtonItem = cancelBarButton
        
        instructionsLabel = UILabel()
        instructionsLabel.font = CaStyle.InstructionHeadlineFont
        instructionsLabel.text = "Select the vehicle that your carless trips replace"
        instructionsLabel.textColor = CaStyle.InstructionHeadlineColor
        instructionsLabel.textAlignment = NSTextAlignment.Left
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsLabel.numberOfLines = 0
        view.addSubview(instructionsLabel)
        
        yearLabel = UILabel()
        yearLabel.font = CaStyle.InputLabelFont
        yearLabel.hidden = true
        yearLabel.text = "Year"
        yearLabel.textColor = CaStyle.InputLabelColor
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(yearLabel)
        
        yearTextField = UITextField()
        yearTextField.adjustsFontSizeToFitWidth = true
        yearTextField.borderStyle = UITextBorderStyle.None
        yearTextField.font = CaStyle.InputFieldFont
        yearTextField.minimumFontSize = CaStyle.InputFieldFontMinimumScaleFactor
        yearTextField.placeholder = "Year"
        yearTextField.textColor = CaStyle.InputFieldColor
        yearTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(yearTextField)
        
        makeLabel = UILabel()
        makeLabel.font = CaStyle.InputLabelFont
        makeLabel.hidden = true
        makeLabel.text = "Make"
        makeLabel.textColor = CaStyle.InputLabelColor
        makeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(makeLabel)
        
        makeTextField = UITextField()
        makeTextField.adjustsFontSizeToFitWidth = true
        makeTextField.borderStyle = UITextBorderStyle.None
        makeTextField.font = CaStyle.InputFieldFont
        makeTextField.minimumFontSize = CaStyle.InputFieldFontMinimumScaleFactor
        makeTextField.placeholder = "Make"
        makeTextField.textColor = CaStyle.InputFieldColor
        makeTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(makeTextField)
        
        modelLabel = UILabel()
        modelLabel.font = CaStyle.InputLabelFont
        modelLabel.hidden = true
        modelLabel.text = "Model"
        modelLabel.textColor = CaStyle.InputLabelColor
        modelLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(modelLabel)
        
        modelTextField = UITextField()
        modelTextField.adjustsFontSizeToFitWidth = true
        modelTextField.borderStyle = UITextBorderStyle.None
        modelTextField.font = CaStyle.InputFieldFont
        modelTextField.minimumFontSize = CaStyle.InputFieldFontMinimumScaleFactor
        modelTextField.placeholder = "Model"
        modelTextField.textColor = CaStyle.InputFieldColor
        modelTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(modelTextField)
        
        optionsLabel = UILabel()
        optionsLabel.font = CaStyle.InputLabelFont
        optionsLabel.hidden = true
        optionsLabel.text = "Options"
        optionsLabel.textColor = CaStyle.InputLabelColor
        optionsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(optionsLabel)
        
        optionsTextField = UITextField()
        optionsTextField.adjustsFontSizeToFitWidth = true
        optionsTextField.borderStyle = UITextBorderStyle.None
        optionsTextField.font = CaStyle.InputFieldFont
        optionsTextField.minimumFontSize = CaStyle.InputFieldFontMinimumScaleFactor
        optionsTextField.placeholder = "Options"
        optionsTextField.textColor = CaStyle.InputFieldColor
        optionsTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(optionsTextField)
        
        combMpgLabel = UILabel()
        combMpgLabel.font = CaStyle.MpgLabelFont
        combMpgLabel.text = "combined mpg"
        combMpgLabel.textColor = CaStyle.MpgLabelColor
        combMpgLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(combMpgLabel)
        
        combMpgValueLabel = UILabel()
        combMpgValueLabel.font = CaStyle.MpgValueFont
        combMpgValueLabel.translatesAutoresizingMaskIntoConstraints = false
        combMpgValueLabel.textColor = CaStyle.MpgValueColor
        view.addSubview(combMpgValueLabel)
        
    }
    
    private func setConstraints() {
        
        view.addConstraint(NSLayoutConstraint(item: instructionsLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.topLayoutGuide, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 20.0))
        view.addConstraint(NSLayoutConstraint(item: instructionsLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 20.0))
        view.addConstraint(NSLayoutConstraint(item: instructionsLabel, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -20.0))

        
        view.addConstraint(NSLayoutConstraint(item: yearLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: instructionsLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 20.0))
        view.addConstraint(NSLayoutConstraint(item: yearLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 20.0))
        view.addConstraint(NSLayoutConstraint(item: yearLabel, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -20.0))
        
        view.addConstraint(NSLayoutConstraint(item: yearTextField, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: yearLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: CaStyle.InputGroupLvVerticlePadding))
        view.addConstraint(NSLayoutConstraint(item: yearTextField, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 20.0))
        view.addConstraint(NSLayoutConstraint(item: yearTextField, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -20.0))
        
        view.addConstraint(NSLayoutConstraint(item: makeLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: yearTextField, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: CaStyle.InputGroupVerticlePadding))
        view.addConstraint(NSLayoutConstraint(item: makeLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 20.0))
        view.addConstraint(NSLayoutConstraint(item: makeLabel, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -20.0))
        
        view.addConstraint(NSLayoutConstraint(item: makeTextField, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: makeLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: CaStyle.InputGroupLvVerticlePadding))
        view.addConstraint(NSLayoutConstraint(item: makeTextField, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 20.0))
        view.addConstraint(NSLayoutConstraint(item: makeTextField, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -20.0))
        
        view.addConstraint(NSLayoutConstraint(item: modelLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: makeTextField, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: CaStyle.InputGroupVerticlePadding))
        view.addConstraint(NSLayoutConstraint(item: modelLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 20.0))
        view.addConstraint(NSLayoutConstraint(item: modelLabel, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -20.0))
        
        view.addConstraint(NSLayoutConstraint(item: modelTextField, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: modelLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: CaStyle.InputGroupLvVerticlePadding))
        view.addConstraint(NSLayoutConstraint(item: modelTextField, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 20.0))
        view.addConstraint(NSLayoutConstraint(item: modelTextField, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -20.0))
        
        view.addConstraint(NSLayoutConstraint(item: optionsLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: modelTextField, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: CaStyle.InputGroupVerticlePadding))
        view.addConstraint(NSLayoutConstraint(item: optionsLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 20.0))
        view.addConstraint(NSLayoutConstraint(item: optionsLabel, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -20.0))
        
        view.addConstraint(NSLayoutConstraint(item: optionsTextField, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: optionsLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: CaStyle.InputGroupLvVerticlePadding))
        view.addConstraint(NSLayoutConstraint(item: optionsTextField, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 20.0))
        view.addConstraint(NSLayoutConstraint(item: optionsTextField, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -20.0))
        
        view.addConstraint(NSLayoutConstraint(item: combMpgValueLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: optionsTextField, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: CaStyle.InputGroupVerticlePadding))
        view.addConstraint(NSLayoutConstraint(item: combMpgValueLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 20.0))
        view.addConstraint(NSLayoutConstraint(item: combMpgValueLabel, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -20.0))
        
        view.addConstraint(NSLayoutConstraint(item: combMpgLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: combMpgValueLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 1.0))
        view.addConstraint(NSLayoutConstraint(item: combMpgLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 20.0))
        view.addConstraint(NSLayoutConstraint(item: combMpgLabel, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -20.0))
        
        
    }
   
}
