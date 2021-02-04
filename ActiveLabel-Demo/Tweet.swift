//
//  TweetContent.swift
//  ActiveLabel-Demo
//
//  Created by MainasuK Cirno on 2021/2/1.
//

import Foundation
import ActiveLabel
import twitter_text

enum TweetContent {
    
    static func parse(tweet: String) -> ParseResult {
        var activeEntities: [ActiveEntity] = []
        let twitterTextEntities = TwitterText.entities(inText: tweet)
        for twitterTextEntity in twitterTextEntities {
            switch twitterTextEntity.type {
            case .URL:
                if let text = tweet.string(in: twitterTextEntity.range) {
                    let trimmed = text.trim(to: 24)
                    activeEntities.append(ActiveEntity(range: twitterTextEntity.range, type: .url(text, trimmed: trimmed, url: text)))
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
        
        return ParseResult(
            originalTweet: tweet,
            trimmedTweet: trimmedTweet,
            activeEntities: activeEntities
        )
    }

    static func trimEntity(tweet: inout String, activeEntity: ActiveEntity, activeEntities: [ActiveEntity]) {
        guard case let .url(text, trimmed, _, _) = activeEntity.type else { return }
        guard let index = activeEntities.firstIndex(where: { $0.range == activeEntity.range }) else { return }
        guard let range = Range(activeEntity.range, in: tweet) else { return }
        tweet.replaceSubrange(range, with: trimmed)
        
        let offset = trimmed.count - text.count
        activeEntity.range.length += offset
        
        let moveActiveEntities = Array(activeEntities[index...].dropFirst())
        for moveActiveEntity in moveActiveEntities {
            moveActiveEntity.range.location += offset
        }
    }

}

extension TweetContent {
    struct ParseResult {
        let originalTweet: String
        let trimmedTweet: String
        let activeEntities: [ActiveEntity]
    }
}
