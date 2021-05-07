//
//  ViewController.swift
//  ActiveLabel-Demo
//
//  Created by Cirno MainasuK on 2020-12-10.
//

import UIKit
import ActiveLabel
import Kanna
import AlamofireImage
import twitter_text

class ViewController: UIViewController {

    let tweetContentLabel = ActiveLabel()
    let tootContentLabel = ActiveLabel()
    
    static let emojiDict: MastodonStatusContent.EmojiDict = [
        ":apple_inc": URL(string: "https://media.mstdn.jp/custom_emojis/images/000/002/171/original/b848520ba07a354c.png")!,
        ":awesome:": URL(string: "https://media.mstdn.jp/custom_emojis/images/000/002/757/original/3e0e01274120ad23.png")!
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Demo"
        
        tweetContentLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tweetContentLabel)
        NSLayoutConstraint.activate([
            tweetContentLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 8),
            tweetContentLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            tweetContentLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
        
        tootContentLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tootContentLabel)
        NSLayoutConstraint.activate([
            tootContentLabel.topAnchor.constraint(equalTo: tweetContentLabel.bottomAnchor, constant: 16),
            tootContentLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            tootContentLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
        
        let tweet = "Tweet: \n@username: Hello 你好 こんにちは 😂😂😂 #hashtag https://twitter.com/ABCDEFG"
        let tweetParseResults = TweetContent.parse(tweet: tweet)
        tweetContentLabel.delegate = self
        tweetContentLabel.numberOfLines = 0
        tweetContentLabel.URLColor = .systemRed
        tweetContentLabel.mentionColor = .systemGreen
        tweetContentLabel.hashtagColor = .systemBlue
        tweetContentLabel.text = tweetParseResults.trimmedTweet
        tweetContentLabel.activeEntities = tweetParseResults.activeEntities
        
        let toot = """
        <p>Toot:<br/><span class="h-card"><a class="u-url mention" href="https://example.com/users/@username" rel="nofollow noopener noreferrer" target="_blank">@<span>username</span></a></span> Hello 你好 こんにちは 😂😂:awesome:<a href="https://mstdn.jp/tags/hashtag" class="mention hashtag" rel="tag">#<span>hashtag</span></a> <a href="https://example.com/ABCDEFG/2021/02/01" rel="nofollow noopener noreferrer" target="_blank"><span class="invisible">https://</span><span class="ellipsis">example.com/ABCDEFG/</span><span class="invisible">2021/02/01</span></a></p>
        """
        if let parseResult = try? MastodonStatusContent.parse(content: toot, emojiDict: ViewController.emojiDict) {
            tootContentLabel.delegate = self
            tootContentLabel.numberOfLines = 0
            tootContentLabel.URLColor = .systemRed
            tootContentLabel.mentionColor = .systemGreen
            tootContentLabel.hashtagColor = .systemBlue
            tootContentLabel.emojiPlaceholderColor = .systemFill
            tootContentLabel.text = parseResult.trimmed
            tootContentLabel.activeEntities = parseResult.activeEntities
            
            
        }

    }

}

// MARK: - ActiveLabelDelegate
extension ViewController: ActiveLabelDelegate {
    func activeLabel(_ activeLabel: ActiveLabel, didSelectActiveEntity entity: ActiveEntity) {
        print(entity.primaryText)
    }
}

extension String {
    func string(in nsrange: NSRange) -> String? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return String(self[range])
    }
}
