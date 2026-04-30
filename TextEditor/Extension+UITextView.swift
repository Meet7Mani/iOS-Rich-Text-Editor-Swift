
import UIKit



extension UITextField{
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    
    @IBInspectable var padding_left: CGFloat {
        get {
            return 0
        }
        set (f) {
            layer.sublayerTransform = CATransform3DMakeTranslation(f, 0, 0)
        }
    }
}

extension UITextView {
    
    /**
     Calls provided `test` block if point is in gliph range and there is no link detected at this point.
     Will pass in to `test` a character index that corresponds to `point`.
     Return `self` in `test` if text view should intercept the touch event or `nil` otherwise.
     */
    public func hitTest(pointInGliphRange aPoint: CGPoint, event: UIEvent?, test: (Int) -> UIView?) -> UIView? {
        guard let charIndex = charIndexForPointInGlyphRect(point: aPoint) else {
                return super.hitTest(aPoint, with: event)
        }
        guard textStorage.attribute(NSAttributedString.Key.link, at: charIndex, effectiveRange: nil) == nil else {
            return super.hitTest(aPoint, with: event)
        }
        return test(charIndex)
    }
    
    /**
     Returns true if point is in text bounding rect adjusted with padding.
     Bounding rect will be enlarged with positive padding values and decreased with negative values.
     */
    public func pointIsInTextRange(point aPoint: CGPoint, range: NSRange, padding: UIEdgeInsets) -> Bool {
        var boundingRect = layoutManager.boundingRect(forGlyphRange: range, in: textContainer)
        boundingRect = boundingRect.offsetBy(dx: textContainerInset.left, dy: textContainerInset.top)
        boundingRect = boundingRect.insetBy(dx: -(padding.left + padding.right), dy: -(padding.top + padding.bottom))
        return boundingRect.contains(aPoint)
    }
    
    /**
     Returns index of character for glyph at provided point. Returns `nil` if point is out of any glyph.
     */
    public func charIndexForPointInGlyphRect(point aPoint: CGPoint) -> Int? {
        let point = CGPoint(x: aPoint.x, y: aPoint.y - textContainerInset.top)
        let glyphIndex = layoutManager.glyphIndex(for: point, in: textContainer)
        let glyphRect = layoutManager.boundingRect(forGlyphRange: NSMakeRange(glyphIndex, 1), in: textContainer)
        if glyphRect.contains(point) {
            return layoutManager.characterIndexForGlyph(at: glyphIndex)
        } else {
            return nil
        }
    }
    
    func trimTextView(){
        self.text = self.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func leftSpace() {
        self.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 4, right: 4)
    }
}

