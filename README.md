# iOS Rich Text Editor (Swift)

A reusable rich text editor for iOS with support for **bold**, *italic*, underline, font styling, and HTML export.

---

## 🚀 Features

* Apply **bold**, *italic*, and underline
* Change font family and size
* Text color and background color support
* Export formatted content as HTML
* Built using `UITextView` and `NSAttributedString`

---

## 📱 Here

<img width="1536" height="1024" alt="img" src="https://github.com/user-attachments/assets/459acee4-9a15-4d66-aa41-05375c93d9cb" />

Rich text editor supporting:

* Bold, Italic, Underline
* Font selection (e.g., Trebuchet MS, Georgia)
* Font size control
* Color styling
* HTML export

---

## 🧠 How It Works

This editor uses **NSAttributedString** to manage styled text.

Instead of plain text:

* text is stored with attributes
* styles are applied to selected ranges
* updates are reflected dynamically

---

## 🧩 Example

```swift
DispatchQueue.main.async {
  self.noteTextView.attributedStringFromHTML(txt)
}
```

---

## ⚙️ Usage

1. Add a `UITextView`
2. Track selected range:

```swift
textView.selectedRange
```

3. Apply formatting using attributes

---

## 💡 Use Cases

* Notes apps
* Chat editors
* Content creation tools
* Rich input forms

---

## 🔗 Medium Article

Read full explanation here:
👉 https://medium.com/@manpreet.s_92558/how-to-build-a-rich-text-editor-in-ios-bold-italic-formatting-in-swift-f80f15ad8c08

---

## ✍️ Author

Built with 💙 by Manpreet Singh
