# ConnectKit

A Swift client for Infinite Flight's Connect APIs, built using the Network framework.

#### Supported APIs
* IF Session Discovery
* Connect API V2
* OpenTrack
* ForeFlight

#### Supported targets
| MacOS | Mac Catalyst | iOS | tvOS |
|-------|--------------|-----|------|
| 10.14 | 13           | 12  | 12   |

#### Package structure:
| Module       | Prefix | Description                                   |
| ------------ | ------ | --------------------------------------------- |
| `ConnectV2`  | `C2`   | Client for Connect V2 API                     |
| `OpenTrack`  | `OT`   | Client for sending OpenTrack broadcasts       |
| `ForeFlight` | `FF`   | Client for listening to ForeFlight broadcasts |
| `ConnectKit` | `--`   | Imports all of the modules above              |

Along with that, all packages include common components, prefixed with `IF`, such as `IFListener` used for discovering Infinite Flight sessions. If, for some reason, you want to specifically import only that functionality, you can import `_ConnectKitCommon`.

## Getting started

#### Installation

if you're using XCode 11+, you can add ConnectKit as a dependency by clicking File -> Swift Packages -> Add Package Dependency and entering `https://github.com/sqeezelemon/ConnectKit.git`.

Alternatively, you can add it to your `Package.swift` file as follows:
```swift
dependencies: [
    // Add to your dependencies
    .package(url: "https://github.com/sqeezelemon/ConnectKit.git", from: "1.0.0")
]
...
.target(name: "YourTarget", dependencies: [
    // And then add to your target
    .product(name: "ConnectKit", package: "SwiftyLiveApi")
],
```

#### Discovering sessions

```swift
// 1. Create the listener
let listener = IFListener()

// 2. Add a sessionHandler
listener.sessionHandler = { (session) in 
    print($0.ipv4) // IFSession.ipv4
    listener.stop()
}

// 3. Start the listener
listener.start()
```

#### Using Connect V2 API

```swift
import ConnectV2 // or ConnectKit

// 1. Create the client
let client = C2Client()

// 2. Implement a delegate to receive data
class MyDelegate: C2ClientDelegate { ... }
let delegate = MyDelegate(...)
client.delegate = delegate

// 3. Connect to an Infinite Flight session
client.connect(to: ip)

// 4. Start using
if let id = client.findState(by: "aircraft/0/altitude_agl")?.id {
    client.get(50)
}

// 5. When finished, disconnect from IF.
client.disconnect()
```

#### Sending OpenTrack broadcasts

```swift
import OpenTrack // or ConnectKit

// 1. Create the client
let client = OTClient()

// 2. Connect to an Infinite Flight session
client.connect(to: ip)

// 3. Start using
client.send(x: x, y: y, z: z,
            roll: roll, pitch: pitch, yaw: yaw)

// 4. When finished, disconnect from IF.
client.disconnect()
```

#### Listening to ForeFlight broadcasts

```swift
import ForeFlight // or ConnectKit

// 1. Create the client
let listener = FFListener()

// 2. Implement a delegate to receive data
class MyDelegate: FFListenerDelegate { ... }
let delegate = MyDelegate(...)
listener.delegate = delegate

// 3. Start listening to broadcasts
listener.start()

// 4. When finished, stop the client.
listener.stop()
```

***

#### Bugs and enhancements
If you encounter a bug, please file an issue with the reproduction steps and any other information you consider helpful.
If you want to suggest a change to the package, please make an issue with your proposal.

#### Contacts
[**@sqeezelemon** on IFC](https://community.infiniteflight.com/u/sqeezelemon)