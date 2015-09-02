import Foundation
import CoreGraphics
import UIKit

struct CaSegue {
    
    static let TrackedHomeToProgress = "TrackedHomeToProgressSegue"
    static let TrackedProgressToSummary = "TrackedProgressToSummarySegue"
    static let TrackedSummaryToHome = "TrackedSummaryToHomeSegue"
}

struct CaConstants {
    
    static let SaveActivityDelay = 3.0 * Double(NSEC_PER_SEC)
    static let SaveDisplayAlpha: CGFloat = 0.5
}

struct CaColor {

    // Hex 3B3833
    static let FadedSlateGray = UIColor(red: 59.0/255.0, green: 56.0/255.0, blue: 51.0/255.0, alpha: 1.0)

    // Hex E9BC1B
    static let Mustard = UIColor(red: 233.0/255.0, green: 188.0/255.0, blue: 27.0/255.0, alpha: 1.0)

    // Hex F5EACD
    static let Ivory = UIColor(red: 245.0/255.0, green: 234.0/255.0, blue: 205.0/255.0, alpha: 1.0)
   
    // Hex EE4B3E
    static let RedOrange = UIColor(red: 238.0/255.0, green: 75.0/255.0, blue: 62.0/255.0, alpha: 1.0)
    
    // Hex 096EA0
    static let LightBlue = UIColor(red: 9.0/255.0, green: 110.0/255.0, blue: 160.0/255.0, alpha: 1.0)

    // Hex 1F784F
    static let HunterGreen = UIColor(red: 31.0/255.0, green: 120.0/255.0, blue: 79.0/255.0, alpha: 1.0)

}

struct CaStyle {
    
    static let ButtonWidth: CGFloat = 110.0
    static let ButtonHeight: CGFloat = 36.0
    static let ButtonBorderWidth: CGFloat = 0.0
}

struct CaLogStyle {
    
    
    static let SegmentBarBgColor = CaColor.Mustard
    static let SegmentControlColor = CaColor.FadedSlateGray
    static let ViewBgColor = CaColor.Ivory
    static let ViewLabelColor = CaColor.FadedSlateGray
    static let ViewFieldColor = UIColor.blackColor()
    static let ActivitySpinnerColor = CaColor.RedOrange
    static let StartButtonColor = UIColor.whiteColor()
    static let StartButtonBgColor = CaColor.HunterGreen
    static let StartButtonBorderColor = CaColor.FadedSlateGray
    static let StopButtonColor = UIColor.whiteColor()
    static let StopButtonBgColor = CaColor.RedOrange
    static let StopButtonBorderColor = CaColor.FadedSlateGray
    static let SaveButtonColor = UIColor.whiteColor()
    static let SaveButtonBgColor = CaColor.LightBlue
    static let SaveButtonBorderColor = CaColor.LightBlue
    static let DiscardButtonColor = UIColor.whiteColor()
    static let DiscardButtonBgColor = CaColor.FadedSlateGray
    static let DiscardButtonBorderColor = CaColor.FadedSlateGray
   
}

class CaComponent {
    
    static func createButton(#title: String, color: UIColor, bgColor: UIColor, borderColor: UIColor) -> UIButton {
    
        var button = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setTitle(title, forState: UIControlState.Normal)
        button.setTitleColor(color, forState: UIControlState.Normal)
        button.layer.backgroundColor = bgColor.CGColor
        button.layer.borderColor = borderColor.CGColor
        button.layer.cornerRadius = CaStyle.ButtonHeight/2.0
        button.layer.borderWidth = CaStyle.ButtonBorderWidth
        return button
    }
}