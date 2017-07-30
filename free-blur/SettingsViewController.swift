//
//  SecondViewController.swift
//  free-blur
//
//  Created by Justin Kambic on 6/1/17.
//

import UIKit

class SettingsViewController: UIViewController {
    let blurSettings = BlurSettings()
    
    @IBOutlet weak var diamval: UILabel!
    @IBOutlet weak var diameterSlider: UISlider!
    @IBOutlet weak var passSlider: UISlider!
    
    @IBOutlet weak var shapeButtons: UISegmentedControl!
    @IBOutlet weak var passLabel: UILabel!
    var numPasses: Int = 0
    var diameter: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        numPasses = self.blurSettings.getNumPasses()
        diameter = self.blurSettings.getDiameter()
        let shape = self.blurSettings.getBlurShape()
        let shapeSegment = shape == "circle" ? 0 : 1
        
        self.diameterSlider.setValue(Float(diameter), animated: false)
        self.passSlider.setValue(Float(numPasses), animated: false)
        
        self.passSlider.addTarget(self, action: #selector(self.passesSliderChanged(_:)), for: .valueChanged)
        self.diameterSlider.addTarget(self, action: #selector(self.diameterSl(_:)), for: .valueChanged)
        
        self.setDiameterLabel(value: String(Int(self.diameterSlider.value)))
        self.setPassesLabel(value: String(Int(self.passSlider.value)))
        self.shapeButtons.selectedSegmentIndex = shapeSegment
    }
    
    @IBAction func segmentchanged(_ sender: Any) {
        let shapeSelection = self.shapeButtons.selectedSegmentIndex
        
        let shape = shapeSelection == 0 ? "circle" : "square"
        
        do {
            try self.blurSettings.setBlurShape(shape: shape)
        } catch {
            self.showErrorMessage()
        }
    }
    
    func passesSliderChanged(_ sender: UISlider) {
        let nextPasses = Int(sender.value)
        self.setPassesLabel(value: String(nextPasses))
        do {
            try self.blurSettings.setNumPasses(numPasses: nextPasses)
        } catch {
            self.showErrorMessage()
        }
    }
    
    func diameterSl(_ sender: UISlider) {
        let nextDiameter = Int(sender.value)
        self.setDiameterLabel(value: String(nextDiameter))
        do {
            try self.blurSettings.setDiameter(diameter: nextDiameter)
        } catch {
            self.showErrorMessage()
        }
    }
    
    func setDiameterLabel(value: String) {
        self.diamval.text = value + " pixels"
    }
    
    func setPassesLabel(value: String) {
        self.passLabel.text = value + " passes"
    }

    func showErrorMessage() {
        let alertController = UIAlertController(title: "Error saving settings", message: "There was a problem saving your settings. Please open an issue and describe what you were doing at https://github.com/jkascend/free-blur/issues/", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
