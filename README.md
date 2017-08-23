![Logo](./Images/Logo.png)

# FluxCapacitor

[![Build Status](https://www.bitrise.io/app/da28e1f04e6fe024/status.svg?token=bvDkmuaRPMxKy8BewHLGzA)](https://www.bitrise.io/app/da28e1f04e6fe024)
[![Build Status](https://travis-ci.org/marty-suzuki/FluxCapacitor.svg?branch=master)](https://travis-ci.org/marty-suzuki/FluxCapacitor)
[![Version](https://img.shields.io/cocoapods/v/FluxCapacitor.svg?style=flat)](http://cocoapods.org/pods/FluxCapacitor)
[![License](https://img.shields.io/cocoapods/l/FluxCapacitor.svg?style=flat)](http://cocoapods.org/pods/FluxCapacitor)
[![Platform](https://img.shields.io/cocoapods/p/FluxCapacitor.svg?style=flat)](http://cocoapods.org/pods/FluxCapacitor)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

FluxCapacitor makes implementing [Flux](https://facebook.github.io/flux/) design pattern easily with protocols and typealias.

- Storable protocol
- Actionable protocol
- DispatchValue protocol

## Requirements

- Swift 3.1 or later
- iOS 9.0 or later

## Installation

### CocoaPods

FluxCapacitor is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "FluxCapacitor"
```

### Carthage

If you’re using [Carthage](https://github.com/Carthage/Carthage), simply add FluxCapacitor to your `Cartfile`:

```ruby
github "marty-suzuki/FluxCapacitor"
```

## Usage

This is ViewController sample that uses Flux design pattern. If ViewController calls fetchRepositories method of RepositoryAction, it is reloaded automatically with subscribe method of RepositoryStore after fetched repositories from Github. Introducing how to implement Flux design pattern with **FluxCapacitor**.

```swift
final class UserRepositoryViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private let repositoryAction = RepositoryAction()
    private let repositoryStore = RepositoryStore.instantiate()
    private let userStore = UserStore.instantiate()
    private let dustBuster = DustBuster()
    private let dataSource = UserRepositoryViewDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.configure(with: tableView)
        observeStore()

        if let user = userStore.selectedUser {
            repositoryAction.fetchRepositories(withUserId: user.id, after: nil)
        }
    }

    private func observeStore() {
        repositoryStore.subscribe { [weak self] changes in
            DispatchQueue.main.async {
                switch changes {
                case .addRepositories,
                     .removeAllRepositories,
                     .isRepositoryFetching:
                    self?.tableView.reloadData()
                }
            }
        }
        .cleaned(by: dustBuster)
    }
}
```

### Dispatcher

First of all, implementing `DispatchValue`. It connects Action and Store, but it plays a role that don't depend each other.

```swift
extension Dispatcher {
    enum Repository: DispatchValue {
        case isRepositoryFetching(Bool)
        case addRepositories([GithubApiSession.Repository])
        case removeAllRepositories
    }
}
```

### Store

Implementing `Store` with `Storable` protocol. If you call register method, that closure returns dispatched value related DispatchValueType.　Please update store's value with Associated Values.

```swift
final class RepositoryStore: Storable {
    typealias DispatchValueType = Dispatcher.Repository

    private(set) var isRepositoryFetching = false
    private(set) var repositories: [Repository] = []

    init(dispatcher: Dispatcher) {
        register { [weak self] in
            switch $0 {
            case .isRepositoryFetching(let value):
                self?.isRepositoryFetching = value
            case .addRepositories(let value):
                self?.repositories.append(contentsOf: value)
            case .removeAllRepositories:
                self?.repositories.removeAll()
            }
        }
    }
```

### Action

Implementing `Action` with `Actionable` protocol. If you call invoke method, it can dispatch value related DispatchValueType.

```swift
final class RepositoryAction: Actionable {
    typealias DispatchValueType = Dispatcher.Repository

    private let session: ApiSession

    init(session: ApiSession = .shared) {
        self.session = session
    }

    func fetchRepositories(withUserId id: String, after: String?) {
        invoke(.isRepositoryFetching(true))
        let request = UserNodeRequest(id: id, after: after)
        _ = session.send(request) { [weak self] in
            switch $0 {
            case .success(let value):
                self?.invoke(.addRepositories(value.nodes))
            case .failure:
                break
            }
            self?.invoke(.isRepositoryFetching(false))
        }
    }
}
```

### Observe changes

You can initialize a store with `instantiate()`. If reference of store is left, that method returns remained one. If reference is not left, that method returns new instance.
You can observe changes by store's subscribe method. When called subscribe, it returns `Dust`. So, clean up with `DustBuster`.

```swift
let dustBuster = DustBuster()

func observeStore() {
    RepositoryStore.instantiate().subscribe {
        switch $0 {
        case .addRepositories,
             .removeAllRepositories,
             .isRepositoryFetching:
            break
        }
    }
    .cleaned(by: dustBuster)
}
```

> ![dustbuster](./Images/dustbuster.png)
	Robert Zemeckis (1989) Back to the future Part II, Universal Pictures

### with RxSwift

You can use FluxCapacitor with RxSwift like [this link](./Examples/Flux/FluxCapacitorSample/Sources/Common/Flux/User/UserStore.swift).

## Example

To run the example project, clone the repo, and run `pod install` and `carthage update` from the Example directory first. In addition, you must set Github Personal access token.

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    ApiSession.shared.token = "/** Github Personal access token **/"
    return true
}
```

Application structure is like below.

![flux_image](./Images/flux_image.png)

- [SearchViewController](./Examples/Flux/FluxCapacitorSample/Sources/UI/Search) (with RxSwift) You can search Github user.
- [FavoriteViewController](./Examples/Flux/FluxCapacitorSample/Sources/UI/Favorite) You can stock favorites on memory.
- [UserRepositoryViewController](./Examples/Flux/FluxCapacitorSample/Sources/UI/UserRepository) You can display a user's repositories.
- [RepositoryViewController](./Examples/Flux/FluxCapacitorSample/Sources/UI/Repository) You can display webpage of repository, and add favorites on memory.

[GithubKitForSample](https://github.com/marty-suzuki/GithubKitForSample) is used in this sample project.

### Additional

Flux + MVVM Sample is [here](./Examples/Flux+MVVM).

## Author

marty-suzuki, s1180183@gmail.com

## License

FluxCapacitor is available under the MIT license. See the LICENSE file for more info.