extension UITextView {
    
//    func attributedStringFromHTML(_ html: String) {
//       
//        let result                                  = NSMutableAttributedString()
//        
//        // --- STEP 1: Normalize ---
//        let cleanedHTML                             = html
//                                                        .replacingOccurrences(of: "\\/", with: "/")
//                                                        .replacingOccurrences(of: "<br>", with: "\n")
//                                                        .replacingOccurrences(of: "<br/>", with: "\n")
//                                                        .replacingOccurrences(of: "<br />", with: "\n")
//                                                        .replacingOccurrences(of: "</p>", with: "\n")
//        
//        let preprocessedHTML                        = cleanedHTML
//                                                        .replacingOccurrences(of: "<p>", with: "")
//                                                        .replacingOccurrences(of: "<ul>", with: "[[ul_start]]")
//                                                        .replacingOccurrences(of: "</ul>", with: "[[ul_end]]")
//                                                        .replacingOccurrences(of: "<ol>", with: "[[ol_start]]")
//                                                        .replacingOccurrences(of: "</ol>", with: "[[ol_end]]")
//                                                        .replacingOccurrences(of: "<li>", with: "[[li]]")
//                                                        .replacingOccurrences(of: "</li>", with: "\n")
//        
//        // --- STEP 2: Process lists and <p> ---
//        var finalHTML = ""
//        var insideOrderedList = false
//        var olCounter = 1
//        
//        let lines = preprocessedHTML.components(separatedBy: "\n")
//        
//        for var line in lines {
//            // Extract <p> alignment
////            if let pRange = line.range(of: #"<p[^>]*>"#, options: .regularExpression) {
////                let pTag = String(line[pRange])
////                
////                if let alignMatch = pTag.range(of: #"text-align:\s*(left|center|right|justify)"#, options: .regularExpression) {
////                    let alignStr = String(pTag[alignMatch])
////                        .replacingOccurrences(of: "text-align:", with: "")
////                        .trimmingCharacters(in: .whitespaces)
////                    
////                    switch alignStr.lowercased() {
////                    case "center": line = "[[align=center]]" + line
////                    case "right": line = "[[align=right]]" + line
////                    case "justify": line = "[[align=justify]]" + line
////                    default: break
////                    }
////                }
////                
////                // ✅ Remove the entire <p ...> completely
////                line = line.replacingOccurrences(of: pTag, with: "")
////            }
//            
//            // Handle lists
//            if line.contains("[[ul_start]]") {
//                insideOrderedList = false
//                line = line.replacingOccurrences(of: "[[ul_start]]", with: "")
//            }
//            if line.contains("[[ol_start]]") {
//                insideOrderedList = true
//                olCounter = 1
//                line = line.replacingOccurrences(of: "[[ol_start]]", with: "")
//            }
//            if line.contains("[[ul_end]]") || line.contains("[[ol_end]]") {
//                insideOrderedList = false
//                line = line.replacingOccurrences(of: "[[ul_end]]", with: "")
//                line = line.replacingOccurrences(of: "[[ol_end]]", with: "")
//            }
//            
//            if line.contains("[[li]]") {
//                if insideOrderedList {
//                    line = line.replacingOccurrences(of: "[[li]]", with: "\(olCounter). ")
//                    olCounter += 1
//                } else {
//                    line = line.replacingOccurrences(of: "[[li]]", with: "• ")
//                }
//            }
//            
//            finalHTML += line + "\n"
//        }
//        
//        // --- STEP 3: Regex for tags ---
//        //let pattern                                 = #"<(span|strong|em|u|b|i|p)[^>]*>(.*?)</\1>"#
//        let pattern = #"(\[\[(?:align=(?:left|center|right|justify)|[a-zA-Z0-9_]+)\]\])|<(span|strong|em|u|b|i)[^>]*>(.*?)</\2>|([^<\[]+)"#
//        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators, .caseInsensitive]) else {
//            
//            self.attributedText                     = NSAttributedString(string: finalHTML)
//            return
//        }
//        
//        let nsHTML                                  = finalHTML as NSString
//        var lastLocation                            = 0
//        
//        for match in regex.matches(in: finalHTML, range: NSRange(location: 0, length: nsHTML.length)) {
//           
//            // Append plain text before tag
//            if match.range.location > lastLocation {
//               
//                let plainText                       = nsHTML.substring(with: NSRange(location: lastLocation,
//                                                                                     length: match.range.location - lastLocation))
//                result.append(NSAttributedString(string: plainText))
//            }
//            
//            let fullTag = nsHTML.substring(with: match.range(at: 0))
//            var innerText = safeGroup(match, 4, in: nsHTML)
//                ?? safeGroup(match, 5, in: nsHTML)
//                ?? safeGroup(match, 1, in: nsHTML)
//                ?? safeGroup(match, 3, in: nsHTML)
//                ?? ""
//            
//            // Keep line breaks
//            innerText                               = innerText
//                                                        .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
//                                                        .replacingOccurrences(of: "<br>", with: "\n")
//                                                        .replacingOccurrences(of: "<br/>", with: "\n")
//                                                        .replacingOccurrences(of: "<br />", with: "\n")
//            
//            if innerText.isEmpty {
//                lastLocation = match.range.location + match.range.length
//                continue
//            }
//            // --- Default style ---
//            var fontName                            = "Arial"
//            var fontSize                            : CGFloat = 14
//            var traits                              : UIFontDescriptor.SymbolicTraits = []
//            var textColor                           : UIColor = .black
//            var bgColor                             : UIColor? = nil
//            var underline                           = false
//            
//            // --- Extract inline styles ---
//            if let styleMatch = fullTag.range(of: #"style="([^"]*)""#, options: .regularExpression) {
//                
//                let styleString                     = String(fullTag[styleMatch])
//                                                        .replacingOccurrences(of: "style=", with: "")
//                                                        .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
//                var styleDict                       : [String: String] = [:]
//                
//                styleString.split(separator: ";").forEach { pair in
//                    
//                    let parts = pair.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
//                    if parts.count == 2 {
//                        
//                        styleDict[parts[0].lowercased()] = parts[1]
//                    }
//                }
//                
//                if let sizeVal = styleDict["font-size"]?.replacingOccurrences(of: "px", with: "").trimmingCharacters(in: .whitespaces), let size = Double(sizeVal) {
//                    
//                    fontSize                        = CGFloat(size)
//                }
//                if let colorVal = styleDict["color"] {
//                    
//                    textColor                       = parseCSSColor(colorVal) ?? textColor
//                }
//                if let bgVal = styleDict["background-color"] {
//                   
//                    bgColor                         = parseCSSColor(bgVal)
//                }
//            }
//            
//            // --- Font from class (ql-font-*) ---
//            if let fontMatch = fullTag.range(of: #"ql-font-([A-Za-z0-9]+)"#, options: .regularExpression) {
//                
//                let matchStr                        = String(fullTag[fontMatch])
//                fontName                            = matchStr
//                                                        .replacingOccurrences(of: "ql-font-", with: "")
//                                                        .replacingOccurrences(of: "-", with: " ")
//            }
//            
//            if fontName == "Garamond" {
//                
//                fontName                            = "EB Garamond"
//            }
//            else if fontName == "Courier" || fontName == "CourierNew" {
//                
//                fontName                            = "Courier New"
//            }
//            
//            // --- Traits from tags ---
//            let tagLower                            = fullTag.lowercased()
//            if tagLower.contains("<strong") || tagLower.contains("<b") {
//              
//                traits.insert(.traitBold)
//            }
//            if tagLower.contains("<em") || tagLower.contains("<i") {
//                
//                traits.insert(.traitItalic)
//            }
//            if tagLower.contains("<u") {
//                
//                underline                           = true
//            }
//            
//            // --- Build font safely ---
//            var font                                : UIFont
//            if let customFont = UIFont(name: fontName, size: fontSize) {
//                
//                font                                = customFont
//            }
//            else {
//                font                                = UIFont.systemFont(ofSize: fontSize)
//            }
//            if let descriptor = font.fontDescriptor.withSymbolicTraits(traits) {
//                
//                font                                = UIFont(descriptor: descriptor, size: fontSize)
//            }
//            
//            // --- Attributes ---
//            var attrs                               : [NSAttributedString.Key: Any] = [
//                .font: font,
//                .foregroundColor: textColor
//            ]
//            if let bg = bgColor {
//                
//                attrs[.backgroundColor]             = bg
//            }
//            if underline {
//                
//                attrs[.underlineStyle]              = NSUnderlineStyle.single.rawValue
//            }
//            result.append(NSAttributedString(string: innerText, attributes: attrs))
//            lastLocation                            = match.range.location + match.range.length
//        }
//        // Append trailing plain text
//        if lastLocation < nsHTML.length {
//            
//            let trailing                            = nsHTML.substring(from: lastLocation)
//            result.append(NSAttributedString(string: trailing))
//        }
//        // --- STEP 4: Apply alignment per paragraph (safe!) ---
//        let alignRegex = #"\[\[align=(left|center|right|justify)\]\]"#
////        if let _ = try? NSRegularExpression(pattern: alignRegex).firstMatch(in: result.string, range: NSRange(location: 0, length: result.length)) {
////            applyParagraphAlignment(to: result)
////        }
//        
//        self.attributedText                         = result
//    }
    
//    func attributedStringFromHTML(_ html: String) {
//        let result = NSMutableAttributedString()
//
//        // --- STEP 1: Normalize ---
//        let cleanedHTML = html
//            .replacingOccurrences(of: "\\/", with: "/")
//            .replacingOccurrences(of: "<br>", with: "\n")
//            .replacingOccurrences(of: "<br/>", with: "\n")
//            .replacingOccurrences(of: "<br />", with: "\n")
//            .replacingOccurrences(of: "</p>", with: "\n")
//
//        var preprocessedHTML = cleanedHTML
//            .replacingOccurrences(of: "<ul>", with: "[[ul_start]]")
//            .replacingOccurrences(of: "</ul>", with: "[[ul_end]]")
//            .replacingOccurrences(of: "<ol>", with: "[[ol_start]]")
//            .replacingOccurrences(of: "</ol>", with: "[[ol_end]]")
//        // Keep style info for <li> and <p>
//            .replacingOccurrences(of: #"<li([^>]*)>"#, with: "[[li$1]]", options: .regularExpression)
//            .replacingOccurrences(of: "</li>", with: "\n")
//            .replacingOccurrences(of: #"<p([^>]*)>"#, with: "[[p$1]]", options: .regularExpression)
////            .replacingOccurrences(of: "<li>", with: "[[li]]")
////            .replacingOccurrences(of: "</li>", with: "\n")
//
//        // --- STEP 2: Process lists and <p> ---
//        var finalHTML = ""
//        var insideOrderedList = false
//        var olCounter = 1
//
//        let lines = preprocessedHTML.components(separatedBy: "\n")
//        for var line in lines {
//            // --- Extract <p> alignment ---
////            if let pRange = line.range(of: #"<p[^>]*>"#, options: .regularExpression) {
////                let pTag = String(line[pRange])
////                if let alignMatch = pTag.range(of: #"text-align:\s*(left|center|right|justify)"#, options: .regularExpression) {
////                    let alignStr = String(pTag[alignMatch])
////                        .replacingOccurrences(of: "text-align:", with: "")
////                        .trimmingCharacters(in: .whitespaces)
////                    switch alignStr.lowercased() {
////                    case "center": line = "[[align=center]]" + line
////                    case "right": line = "[[align=right]]" + line
////                    case "justify": line = "[[align=justify]]" + line
////                    default: break
////                    }
////                }
////                line = line.replacingOccurrences(of: pTag, with: "")
////            }
//            if let tagRange = line.range(of: #"\[\[(p|li)([^\]]*)\]\]"#, options: .regularExpression) {
//                let tagStr = String(line[tagRange])
//                if let alignMatch = tagStr.range(of: #"text-align:\s*(left|center|right|justify)"#, options: .regularExpression) {
//                    let alignStr = String(tagStr[alignMatch])
//                        .replacingOccurrences(of: "text-align:", with: "")
//                        .trimmingCharacters(in: .whitespaces)
//                    line = "[[align=\(alignStr)]]" + line
//                }
//                line = line.replacingOccurrences(of: tagStr, with: "")
//            }
//            // --- Handle lists ---
//            if line.contains("[[ul_start]]") { insideOrderedList = false; line = line.replacingOccurrences(of: "[[ul_start]]", with: "") }
//            if line.contains("[[ol_start]]") { insideOrderedList = true; olCounter = 1; line = line.replacingOccurrences(of: "[[ol_start]]", with: "") }
//            if line.contains("[[ul_end]]") || line.contains("[[ol_end]]") { insideOrderedList = false; line = line.replacingOccurrences(of: "[[ul_end]]", with: ""); line = line.replacingOccurrences(of: "[[ol_end]]", with: "") }
//            if line.contains("[[li]]") {
//                if insideOrderedList {
//                    line = line.replacingOccurrences(of: "[[li]]", with: "\(olCounter). ")
//                    olCounter += 1
//                } else { line = line.replacingOccurrences(of: "[[li]]", with: "• ") }
//            }
//            finalHTML += line + "\n"
//        }
//
//        // --- STEP 3: Regex for tags including <a> ---
//        let pattern = #"(\[\[align=(?:left|center|right|justify)\]\])|<a[^>]*?href="([^"]+)"[^>]*>(.*?)</a>|<(span|strong|em|u|b|i)[^>]*>(.*?)</\4>|([^<\[]+)"#
//
//        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators, .caseInsensitive]) else {
//            self.attributedText = NSAttributedString(string: finalHTML)
//            return
//        }
//
//        let nsHTML = finalHTML as NSString
//        var lastLocation = 0
//
//        for match in regex.matches(in: finalHTML, range: NSRange(location: 0, length: nsHTML.length)) {
//            // Append plain text before tag
//            if match.range.location > lastLocation {
//                let plainText = nsHTML.substring(with: NSRange(location: lastLocation, length: match.range.location - lastLocation))
//                result.append(NSAttributedString(string: plainText))
//            }
//
//            // Determine matched content
//            let linkHref = safeGroup(match, 2, in: nsHTML)
//            var innerText = safeGroup(match, 3, in: nsHTML)
//                ?? safeGroup(match, 5, in: nsHTML)
//                ?? safeGroup(match, 1, in: nsHTML)
//                ?? safeGroup(match, 6, in: nsHTML)
//                ?? ""
//
//            innerText = innerText
//                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
//                .replacingOccurrences(of: "<br>", with: "\n")
//                .replacingOccurrences(of: "<br/>", with: "\n")
//                .replacingOccurrences(of: "<br />", with: "\n")
//
//            if innerText.isEmpty { lastLocation = match.range.location + match.range.length; continue }
//
//            // --- Default style ---
//            var fontName = "Arial"
//            var fontSize: CGFloat = 14
//            var traits: UIFontDescriptor.SymbolicTraits = []
//            var textColor: UIColor = .black
//            var bgColor: UIColor? = nil
//            var underline = false
//
//            // Inline styles for <span> inside link
//            let fullTag = nsHTML.substring(with: match.range(at: 0))
//            if let styleMatch = fullTag.range(of: #"style="([^"]*)""#, options: .regularExpression) {
//               
//                let styleString = String(fullTag[styleMatch]).replacingOccurrences(of: "style=", with: "").trimmingCharacters(in: CharacterSet(charactersIn: "\""))
//                var styleDict: [String: String] = [:]
//                styleString.split(separator: ";").forEach { pair in
//                    let parts = pair.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
//                    if parts.count == 2 { styleDict[parts[0].lowercased()] = parts[1] }
//                }
//                if let sizeVal = styleDict["font-size"]?.replacingOccurrences(of: "px", with: "").trimmingCharacters(in: .whitespaces), let size = Double(sizeVal) {
//                    fontSize = CGFloat(size)
//                }
//                if let colorVal = styleDict["color"] {
//                    textColor = parseCSSColor(colorVal) ?? textColor
//                }
//                if let bgVal = styleDict["background-color"] {
//                    bgColor = parseCSSColor(bgVal)
//                }
//            }
//
//            if let colorVal = fullTag["font-color"] as? String {
//                textColor = parseCSSColor(colorVal) ?? textColor
//            }
//            // Font class
//            if let fontMatch = fullTag.range(of: #"ql-font-([A-Za-z0-9]+)"#, options: .regularExpression) {
//                let matchStr = String(fullTag[fontMatch])
//                fontName = matchStr.replacingOccurrences(of: "ql-font-", with: "").replacingOccurrences(of: "-", with: " ")
//            }
//            if fontName == "Garamond" { fontName = "EB Garamond" }
//            else if fontName == "Courier" || fontName == "CourierNew" { fontName = "Courier New" }
//            else if fontName == "TimesNewRoman" { fontName = "Times New Roman" }
//
//            // Traits from tags
//            let tagLower = fullTag.lowercased()
//            if tagLower.contains("<strong") || tagLower.contains("<b") { traits.insert(.traitBold) }
//            if tagLower.contains("<em") || tagLower.contains("<i") { traits.insert(.traitItalic) }
//            if tagLower.contains("<u") { underline = true }
//
//            // Build font safely
//            var font: UIFont
//            if let customFont = UIFont(name: fontName, size: fontSize) { font = customFont }
//            else { font = UIFont.systemFont(ofSize: fontSize) }
//            if let descriptor = font.fontDescriptor.withSymbolicTraits(traits) { font = UIFont(descriptor: descriptor, size: fontSize) }
//
//            // Attributes
//            var attrs: [NSAttributedString.Key: Any] = [
//                .font: font,
//                .foregroundColor: textColor
//            ]
//            if let bg = bgColor { attrs[.backgroundColor] = bg }
//            if underline { attrs[.underlineStyle] = NSUnderlineStyle.single.rawValue }
//            if let href = linkHref, let url = URL(string: href) { attrs[.link] = url }
//
//            result.append(NSAttributedString(string: innerText, attributes: attrs))
//            lastLocation = match.range.location + match.range.length
//        }
//
//        // Append trailing plain text
//        if lastLocation < nsHTML.length {
//            let trailing = nsHTML.substring(from: lastLocation)
//            result.append(NSAttributedString(string: trailing))
//        }
//
//        // --- STEP 4: Apply alignment per paragraph ---
//        let alignRegex = #"\[\[align=(left|center|right|justify)\]\]"#
//        if let _ = try? NSRegularExpression(pattern: alignRegex).firstMatch(in: result.string, range: NSRange(location: 0, length: result.length)) {
//            applyParagraphAlignment(to: result)
//        }
//
//        self.attributedText = result
//    }


