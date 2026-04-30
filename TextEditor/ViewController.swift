
import UIKit
class ViewController: UIViewController, UIColorPickerViewControllerDelegate {

    //MARK: @IBOutlet & Variables
    @IBOutlet weak var lblHTMLText                                  : UILabel!
    @IBOutlet weak var richTextEditor                               : UITextView!
    @IBOutlet weak var btFont                                       : UIButton!
    @IBOutlet weak var btFontSize                                   : UIButton!
    @IBOutlet weak var lblFont                                      : UILabel!
    @IBOutlet weak var lblFontSize                                  : UILabel!
    @IBOutlet weak var pickerView                                   : UIView!
    @IBOutlet weak var colorPickerView                              : UIView!
    @IBOutlet weak var txtColorView                                 : UIView!
    @IBOutlet weak var txtColorLbl                                  : UILabel!
    @IBOutlet weak var txtBackGrndColorLbl                          : UILabel!
    var fontSize                                                    : [CGFloat] = [8, 9, 10, 11, 12, 14, 16, 18, 24, 30]
    var fonts                                                       = ["Arial", "Verdana", "Helvetica", "Tahoma",   "Trebuchet MS",
                                                                       "Times New Roman",  "Georgia",   "Garamond", "Courier New",
                                                                       "Brush Script MT"]
    var colors                                                      = ["#000000", "#e60000", "#ff9900", "#ffff00", "#008a00",
                                                                       "#0066cc", "#9933ff", "#ffffff", "#facccc", "#ffebcc",
                                                                       "#ffebcc", "#cce8cc", "#cce0f5", "#ebd6ff", "#bbbbbb",
                                                                       "#f06666", "#ffc266", "#ffff66", "#66b966", "#66a3e0",
                                                                       "#c285ff", "#888888", "#a10000", "#b26b00", "#b2b200",
                                                                       "#006100", "#0047b2", "#6b24b2", "#444444", "#5c0000",
                                                                       "#663d00", "#666600", "#003700", "#002966", "#3d1466"]
    
    var txtBackgroundClr : UIColor = .white {
        didSet {
            
            self.txtBackGrndColorLbl.backgroundColor                    = txtBackgroundClr.withAlphaComponent(0.6)
            self.applyBackgroundColor(txtBackgroundClr)
        }
    }
    
    ///For changing text color
    var selectedColor : UIColor = .black {
        didSet {
            
            if self.selectedColor != .black {
                
                self.txtColorLbl.tintColor                    = .systemBlue
            }
            else {
                self.txtColorLbl.tintColor                    = .black
            }
            self.txtColorView.backgroundColor                        = self.selectedColor
            changeSelectedTextColor(in: self.richTextEditor, to: self.selectedColor)
        }
    }
    ///For changing text font
    var selectedFont: String = "Arial" {
        didSet {
            
            let isDefaultFont                                       = !(self.selectedFont == "Garamond")
            self.selectedFont                                       = isDefaultFont ? self.selectedFont : "EBGaramond-Regular"
            //self.richTextEditor.font                                = UIFont(name: font, size: self.selectedSize)
            
            self.lblFont.text                                       = self.selectedFont + " ▼"
            let font = UIFont(name: selectedFont, size: self.selectedSize)!
            self.changeFont(font)
        }
    }
    ///For text font traits
    var selectedTrait: TextStyle = .normal {
        didSet {
            //self.applyStyle(to: self.richTextEditor, style: selectedTrait)
            
            if selectedTrait == .underline {
                
                applyUnderline()
            }
            else {
                
                self.applyFontTrait(selectedTrait)
            }
        }
    }
    ///For text font size
    var selectedSize: CGFloat = 16 {
        didSet {
            //self.richTextEditor.font                                = UIFont(name: self.selectedFont, size: self.selectedSize)
            self.lblFontSize.text                                   = "\(Int(self.selectedSize)) ▼"
            let font = UIFont(name: self.selectedFont, size: self.selectedSize)!
            self.changeFont(font)
        }
    }
    ///For text Alignment
    var selectedAlign: NSTextAlignment = .left {
        didSet {
            self.richTextEditor.textAlignment                       = self.selectedAlign
        }
    }
    var pickerTag                                                   = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtColorView.backgroundColor                           = self.selectedColor
        self.btFont.showsMenuAsPrimaryAction                        = true
        self.btFont.menu                                            = createMenu(from: fonts)
        self.btFont.translatesAutoresizingMaskIntoConstraints       = false
        
