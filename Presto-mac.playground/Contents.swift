import Presto
import AppKit
import WebKit
import PlaygroundSupport

let webview = WKWebView(frame: NSRect(x: 0, y: 0, width: 300, height: 400))
let markdown = """
    But, *this* is **my** h\\abrevetml and an \\abreve symbol which ă is.
    I don't know

    - How to do this.
    - Why to do this.

    Do you?
    """

let result1 = markdown.html
webview.loadHTMLString(result1, baseURL: nil)
PlaygroundPage.current.liveView = webview

let attributedString = markdown.attributedString

let tv = NSTextField(labelWithAttributedString: attributedString)
//PlaygroundPage.current.liveView = tv

let render = Cmark(markdown).renderHTMLEntities()
dump(render)
let html = try? render.renderHtml()
dump(html!)

let result = try? Cmark(markdown).renderAttributedString()
let textfield = NSTextField(labelWithAttributedString: result!)