    func attributedStringFromHTML(_ html: String) {
        let result = NSMutableAttributedString()

        // --- STEP 1: Normalize HTML ---
        let cleanedHTML = html.decodedHTMLEntities
            .replacingOccurrences(of: "\\/", with: "/")
            .replacingOccurrences(of: "<br>", with: "\n")
            .replacingOccurrences(of: "<br/>", with: "\n")
            .replacingOccurrences(of: "<br />", with: "\n")
            .replacingOccurrences(of: "</p>", with: "\n")

        // --- STEP 2: Preprocess lists and paragraphs ---
        let preprocessedHTML = cleanedHTML
            .replacingOccurrences(of: "<ul>", with: "[[ul_start]]")
            .replacingOccurrences(of: "</ul>", with: "[[ul_end]]")
            .replacingOccurrences(of: "<ol>", with: "[[ol_start]]")
            .replacingOccurrences(of: "</ol>", with: "[[ol_end]]")
            // leave attributes inside the marker (we'll parse them below), but ensure it's bracketed
            .replacingOccurrences(of: #"<li([^>]*)>"#, with: "[[li$1]]", options: .regularExpression)
            .replacingOccurrences(of: "</li>", with: "\n")
            .replacingOccurrences(of: #"<p([^>]*)>"#, with: "[[p$1]]", options: .regularExpression)

        var finalHTML = ""
        var insideOrderedList = false
        var olCounter = 1

        let lines = preprocessedHTML.components(separatedBy: "\n")
        for var line in lines {
            // --- Extract alignment from <p> or <li> ---
            if let tagRange = line.range(of: #"\[\[(p|li)([^\]]*)\]\]"#, options: .regularExpression) {
                let tagStr = String(line[tagRange])
                let isLi = tagStr.lowercased().hasPrefix("[[li")
                var alignStrExtracted: String? = nil

                if let alignMatch = tagStr.range(of: #"text-align:\s*(left|center|right|justify)"#, options: .regularExpression) {
                    alignStrExtracted = String(tagStr[alignMatch])
                        .replacingOccurrences(of: "text-align:", with: "")
                        .trimmingCharacters(in: .whitespaces)
                }

                // remove the bracketed tag from the line
                line = line.replacingOccurrences(of: tagStr, with: "")

                // prepend align marker (if any)
                if let alignStr = alignStrExtracted {
                    line = "[[align=\(alignStr)]]" + line
                }

                // IMPORTANT: if this was a <li ...> tag, ensure a plain [[li]] marker exists
                if isLi {
                    // Insert [[li]] right AFTER an existing align marker (if present), otherwise prefix
                    if line.hasPrefix("[[align=") {
                        if let closeRange = line.range(of: "]]") {
                            let insertIndex = closeRange.upperBound
                            line.insert(contentsOf: "[[li]]", at: insertIndex)
                        } else {
                            // fallback
                            line = "[[li]]" + line
                        }
                    } else {
                        line = "[[li]]" + line
                    }
                }
            }

            // --- Handle list start/end ---
            if line.contains("[[ul_start]]") { insideOrderedList = false; line = line.replacingOccurrences(of: "[[ul_start]]", with: "") }
            if line.contains("[[ol_start]]") { insideOrderedList = true; olCounter = 1; line = line.replacingOccurrences(of: "[[ol_start]]", with: "") }
            if line.contains("[[ul_end]]") || line.contains("[[ol_end]]") { insideOrderedList = false; line = line.replacingOccurrences(of: "[[ul_end]]", with: ""); line = line.replacingOccurrences(of: "[[ol_end]]", with: "") }

            // --- Handle <li> items ---
            if line.contains("[[li]]") {
                if insideOrderedList {
                    line = line.replacingOccurrences(of: "[[li]]", with: "\(olCounter). ")
                    olCounter += 1
                } else {
                    line = line.replacingOccurrences(of: "[[li]]", with: "• ")
                }
            }
            finalHTML += line + "\n"
        }

        // --- STEP 3: Regex for inline tags including alignment and links ---
        let pattern = #"(\[\[align=(?:left|center|right|justify)\]\])|<a[^>]*?href="([^"]+)"[^>]*>(.*?)</a>|<(span|strong|em|u|b|i)[^>]*>(.*?)</\4>|([^<\[]+)"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators, .caseInsensitive]) else {
            self.attributedText = NSAttributedString(string: finalHTML)
            return
        }

        let nsHTML = finalHTML as NSString
        var lastLocation = 0
        var pendingAlignment: NSTextAlignment = .left

        for match in regex.matches(in: finalHTML, range: NSRange(location: 0, length: nsHTML.length)) {
            // --- Update alignment from first capture group ---
            let alignMarker = safeGroup(match, 1, in: nsHTML)
            if let align = alignMarker?.replacingOccurrences(of: "[[align=", with: "").replacingOccurrences(of: "]]", with: "") {
                switch align.lowercased() {
                case "center": pendingAlignment = .center
                case "right": pendingAlignment = .right
                case "justify": pendingAlignment = .justified
                default: pendingAlignment = .left
                }
            }

            // Append plain text before match
            if match.range.location > lastLocation {
                let plainText = nsHTML.substring(with: NSRange(location: lastLocation, length: match.range.location - lastLocation))
                let startIndex = result.length
                result.append(NSAttributedString(string: plainText))
                let endIndex = result.length
                if endIndex > startIndex {
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = pendingAlignment
                    result.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: startIndex, length: endIndex - startIndex))
                }
            }

            // --- Determine matched content ---
            let linkHref = safeGroup(match, 2, in: nsHTML)
            var innerText = safeGroup(match, 3, in: nsHTML)
                ?? safeGroup(match, 5, in: nsHTML)
                ?? safeGroup(match, 6, in: nsHTML)
                ?? ""

            innerText = innerText
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .replacingOccurrences(of: "<br>", with: "\n")
                .replacingOccurrences(of: "<br/>", with: "\n")
                .replacingOccurrences(of: "<br />", with: "\n")

            if innerText.isEmpty { lastLocation = match.range.location + match.range.length; continue }

            // --- Default style ---
            var fontName = "Arial"
            var fontSize: CGFloat = 14
            var traits: UIFontDescriptor.SymbolicTraits = []
            var textColor: UIColor = .black
            var bgColor: UIColor? = nil
            var underline = false

            let fullTag = nsHTML.substring(with: match.range(at: 0))
            if let styleMatch = fullTag.range(of: #"style="([^"]*)""#, options: .regularExpression) {
                let styleString = String(fullTag[styleMatch])
                    .replacingOccurrences(of: "style=", with: "")
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                var styleDict: [String: String] = [:]
                styleString.split(separator: ";").forEach { pair in
                    let parts = pair.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
                    if parts.count == 2 { styleDict[parts[0].lowercased()] = parts[1] }
                }
                if let sizeVal = styleDict["font-size"]?.replacingOccurrences(of: "px", with: "").trimmingCharacters(in: .whitespaces), let size = Double(sizeVal) {
                    fontSize = CGFloat(size)
                }
                if let colorVal = styleDict["color"] { textColor = parseCSSColor(colorVal) ?? textColor }
                if let bgVal = styleDict["background-color"] { bgColor = parseCSSColor(bgVal) }
            }

            if let fontMatch = fullTag.range(of: #"ql-font-([A-Za-z0-9]+)"#, options: .regularExpression) {
                let matchStr = String(fullTag[fontMatch])
                fontName = matchStr.replacingOccurrences(of: "ql-font-", with: "").replacingOccurrences(of: "-", with: " ")
            }

            if fontName == "Garamond" { fontName = "EB Garamond" }
            else if fontName == "Courier" || fontName == "CourierNew" { fontName = "Courier New" }
            else if fontName == "TimesNewRoman" { fontName = "Times New Roman" }

            let tagLower = fullTag.lowercased()
            if tagLower.contains("<strong") || tagLower.contains("<b") { traits.insert(.traitBold) }
            if tagLower.contains("<em") || tagLower.contains("<i") { traits.insert(.traitItalic) }
            if tagLower.contains("<u") { underline = true }

            var font: UIFont
            if let customFont = UIFont(name: fontName, size: fontSize) { font = customFont }
            else { font = UIFont.systemFont(ofSize: fontSize) }
            if let descriptor = font.fontDescriptor.withSymbolicTraits(traits) { font = UIFont(descriptor: descriptor, size: fontSize) }

            var attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: textColor]
            if let bg = bgColor { attrs[.backgroundColor] = bg }
            if underline { attrs[.underlineStyle] = NSUnderlineStyle.single.rawValue }
            if let href = linkHref, let url = URL(string: href) { attrs[.link] = url }