        self.btFontSize.showsMenuAsPrimaryAction                    = true
        self.btFontSize.menu                                        = createFontSizeMenu(from: self.fontSize)
        self.btFontSize.translatesAutoresizingMaskIntoConstraints   = false
        
        let picker                                                  = CustomColorPickerView(colorHexes: self.colors)
        picker.translatesAutoresizingMaskIntoConstraints            = false
        picker.onColorPicked = { color in
            
            if self.pickerTag == 0 {
                
                self.selectedColor                                  = color
            }
            else {
                
                if color.isColor(color, equalTo: .white) {
                    
                    self.txtBackgroundClr                               = .white
                }
                else {
                    self.txtBackgroundClr                               = color
                }
                
            }
            
            self.pickerView.isHidden.toggle()
        }
        picker.frame                                                = self.colorPickerView.frame
        self.colorPickerView.addSubview(picker)
        self.pickerView.isHidden                                    = true
//        for family in UIFont.familyNames {
//            print("Family: \(family)")
//            for name in UIFont.fontNames(forFamilyName: family) {
//                print("  Font: \(name)")
//            }
//        }
        
        
    }

    // MARK: remove all Styling Erase bt
    @IBAction func btErase(_ sender: UIButton) {
        
        self.selectedFont                                           = "Arial"
        self.selectedSize                                           = 17
        self.selectedAlign                                          = .left
        self.selectedTrait                                          = .normal
        self.selectedColor                                          = .black
    }
    // MARK: Add link to text Action
    @IBAction func btAddLinkAction(_ sender: UIButton) {
        
        let alert                                                   = UIAlertController(title: "Insert Link",
                                                                                        message: "Enter the URL to link selected text",
                                                                                        preferredStyle: .alert)
        alert.addTextField { textField in
            
            textField.placeholder                                   = "https://example.com"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Insert", style: .default, handler: { _ in
            
            if let urlText = alert.textFields?.first?.text, !urlText.isEmpty {
                
                self.insertLink(in: self.richTextEditor, urlString: urlText)
            }
        }))
        if let vc = self.richTextEditor.window?.rootViewController {
           
            vc.present(alert, animated: true)
        }
    }
    // MARK: Font Style to text Action
    @IBAction func btFontStyleAction(_ sender: UIButton) {
        
        switch sender.tag {
            
        case 1:
            self.selectedTrait                                      = .italic
            break
        case 2:
            self.selectedTrait                                      = .underline
            break
        default:
            self.selectedTrait                                      = .bold
            break
        }
    }
    // MARK: Font Alignment to text Action
    @IBAction func btFontAlignAction(_ sender: UIButton) {
        
        switch sender.tag {
        case 1:
            self.selectedAlign                                      = .center
            break
        case 2:
            self.selectedAlign                                      = .right
            break
        default:
            self.selectedAlign                                      = .left
            break
        }
    }
    // MARK: Font Color to text Action
    @IBAction func btFontColorAction(_ sender: UIButton) {
        
        self.pickerView.isHidden.toggle()
    }
    // MARK: Font Color to text Action
    @IBAction func btFontBackGrndColorAction(_ sender: UIButton) {
        
        self.pickerTag                                        = 1
        self.pickerView.isHidden.toggle()
    }
    // MARK: Export Action for HTML String
    @IBAction func btnExportHTMl(_ sender: Any) {
        
        let attributedText                                          = self.richTextEditor.attributedText!
        self.lblHTMLText.text                                       = attributedText.attributedStringToInlineHTML()
        print(self.lblHTMLText.text ?? "")
    }
    
}
// MARK: Extension For ViewController Methods
extension ViewController {
   
    enum TextStyle {
       
        case normal, bold, italic, underline
    }

    //MARK: Updating Font
    func changeFont(_ font: UIFont) {
       
        if richTextEditor.selectedRange.length > 0 {
          
            let selectedRange = self.richTextEditor.selectedRange
            guard selectedRange.length > 0 else { return }

            let attributedText = NSMutableAttributedString(attributedString: self.richTextEditor.attributedText)
            attributedText.addAttribute(.font, value: font, range: selectedRange)

            self.richTextEditor.attributedText = attributedText
            self.richTextEditor.selectedRange = selectedRange // keep selection
        }
        else {
            
            richTextEditor.typingAttributes[.font] = font // new text to be typed
        }
        self.applyStyle(to: self.richTextEditor, style: selectedTrait)
    }
    
