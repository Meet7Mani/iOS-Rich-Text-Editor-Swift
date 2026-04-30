
import Foundation
import UIKit

extension NSAttributedString {
    
    ///To generating Inline HTML
    func attributedStringToInlineHTML() -> String {
        
        let htmlRaw                                 = exportStyledHTML(from: self)
        print("Final Quill-style HTML: \(htmlRaw)")
        return htmlRaw
    }
    
    // Helper: Exports inline styles for a given attributed string
    func exportStyledHTML(from attributed: NSAttributedString) -> String {
        
        
        var html                                    = ""
        var insideListType                          : String? = nil // "ol" or "ul"
        
        // Split by paragraph (using newline characters)
        let fullText                                = attributed.string as NSString
        let paragraphs                              = fullText.components(separatedBy: CharacterSet.newlines)
                                    
        var location                                = 0
        for paragraph in paragraphs {
            
            let length = paragraph.utf16.count
            if location >= attributed.length { break } // prevent out-of-bounds
            
            var paragraphRange                      = NSRange(location: location, length: length)
            
            
            // Clamp to the actual attributed length
            if paragraphRange.upperBound > attributed.length {
                
                paragraphRange.length = attributed.length - paragraphRange.location
            }
            
            guard paragraphRange.length > 0 else {
                // Skip empty safely
                location += length
                if location < attributed.length,
                   (fullText.character(at: location) == "\n".utf16.first!) {
                    location += 1
                }
                continue
            }
            
            
            // Build HTML for this paragraph from attributed runs
            var paragraphHTML                       = ""
            attributed.enumerateAttributes(in: paragraphRange, options: []) { attributes, range, _ in
                
                let substring                       = attributed.attributedSubstring(from: range).string
                paragraphHTML += styledHTML(for: substring, attributes: attributes)
            }
            
            let trimmedPlain                        = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // --- Unordered list (•) ---
            if trimmedPlain.hasPrefix("•") {
               
                if insideListType != "ul" {
                   
                    if let type = insideListType {
                       
                        html += "</\(type)>"
                    }
                    html += "<ul>"
                    insideListType                  = "ul"
                }
                let paragraphStyle = attributed.attribute(.paragraphStyle, at: paragraphRange.location, effectiveRange: nil) as? NSParagraphStyle
                    let alignStyle: String
                    switch paragraphStyle?.alignment {
                    case .center: alignStyle = "center"
                    case .right: alignStyle = "right"
                    case .justified: alignStyle = "justify"
                    default: alignStyle = "left"
                    }
                // remove only the bullet char
//                let textWithoutBullet = String(paragraphHTML.dropFirst())
//                html += "<li>\(textWithoutBullet)</li>"
                // Remove the bullet (•) and any following spaces while preserving attributes
                var cleanedHTML = ""
                attributed.enumerateAttributes(in: paragraphRange, options: []) { attributes, range, _ in
                    let substring = attributed.attributedSubstring(from: range).string
                    // Remove leading bullet and optional spaces using regex
                    let cleanedSub = substring.replacingOccurrences(of: #"^•\s*"#,
                                                                    with: "",
                                                                    options: .regularExpression)
                    cleanedHTML += styledHTML(for: cleanedSub, attributes: attributes)
                }
                
                //html += "<li>\(cleanedHTML)</li>"
                html += "<li style=\"text-align:\(alignStyle)\">\(cleanedHTML)</li>"
            }
            // --- Ordered list (number + dot) ---
            else if let numberMatch = trimmedPlain.split(separator: ".").first, Int(numberMatch) != nil {
                
                if insideListType != "ol" {
                   
                    if let type = insideListType {
                       
                        html += "</\(type)>"
                    }
                    html += "<ol>"
                    insideListType = "ol"
                }
                // remove the "1. " or "2. " prefix completely
                var cleanedHTML                     = ""
                attributed.enumerateAttributes(in: paragraphRange, options: []) { attributes, range, _ in
                    
                    let substring                   = attributed.attributedSubstring(from: range).string
                    let cleanedSub                  = substring.replacingOccurrences(of: #"^\d+\.\s*"#,
                                                                                     with: "",
                                                                                     options: .regularExpression)
                    cleanedHTML += styledHTML(for: cleanedSub, attributes: attributes)
                }
                html += "<li>\(cleanedHTML)</li>"
            }
            // --- Normal paragraph ---
            else {
                if let type = insideListType {
                    
                    html += "</\(type)>"
                    insideListType = nil
                }
                // Paragraph alignment
                if let style = attributed.attribute(.paragraphStyle, at: paragraphRange.location, effectiveRange: nil) as? NSParagraphStyle {
                    
                    switch style.alignment {
                    case .center:
                        html += "<p style=\"text-align:center\">\(paragraphHTML)</p>"
                    case .right:
                        html += "<p style=\"text-align:right\">\(paragraphHTML)</p>"
                    case .justified:
                        html += "<p style=\"text-align:justify\">\(paragraphHTML)</p>"
                    default:
                        html += "<p>\(paragraphHTML)</p>"
                    }
                }
                else {
                    html += "<p>\(paragraphHTML)</p>"
                }
            }
            
            location += length
            if location < attributed.length,
               (fullText.character(at: location) == "\n".utf16.first!) {
                location += 1
            }
        }
        // Close final list if still open
        if let type = insideListType {
            html += "</\(type)>"
        }
        return html
    }
    
