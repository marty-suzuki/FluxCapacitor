# FluxCapacitor 0.10.0 Migration Guide

FluxCapacitor has some breaking changes like this.

### Critical

- Rename `DispatchValue` to `DispatchState`
- Rename `init(dispatcher:)` to `init()` in Storable
- Remove `func register(handler:_)` from Storable
- Add `func redice(with:_)` definition to Storable
- Remove `func subscribe(changed:_)` from Storable
- Add `Constant<Element>` and `Variable<Element>` via `PrimitiveValue<Trait: ValueTrait, Element>`

### Some affected

- Remove `var dispatcher: Dispatcher` definition from `Actionable` and `Storable`
- Rename `Storable.unregister()` to `Storable.clear()`

## Rename `DispatchValue` to `DispatchState`

- Before

```swift
extension Dispatcher {
    enum Repository: DispatchValue {
        typealias RelatedStoreType = RepositoryStore
        typealias RelatedActionType = RepositoryAction

        case isRepositoryFetching(Bool)
        case addRepositories([GithubApiSession.Repository])
        case removeAllRepositories
    }
}
```

- After

```swift
extension Dispatcher {
    enum Repository: DispatchState {
        typealias RelatedStoreType = RepositoryStore
        typealias RelatedActionType = RepositoryAction

        case isRepositoryFetching(Bool)
        case addRepositories([GithubApiSession.Repository])
        case removeAllRepositories
    }
}
```

## Remove `func register(handler:_)` from Storable

Implement `func reduce(with:_)` instead of `func register(handler:_)`.
In addtion, Dispatcher is no more appeared in Store layer that you implemented.
Therefore, `init(dispatcher:_)` is not needed.

- Before

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
}
```

- After

```swift
final class RepositoryStore: Storable {
    typealias DispatchStateType = Dispatcher.Repository

    let isRepositoryFetching: Constant<Bool>
    private let _isRepositoryFetching = Variable<Bool>(false)

    let repositories: Constant<[Repository]>
    private let _repositories = Variable<[Repository]>([])

    required init() {
        self.isRepositoryFetching = Constant(_isRepositoryFetching)
        self.repositories = Constant(_repositories)
    }

    func reduce(with state: Dispatcher.Repository) {
        switch state {
        case .isRepositoryFetching(let value):
            _isRepositoryFetching.value = value
        case .addRepositories(let value):
            _repositories.value.append(contentsOf: value)
        case .removeAllRepositories:
            _repositories.value.removeAll()
        }
    }
}
```

## Remove `func subscribe(changed:_)` from Storable

In v0.10.0, you can use `Constant<Element>` and `Variable<Element>`. Those can observe its self changes, therefore `func subscribe(changed:_)` no more needed.

- Before

```swift
let dustBuster = DustBuster()

func observeStore() {
    let store = RepositoryStore.instantiate()

    store.subscribe {
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

- After

```swift
let dustBuster = DustBuster()

func observeStore() {
    // Get store instance
    let store = RepositoryStore.instantiate()

    // Observer changes of repositories that is `Constant<[Github.Repository]>`.
    store.repositories
        .observe(on: .main) { value in
            // do something
        }
        .cleaned(by: dustBuster)
}
```