    //MARK: Updating Font
    func applyBackgroundColor(_ color: UIColor) {
        
        let selectedRange = richTextEditor.selectedRange

        if selectedRange.length > 0 {
            
            let attributedText = NSMutableAttributedString(attributedString: richTextEditor.attributedText)
            attributedText.addAttribute(.backgroundColor, value: (color == .white) ? .clear : color, range: selectedRange)
            richTextEditor.attributedText = attributedText
            richTextEditor.selectedRange = selectedRange
        }
        else {
            // Apply to future text input
            richTextEditor.typingAttributes[.backgroundColor] = (color == .white) ? .clear : color
        }
        self.applyStyle(to: self.richTextEditor, style: selectedTrait)
    }

    //MARK: Change Text Color
    func changeSelectedTextColor(in textView: UITextView, to color: UIColor) {
       
        let selectedRange = textView.selectedRange

        if selectedRange.length > 0 {
            
            let attributedText = NSMutableAttributedString(attributedString: textView.attributedText)
            attributedText.addAttribute(.foregroundColor, value: color, range: selectedRange)
            textView.attributedText = attributedText
            textView.selectedRange = selectedRange
        }
        else {
            // Apply to future text input
            textView.typingAttributes[.foregroundColor] = color
        }
        self.applyStyle(to: self.richTextEditor, style: selectedTrait)
    }
    
    //MARK: create Menu for font
    func createMenu(from items: [String]) -> UIMenu {
       
        let actions = items.map { title in
            
            UIAction(title: title) { _ in
               
                print("Selected: \(title)")
                self.selectedFont                                   = title
            }
        }
        return UIMenu(title: "", children: actions)
    }
    
    //MARK: create Menu for Font Size
    func createFontSizeMenu(from items: [CGFloat]) -> UIMenu {
        
        let actions = items.map { size in
                
            UIAction(title: "\(Int(size))") { _ in
                
                print("Selected: \(size)")
                self.selectedSize                                   = size
            }}
        return UIMenu(title: "", children: actions)
    }
    
    //MARK: Apply font Style to Text
    func applyStyle(to textView: UITextView, style: TextStyle) {
        
        guard let selectedRange = textView.selectedTextRange,
              !selectedRange.isEmpty else {
            
            textView.typingAttributes[.font]                      = UIFont.systemFont(ofSize: 17)
            return
        }

        let location                                                = textView.offset(from: textView.beginningOfDocument,
                                                                                      to: selectedRange.start)
        let length                                                  = textView.offset(from: selectedRange.start,
                                                                                      to: selectedRange.end)
        let nsRange                                                 = NSRange(location: location, length: length)
        let mutableAttrString                                       = NSMutableAttributedString(attributedString: textView.attributedText)
        mutableAttrString.enumerateAttribute(.font, in: nsRange, options: []) { value, range, _ in
            
            var font                                                : UIFont
            if let currentFont = value as? UIFont {
                
                font                                                = currentFont
            }
            else {
                
                font                                                = UIFont(name: self.selectedFont, size: self.selectedSize)!
            }
            var newFont                                             : UIFont
            switch style {
            case .bold:
                newFont                                             = applyTrait(font: font, trait: .traitBold)
                mutableAttrString.removeAttribute(.underlineStyle, range: range)

            case .italic:
                newFont                                             = applyTrait(font: font, trait: .traitItalic)
                mutableAttrString.removeAttribute(.underlineStyle, range: range)

            case .underline:
                newFont                                             = font
                let currentUnderline                                = mutableAttrString.attribute(.underlineStyle,
                                                                                                  at: range.location,
                                                                                                  effectiveRange: nil) as? Int ?? 0
                if currentUnderline == 0 {
                   
                    mutableAttrString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
                }
                else {
                    mutableAttrString.removeAttribute(.underlineStyle, range: range)
                }

            case .normal:
                // Reset to system font without traits & remove underline
                newFont                                             = UIFont(name: self.selectedFont, size: self.selectedSize)!
                mutableAttrString.removeAttribute(.underlineStyle, range: range)
            }
            if style != .underline {
                mutableAttrString.addAttribute(.font, value: newFont, range: range)
            }
        }
        textView.attributedText                                     = mutableAttrString
        textView.selectedRange                                      = nsRange
    }