    private func styledHTML(for text: String, attributes: [NSAttributedString.Key: Any]) -> String {
        
        var outerTags                               : [(open: String, close: String)] = []
        var styleParts                              : [String] = []
        var classParts                              : [String] = []
        
        // Link outermost
        if let link = attributes[.link] {
            
            outerTags.append(("<a href=\"\(link)\">", "</a>"))
        }
        // Font + traits
        if let font = attributes[.font] as? UIFont {
           
            let traits                              = font.fontDescriptor.symbolicTraits
            if traits.contains(.traitBold) {
                
                outerTags.append(("<strong>", "</strong>"))
            }
            if traits.contains(.traitItalic) {
               
                outerTags.append(("<em>", "</em>"))
            }
            
            styleParts.append("font-size:\(Int(font.pointSize))px")
            
            var quillFontName                       = font.familyName.replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "-", with: "")
            
            if quillFontName == "EBGaramond" {
                
                quillFontName                       = "Garamond"
            }
            classParts.append("ql-font-\(quillFontName)")
        }
        
        // Underline
        if let underline = attributes[.underlineStyle] as? Int, underline != 0 {
            
            outerTags.append(("<u>", "</u>"))
        }
        
        // Colors
        if let textColor = attributes[.foregroundColor] as? UIColor {
            
            styleParts.append("color:\(rgbString(from: textColor))")
        }
        if let bgColor = attributes[.backgroundColor] as? UIColor {
            
            styleParts.append("background-color:\(rgbString(from: bgColor))")
        }
        
        // Span wrapper for styles/classes
        if !styleParts.isEmpty || !classParts.isEmpty {
            
            let styleAttr                           = styleParts.isEmpty ? "" : " style=\"\(styleParts.joined(separator: "; "))\""
            let classAttr                           = classParts.isEmpty ? "" : " class=\"\(classParts.joined(separator: " "))\""
            outerTags.append(("<span\(styleAttr)\(classAttr)>", "</span>"))
        }
        
        let safeText                                = text.replacingOccurrences(of: "\n", with: "<br>")
        return outerTags.map { $0.open }.joined() + safeText + outerTags.reversed().map { $0.close }.joined()
    }
    
    func rgbString(from color: UIColor) -> String {
       
        var red                                     : CGFloat = 0
        var green                                   : CGFloat = 0
        var blue                                    : CGFloat = 0
        
        // Force resolve dynamic color (for trait environments)
        let resolvedColor                           = color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        
        if resolvedColor.getRed(&red, green: &green, blue: &blue, alpha: nil) {
            
            let r                                   = Int(red * 255)
            let g                                   = Int(green * 255)
            let b                                   = Int(blue * 255)
            return "rgb(\(r), \(g), \(b))"
        }
        else {
            // Fallback to black if RGB extraction fails
            return "rgb(0, 0, 0)"
        }
    }
}
