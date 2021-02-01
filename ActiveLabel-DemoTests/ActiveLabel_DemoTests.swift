//
//  ActiveLabel_DemoTests.swift
//  ActiveLabel-DemoTests
//
//  Created by MainasuK Cirno on 2021/2/1.
//

import XCTest
import Kanna
@testable import ActiveLabel_Demo

class ActiveLabel_DemoTests: XCTestCase {

    func testParseNode() throws {
        let rootNode = try TootContent.Node.parse(document: stubHTML)
    
        print("--- Tree ---")
        debugPrint(rootNode)
        
        print("--- hashtag ---")
        for hashtag in TootContent.Node.hashtags(in: rootNode) {
            let line = String(
                format: "%@: %@",
                String(hashtag.text),
                hashtag.href ?? "nil"
            )
            print(line)
        }
        
        print("--- mention ---")
        for url in TootContent.Node.mentions(in: rootNode) {
            let line: String = String(
                format: "%@: %@",
                String(url.text),
                url.href ?? "nil"
            )
            print(line)
        }
        
        
        print("--- urls ---")
        for url in TootContent.Node.urls(in: rootNode) {
            let line: String = String(
                format: "%@: %@(%@)",
                String(url.text),
                url.hrefEllipsis ?? "nil",
                url.href ?? "nil"
            )
            print(line)
        }
    }
    
    let stubHTML: String = """
    <p><a href="https://example.com/tags/tag1" class="mention hashtag" rel="nofollow noopener noreferrer" target="_blank">#<span>Tag1</span></a> Line 1<br/>Line 2 <a href="https://example.com/tags/tag2" class="mention hashtag" rel="nofollow noopener noreferrer" target="_blank">#<span>Tag2</span></a> <a href="https://example.com/some/path/here/123456/" rel="nofollow noopener noreferrer" target="_blank"><span class="invisible">https://</span><span class="ellipsis">example.com/some/path/</span><span class="invisible">here/123456/</span></a><br/><span>Line 3</span><br/><span class="h-card"><a class="u-url mention" href="https://example.com/users/@username" rel="nofollow noopener noreferrer" target="_blank">@<span>username</span></a></span>，Hello :ablobattention:</p>
    """

}