    func applyFontTrait(_ trait: TextStyle) {
        
        let selectedRange = self.richTextEditor.selectedRange

        if selectedRange.length > 0 {
            let attributedText = NSMutableAttributedString(attributedString: richTextEditor.attributedText)

            attributedText.enumerateAttribute(.font, in: selectedRange, options: []) { value, range, _ in
                if let font = value as? UIFont {
                    var newFont: UIFont!
                    
                    switch trait {
                    case .bold:
                        newFont                                             = applyTrait(font: font, trait: .traitBold)
                        attributedText.removeAttribute(.underlineStyle, range: range)
                        
                    case .italic:
                        newFont                                             = applyTrait(font: font, trait: .traitItalic)
                        attributedText.removeAttribute(.underlineStyle, range: range)
                        
                    default :
                        // Reset to system font without traits & remove underline
                        newFont                                             = UIFont(name: self.selectedFont, size: self.selectedSize)!
                        attributedText.removeAttribute(.underlineStyle, range: range)
                        break
                    }
                    attributedText.addAttribute(.font, value: newFont as Any, range: range)
                }
            }
            richTextEditor.attributedText = attributedText
            richTextEditor.selectedRange = selectedRange
        }
        else {
            // Set trait for new text to be typed
            if let currentFont = richTextEditor.typingAttributes[.font] as? UIFont {
                
                var newTrait: UIFontDescriptor.SymbolicTraits
                switch trait {
                case .bold:
                    newTrait                                                  = .traitBold
                case .italic:
                    newTrait                                                  = .traitItalic
                default:
                    newTrait                                                  = []
                }
                let newFont = applyTrait(font: currentFont, trait: newTrait)
                debugPrint(newFont)
                richTextEditor.typingAttributes[.font] = newFont
            }
        }
    }

    func applyUnderline() {
       
        let selectedRange = richTextEditor.selectedRange

        if selectedRange.length > 0 {
            let attributedText = NSMutableAttributedString(attributedString: richTextEditor.attributedText)
            attributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: selectedRange)
            richTextEditor.attributedText = attributedText
            richTextEditor.selectedRange = selectedRange
        } else {
            // Set underline for future typing
            richTextEditor.typingAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
    }
    
    //MARK: Apply Trait to text
    func applyTrait(font: UIFont, trait: UIFontDescriptor.SymbolicTraits) -> UIFont {
       
        var symTraits                                               = font.fontDescriptor.symbolicTraits
        if symTraits.contains(trait) {
            symTraits.remove(trait)
        }
        else {
            symTraits.insert(trait)
        }
        if let descriptor = font.fontDescriptor.withSymbolicTraits(symTraits) {
           
            return UIFont(descriptor: descriptor, size: font.pointSize)
        }
        return font
    }
    
    //MARK: Insert link to Text
    func insertLink(in textView: UITextView, urlString: String) {
        
        guard let selectedRange = textView.selectedTextRange, !selectedRange.isEmpty else {
            return
        }
        let location                                                = textView.offset(from: textView.beginningOfDocument,
                                                                                      to: selectedRange.start)
        let length                                                  = textView.offset(from: selectedRange.start, to: selectedRange.end)
        let nsRange                                                 = NSRange(location: location, length: length)
        let mutableAttrString                                       = NSMutableAttributedString(attributedString: textView.attributedText)
        // Apply link attribute to selected range
        mutableAttrString.addAttribute(.link, value: urlString, range: nsRange)
        textView.attributedText                                     = mutableAttrString
        textView.selectedRange                                      = nsRange
    }
    
    
}
extension UIColor {
    
    func isColor(_ color1: UIColor, equalTo color2: UIColor, withTolerance tolerance: CGFloat = 0.01) -> Bool {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return abs(r1 - r2) < tolerance &&
               abs(g1 - g2) < tolerance &&
               abs(b1 - b2) < tolerance &&
               abs(a1 - a2) < tolerance
    }
}
