# CryptoCheck

## Installation

### Pre-requisites

The developer must have [git](https://git-scm.com/downloads) and [XCode](https://apps.apple.com/us/app/xcode/id497799835?mt=12/) installed on a Mac computer to be able to run this project.

Go to the [Repository](https://github.com/leonardofs88/cryptoCheck) page and clone the project

## Run

After the project is cloned, it's just necessary to open the **CryptoCheck.xcodeproj**. 

> **_NOTE 1:_**  To be fully able to build the product, the developer must assure that the current branch is **main**.
> **_NOTE 3:_**  To be fully able to build the product, the developer must change the **Team** at **Signing & Capabilities** on the target's configuration.

##### CryptoCheck

The purpose of this app is to check live prices of cryptocurrencies with [Binance](https://developers.binance.com/docs/binance-spot-api-docs/web-socket-streams) Websocket.

## External Libraries

For helping the app development, this project uses two external libraries.

### Swiftlint

This library is responsible to give warnings on the IDE for the developer keeps the code clean and maintanable. You can check more in [SwiftLint](https://github.com/realm/SwiftLint)

### Factory

For helping with dependency injection, the project uses Factory. It uses the container approach with easy application, testable and also with support for SwiftUI. More information at [Factory](https://github.com/hmlongco/Factory)

### SnapKit

Usualy used to help with View Code. For more info, [SnapKit](https://github.com/SnapKit/SnapKit)

### Alamofire

Good alternative for URLSessions, in the project, was used to check app's reachability. For more, check in [Alamofire](https://github.com/Alamofire/Alamofire)

## Native Libraries

The project also uses **Combine** to help fetching data in a thread safe mode, **URLSessionWebSocketTask** to communicate with the websocket endpoint, and uses **UIKit** with view code framework to create the app's views.

## AI Usage

For helping development, it was used ChatGPT to generate some code that was based and adapted in the project.

One good example was when having the payload for the web socket response, AI helped to create the model quickly:

```json
{
  "e": "24hrTicker",  // Event type
  "E": 1672515782136, // Event time
  "s": "BNBBTC",      // Symbol
  "p": "0.0015",      // Price change
  "P": "250.00",      // Price change percent
  "w": "0.0018",      // Weighted average price
  "x": "0.0009",      // First trade(F)-1 price (first trade before the 24hr rolling window)
  "c": "0.0025",      // Last price
  "Q": "10",          // Last quantity
  "b": "0.0024",      // Best bid price
  "B": "10",          // Best bid quantity
  "a": "0.0026",      // Best ask price
  "A": "100",         // Best ask quantity
  "o": "0.0010",      // Open price
  "h": "0.0025",      // High price
  "l": "0.0010",      // Low price
  "v": "10000",       // Total traded base asset volume
  "q": "18",          // Total traded quote asset volume
  "O": 0,             // Statistics open time
  "C": 86400000,      // Statistics close time
  "F": 0,             // First trade ID
  "L": 18150,         // Last trade Id
  "n": 18151          // Total number of trades
}
````

to 

```swift
struct PriceModel: Codable, Identifiable {
    let eventType: String         // "e"
    let eventTime: Date           // "E"
    let symbol: String            // "s"
    let priceChange: String       // "p"
    let priceChangePercent: String // "P"
    let weightedAvgPrice: String  // "w"
    let firstTradePrice: String   // "x"
    let lastPrice: String         // "c"
    let lastQuantity: String      // "Q"
    let bestBidPrice: String      // "b"
    let bestBidQuantity: String   // "B"
    let bestAskPrice: String      // "a"
    let bestAskQuantity: String   // "A"
    let openPrice: String         // "o"
    let highPrice: String         // "h"
    let lowPrice: String          // "l"
    let baseVolume: String        // "v"
    let quoteVolume: String       // "q"
    let openTime: Date            // "O"
    let closeTime: Date           // "C"
    let firstTradeId: Int         // "F"
    let lastTradeId: Int          // "L"
    let tradeCount: Int           // "n"

    var id: String { symbol } // helpful for SwiftUI

    enum CodingKeys: String, CodingKey {
        case eventType = "e"
        case eventTime = "E"
        case symbol = "s"
        case priceChange = "p"
        case priceChangePercent = "P"
        case weightedAvgPrice = "w"
        case firstTradePrice = "x"
        case lastPrice = "c"
        case lastQuantity = "Q"
        case bestBidPrice = "b"
        case bestBidQuantity = "B"
        case bestAskPrice = "a"
        case bestAskQuantity = "A"
        case openPrice = "o"
        case highPrice = "h"
        case lowPrice = "l"
        case baseVolume = "v"
        case quoteVolume = "q"
        case openTime = "O"
        case closeTime = "C"
        case firstTradeId = "F"
        case lastTradeId = "L"
        case tradeCount = "n"
    }
}
```


# Conclusion

I'd like to thank you for the challenge. I regret that I had many technical issues and due to the complexity of the code, I wish I could have done more testing and fixing issues with the websocket, as well as creating a much better UI. 

Finally, I hope that what I've done is good enough, because I had a really good time!

My contacts are:

[GitHub](https://github.com/leonardofs88/)
leonardofs88@live.com

