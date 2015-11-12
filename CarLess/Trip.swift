import Foundation
import CoreData
import CoreLocation

@objc(Trip)
class Trip: NSManagedObject {

    @NSManaged var distance: NSNumber
    @NSManaged var endTimestamp: NSDate?
    @NSManaged var fuelPrice: NSDecimalNumber?
    @NSManaged var fuelPriceDate: NSDate?
    @NSManaged var fuelPriceSeriesId: String?
    @NSManaged var id: String
    @NSManaged private var logTypeCode: String
    @NSManaged private var modeTypeCode: String
    @NSManaged var pending: Bool
    @NSManaged var startTimestamp: NSDate
    @NSManaged var vehicle: Vehicle?
    @NSManaged var waypoints: NSMutableSet
    
    var logType: LogType {
        get {
            return LogType(rawValue: self.logTypeCode)!
        }
        set {
            logTypeCode = newValue.rawValue
        }
    }
    
    var modeType: Mode {
        get {
            return Mode(rawValue: self.modeTypeCode)!
        }
        set {
            modeTypeCode = newValue.rawValue
        }
    }
    
    func getDistanceInUnit(unit: LengthUnit) -> Double {
        
        return distance.doubleValue * unit.conversionFactor
    }
    
    func setDistance(distance: NSNumber, hasUnitType unit: LengthUnit) {
        
        // Convert distance to meters
        self.distance = distance.doubleValue / unit.conversionFactor
    }
    
    func moneySaved() -> NSDecimalNumber? {
        
        let mpg = vehicle?.combinedMpg
        let currencyBehavior = NSDecimalNumberHandler.defaultCurrencyNumberHandler()

        if fuelPrice != nil && mpg != nil {
            if !(fuelPrice!.isEqualToNumber(NSDecimalNumber.notANumber())) {
                var value = fuelPrice!.decimalNumberByMultiplyingBy(NSDecimalNumber(double: getDistanceInUnit(LengthUnit.Mile)), withBehavior: currencyBehavior)
                value = value.decimalNumberByDividingBy(NSDecimalNumber(double: mpg!), withBehavior: currencyBehavior)
                return value
            }
        }
        return nil
    }
    
    func fuelSaved() -> Double? {
        
        if let mpg = vehicle?.combinedMpg {
            return getDistanceInUnit(LengthUnit.Mile) / mpg
        }
        return nil
    }
}
