# GithubKitForSample

This is simple Github API client and UI for using in sample projects.

## Requirements

- Xcode 8.3.3
- Swift 3.1
- iOS 9.0
- carthage 0.23.0
- [RxSwift](https://github.com/ReactiveX/RxSwift) 3.6.1
- [SwiftIconFont](https://github.com/0x73/SwiftIconFont) 2.7.0
- [Nuke](https://github.com/kean/Nuke) 5.1.1

## Installation

You can install via Carthage.

```ruby: Cartfile
github "marty-suzuki/GithubKitForSample"
```
## Usage

```swift
import GithubKit

ApiSession.shared.token = "/* Your Token */"

/// - note: You can search users.
let request = SearchUserRequest(query: "marty-suzuki", after: nil)
ApiSession.shared.send(request) {
    switch $0 {
    case .success(let value):
        //
    case .failure(let error):
        //
    }
}

/// - note: You can fetch user's repositories.
let request = UserNodeRequest(id: user.id, after: nil)
ApiSession.shared.send(request) {
    switch $0 {
    case .success(let value):
        //
    case .failure(let error):
        //
    }
}
```

## Layout

### UserViewCell
![user](./Images/image1.png)

### RepositoryViewCell
![repository](./Images/image2.png)