            let startIndex = result.length
            result.append(NSAttributedString(string: innerText, attributes: attrs))
            let endIndex = result.length

            // --- Apply alignment & bullet/number indent ---
            if endIndex > startIndex {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = pendingAlignment
                if innerText.hasPrefix("•") {
                    paragraphStyle.headIndent = 15
                    paragraphStyle.firstLineHeadIndent = 0
                } else if let _ = innerText.range(of: #"^\d+\.\s"#, options: .regularExpression) {
                    paragraphStyle.headIndent = 20
                    paragraphStyle.firstLineHeadIndent = 0
                }
                result.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: startIndex, length: endIndex - startIndex))
            }

            lastLocation = match.range.location + match.range.length
        }

        // Append trailing text
        if lastLocation < nsHTML.length {
            let trailing = nsHTML.substring(from: lastLocation)
            let startIndex = result.length
            result.append(NSAttributedString(string: trailing))
            let endIndex = result.length
            if endIndex > startIndex {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = pendingAlignment
                result.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: startIndex, length: endIndex - startIndex))
            }
        }

        self.attributedText = result
    }






    func applyParagraphAlignment(to result: NSMutableAttributedString) {
        let fullText = result.string as NSString
        
        fullText.enumerateSubstrings(in: NSRange(location: 0, length: fullText.length),
                                     options: .byParagraphs) { (_, paragraphRange, _, _) in
            // Extract current paragraph style or create new
            let style = (result.attribute(.paragraphStyle, at: paragraphRange.location, effectiveRange: nil) as? NSMutableParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
            style.alignment = .left

            // Get substring for this paragraph
            let substring = fullText.substring(with: paragraphRange)
            var cleaned = substring
            
            // Detect alignment marker
            if cleaned.contains("[[align=center]]") {
                style.alignment = .center
                cleaned = cleaned.replacingOccurrences(of: "[[align=center]]", with: "")
            } else if cleaned.contains("[[align=right]]") {
                style.alignment = .right
                cleaned = cleaned.replacingOccurrences(of: "[[align=right]]", with: "")
            } else if cleaned.contains("[[align=justify]]") {
                style.alignment = .justified
                cleaned = cleaned.replacingOccurrences(of: "[[align=justify]]", with: "")
            }
            
            // Replace text without losing attributes
            result.replaceCharacters(in: paragraphRange, with: cleaned)
            result.addAttribute(.paragraphStyle, value: style, range: NSRange(location: paragraphRange.location, length: (cleaned as NSString).length))
        }
    }



}

