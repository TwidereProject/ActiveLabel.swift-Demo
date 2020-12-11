//
//  ViewController.swift
//  ActiveLabel-Demo
//
//  Created by Cirno MainasuK on 2020-12-10.
//

import UIKit
import ActiveLabel
import twitter_text

class ViewController: UIViewController {

    let label = ActiveLabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Demo"
        
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
        
        let tweet = "RT @username: Hello 你好 こんにちは 😂😂😂 #hashtag https://twitter.com/ABCDEFG"
        let tweetParseResults = ViewController.parse(tweet: tweet)
        label.delegate = self
        label.numberOfLines = 0
        label.URLColor = .systemRed
        label.mentionColor = .systemGreen
        label.hashtagColor = .systemBlue
        label.text = tweetParseResults.trimmedTweet
        label.activeEntities = tweetParseResults.activeEntities
    }

}

extension ViewController {
    
    struct TweetParseResult {
        let originalTweet: String
        let trimmedTweet: String
        let activeEntities: [ActiveEntity]
    }
    
    static func parse(tweet: String) -> TweetParseResult {
        var activeEntities: [ActiveEntity] = []
        let twitterTextEntities = TwitterText.entities(inText: tweet)
        for twitterTextEntity in twitterTextEntities {
            switch twitterTextEntity.type {
            case .URL:
                if let text = tweet.string(in: twitterTextEntity.range) {
                    let trimmed = text.trim(to: 24)
                    activeEntities.append(ActiveEntity(range: twitterTextEntity.range, type: .url(original: text, trimmed: trimmed)))
                }
            case .hashtag:
                if let text = tweet.string(in: twitterTextEntity.range) {
                    activeEntities.append(ActiveEntity(range: twitterTextEntity.range, type: .hashtag(text)))
                }
            case .screenName:
                if let text = tweet.string(in: twitterTextEntity.range) {
                    activeEntities.append(ActiveEntity(range: twitterTextEntity.range, type: .mention(text)))
                }
            default:
                continue
            }
        }
        
        var trimmedTweet = tweet
        for activeEntity in activeEntities {
            guard case .url = activeEntity.type else { continue }
            trimEntity(tweet: &trimmedTweet, activeEntity: activeEntity, activeEntities: activeEntities)
        }
        
        return TweetParseResult(
            originalTweet: tweet,
            trimmedTweet: trimmedTweet,
            activeEntities: activeEntities
        )
    }
    
    static func trimEntity(tweet: inout String, activeEntity: ActiveEntity, activeEntities:  [ActiveEntity]) {
        guard case let .url(original, trimmed) = activeEntity.type else { return }
        guard let index = activeEntities.firstIndex(where: { $0.range == activeEntity.range }) else { return }
        guard let range = Range(activeEntity.range, in: tweet) else { return }
        tweet.replaceSubrange(range, with: trimmed)
        
        let offset = trimmed.count - original.count
        activeEntity.range.length += offset
        
        let moveActiveEntities = Array(activeEntities[index...].dropFirst())
        for moveActiveEntity in moveActiveEntities {
            moveActiveEntity.range.location += offset
        }
    }
    
}

// MARK: - ActiveLabelDelegate
extension ViewController: ActiveLabelDelegate {
    func didSelectEntity(_ entity: ActiveEntity) {
        print(entity.primaryText)
    }
}

extension String {
    func string(in nsrange: NSRange) -> String? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return String(self[range])
    }
}
