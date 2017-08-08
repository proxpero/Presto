import Presto
import UIKit

let markdown = "This is *my* html."
let cmark = CMark(markdown)
let result = try cmark.toHtml()