func parseCSSColor(_ val: String) -> UIColor? {
   
    let v                                           = val.trimmingCharacters(in: .whitespaces).lowercased()
    
    if v.hasPrefix("rgb") {
        
        let numbers                                 = v.replacingOccurrences(of: "rgba", with: "")
                                                        .replacingOccurrences(of: "rgb", with: "")
                                                        .replacingOccurrences(of: "(", with: "")
                                                        .replacingOccurrences(of: ")", with: "")
                                                        .split { $0 == "," || $0 == " " }
                                                        .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        if numbers.count >= 3 {
            
            return UIColor(red: CGFloat(numbers[0]) / 255.0,
                           green: CGFloat(numbers[1]) / 255.0,
                           blue: CGFloat(numbers[2]) / 255.0,
                           alpha: numbers.count == 4 ? CGFloat(numbers[3]) : 1)
        }
    }
    else if v.hasPrefix("#") {
        
        return UIColor(hexString: v)
    }
    else {
        
        return UIColor(cssName: v)
    }
    return nil
}
func safeGroup(_ match: NSTextCheckingResult, _ index: Int, in nsHTML: NSString) -> String? {
    guard index < match.numberOfRanges else { return nil }
    let r = match.range(at: index)
    guard r.location != NSNotFound, NSMaxRange(r) <= nsHTML.length else { return nil }
    return nsHTML.substring(with: r)
}

extension String {
    
    var decodedHTMLEntities: String {
        var text = self
        
        let entities: [String: String] = [
            "&nbsp;": " ",
            "&lt;": "<",
            "&gt;": ">",
            "&amp;": "&",
            "&quot;": "\"",
            "&#39;": "'"
        ]
        
        for (entity, character) in entities {
            text = text.replacingOccurrences(of: entity, with: character)
        }
        
        // Remove invisible zero-width characters if any
        text = text.replacingOccurrences(of: "\u{200B}", with: "")
        
        return text
    }
    
    var cleanedHTML: String {
            var text = self
            
            // Remove stray closing tags like </span> or </div> at the end
            let pattern = #"</(span|div|p|b|i|u)>"#
            text = text.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
            
            // Optional: decode HTML entities
            text = text.decodedHTMLEntities
            
            return text
        }
}
