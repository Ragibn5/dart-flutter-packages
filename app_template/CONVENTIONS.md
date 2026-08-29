# Conventions

## Architecture

This project follows clean architecture. Conventions for architectural consistency are described in the following sections, grouped by layer. Refer to the official [clean architecture][clean-arch] documentation for more details or see existing features for a deeper understanding.

Overall structure of the project:

```
lib/
├── di/
│   ├── config/
│   ├── modules/
│   └── provider/
├── features/
│   ├── <auth>/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── application/
│   │   ├── infrastructure/
│   │   └── presentation/
│   ├── <home>/
│   │   └── ...
│   ├── <other-features>/
│   │   └── ...
│   ...
├── generated/
└── l10n/
```

## Features

### Data layer

#### Per-endpoint API clients

Per-endpoint API client abstractions live in [`data/clients/`](#per-endpoint-api-clients).

These are exclusively for remote (HTTP) data fetching and inherit the [`FeatureApiClient`][feature_api_client] class from the [`feature_api_client`][feature_api_client] package. The feature_api_client allows us to maintain a consistent API client contract for all the features.

#### Data sources

Data sources live in `data/sources/` (both abstract and their implementations). Generally, there can be multiple data sources for a single endpoint, falling mainly in two categories.

- **Remote sources**: should use the [Per-endpoint API clients](#per-endpoint-api-clients) to
  perform HTTP calls.
- **Local sources**: should use the pre-built first-class packages, like
    - [`PreferenceStore`][preference_store]
    - [`FileStore`][file_store]
    - [`SQLiteDb`][sqlite_db]

Please see the data sources of the existing features for a deeper understanding.

#### Data models (DTOs)

DTOs live in `data/models/`.

We use JSON format for serializing and deserializing data. Also, we use the [`json_serializable`][json_serializable] package to help us with that.

#### Data mappers

Mappers live in `data/mappers/`.

They convert between DTOs and domain models by implementing base mapper interfaces defined in the [`data_domain_converters`][data_domain_converters] package.

#### Repository implementations

Repository implementations live in `data/repositories/`.

They implement the abstract contract defined in [`domain/repositories/`](#domain-layer), orchestrating calls to data sources and mappers to return domain models, or entities (or a composite of the domain entities).

### Domain layer

#### Entities

Entities live in [`domain/entities/`](#entities).

These are pure Dart classes that represent and hold core business logic. Be aware of what logic you put in here. The only case when logic belongs to the entity is when the logic is entirely composed of the entity's own components. For example, if `UserEntity` has fields `age` and `gender`, then `userEntity.isAdultMale()` belongs here.

#### Domain models

Domain models live in [`domain/models/`](#domain-models).

These are [entities](#entities) without any business logic.

They are typically used to represent typed domain information. For example, in these data types, prefer using enums whenever possible – rather than raw data (e.g., coming from the transport layer).

Another reason we introduced the domain model concept is to give them a separate space. Entities with business logic are probably one of the most important things we should include in test coverage, but domain models are value objects and are generally excluded from test coverage. So, we keep entities and domain models in separate spaces.

#### Domain services

Domain services live in [`domain/services/`](#domain-services).

These are pure Dart classes that are used in cases when the business logic is not quite the part of one single entity. For example, when the business logic is composed of components scattered between multiple entities of the same domain. This also applies when the business logic is composed with multiple instances of the same, or different entities of the same domain.

These domain services should not use [entities](#entities) from different domains or be used to orchestrate application logic. These are **not** [use cases](#use-cases), or any application layer components.

### Application layer

#### Use cases

Use cases live in [`application/use_cases/`](#use-cases) and orchestrate a single business operation.

Keep in mind the following while designing use cases:

- One class per use case, named after the operation (e.g., `RefreshAuthDataUseCase`, `SubmitOrderUseCase`).
- Has exactly one public method named `call` (so that it is a callable class – can have any return type and/or any parameters).
- Keeps orchestration logic (validation, precondition checks, fallback) — not business rules (those belong in [domain entities](#entities), or [domain services](#domain-services)).

A use case may receive its dependencies from two places:

1. From within the same feature: Repositories, [domain services](#domain-services), other [use cases](#use-cases) etc., from the same feature.
2. From within another feature: Define an abstract use case (ports) and use that as a dependency. See the [`Ports`](#ports) section for more information.

Note:

- If multiple use cases of the same feature end up with the same repeated logic, maybe it belongs to a [domain service](#domain-services).
- Within the same feature, avoid using the use cases as dependencies of other use cases as much as possible and use [domain services](#domain-services) instead. For cross-feature uses, it is inevitable and is actually the way.
- [Use cases](#use-cases) should be the only component that can cross features, i.e., other features can use them.

#### Ports

Ports are abstract use cases and lives together with concrete ones in `application/usecases/`.

These are interfaces used as dependencies of other use cases and BLoC(s) to abstract away external communications such as (but not a complete list):

- Third party library usages
- Cross-feature communications
- Accessing flutter components
- Communication with underlying native platforms

#### Application services

There is no such thing as an application service; it is another use case.

### Infrastructure layer

#### Port implementations

Port abstractions defined in [`application/use_cases/`](#ports) are implemented here in [`infrastructure/ports/`](#port-implementations).

#### Network

Network components in infra layer live in [`infrastructure/network/`](#network).

- [Per-endpoint API client abstractions](#per-endpoint-api-clients) defined in [`data/clients/`] are implemented here in `infrastructure/network/clients/`.
- Interceptors are defined here in `infrastructure/network/interceptors/` and are used in per-endpoint API client implementations in `infrastructure/network/clients/`.

#### Database

Feature specific database components live in [`infrastructure/database/`](#database).

- Table-specific constants live in `constants/<table_name>_table_constants.dart`.

  Each table-specific constant file contains a single privately constructed class with multiple static constants that are used to build queries. The convention is to contain the following static fields:
    - `NAME`: A static constant specifying the name of the table.
    - `COLUMN_<XYZ>`: Static constants specifying each column names.

- Scripted queries live in `scripts/`.

  These are generally instances of `DbScript` defined in the [`sqlite_db`][sqlite_db] package. The scripts are used to perform database migrations, initialization, and many more. See the `DbScript` types in `sqlite_db` package for more details.

### Presentation layer

#### BLoC files

BLoC files follow this convention under [`presentation/bloc/`](#bloc-files):

```
bloc/
├── <feature>_bloc.dart
├── <feature>_event.dart
└── <feature>_state.dart
```

#### Widgets

Widgets live under [`presentation/widgets/`](#widgets). Place each top-level widget (usually a page) in its own folder with its component sub-widgets:

```
widgets/
├── profile_page
│   └── profile_page.dart
│   └── bio_fragment.dart
│   └── info_fragment.dart
│   └── profile_photo.dart
```

#### BLoC pattern

Each BLoC receives events, calls a use case, and creates sealed state classes. For remote network calls, the flow is:

```
Event ──> BLoC ──> Use Case ──> Either<ApiError, Either<DomainErr, DomainEntity/DomainModel>>
                    │
                    ▼
              BLoC folds result:
                Left(ApiError)         → TransportError state + addError()
                Right(Left(DomainErr)) → DomainError state
                Right(Right(Entity))   → Success state
```

Where the sealed states may be defined as:

```
sealed class MyState {}
class Initial extends MyState {}
class Loading extends MyState {}
class Success extends MyState { ... }
class DomainError extends MyState { ... }
class TransportError extends MyState { final ApiError error; ... }
```

### Folder organization in the project

Below is the convention you should follow when structuring features in the project:

| Layer            | Purpose                                                                                                      |
|------------------|--------------------------------------------------------------------------------------------------------------|
| `data`           | Repository implementations, DTOs, [data sources](#data-sources), [mappers](#data-mappers), etc.              |
| `domain`         | Pure Dart — [entities](#entities), [domain services](#domain-services), repository contracts, etc.           |
| `application`    | [Use cases](#use-cases) and [ports](#ports) (abstract use cases).                                            |
| `infrastructure` | [Network](#network) and [database](#database) components, [port implementations](#port-implementations) etc. |
| `presentation`   | State management, [widgets](#widgets), etc.                                                                  |

Note: The `Purpose` column is not a complete list of components. You may have more or fewer types according to your needs.

### Data flow between layers

Each layer uses a consistent return type pattern when communicating with the next. Data flows from outer layers (API, infrastructure) inward toward the domain, with types transformed at each boundary.

```
Per-Endpoint API Client
  │
  │  Future<Either<ApiError, ApiResponse<DataErr, DataDTO>>>
  ▼
Data Source
  │
  │  Future<Either<ApiError, Either<DataErr, DataDTO>>>
  ▼
Repository
  │  ── map DataErr → DomainErr
  │  ── map DataDTO → DomainEntity/DomainModel
  │
  │  Future<Either<ApiError, Either<DomainErr, DomainEntity/DomainModel>>>
  ▼
Use Case (application layer)
  │  ── adds validation & domain logic
  │  ── orchestrates one business operation
  │  ── may call multiple repositories (own feature) / services (cross-feature)
  │
  │  Future<Either<ApiError, Either<DomainErr, DomainEntity/DomainModel>>>
  ▼
BLoC
  │  ── folds Either into sealed states
  │  ── routes errors via addError()
  │
  │  sealed class MyState { ... }
```

#### Component map

Here is a list of each component referenced in the data flow. Use them throughout the project for architectural consistency.

| Component                            | Location / Package                                                                                                       |
|--------------------------------------|--------------------------------------------------------------------------------------------------------------------------|
| `Either<L, R>`                       | [`package:dart_functionals/dart_functionals.dart`][dart_functionals] — custom sealed class (`Left`, `Right`)             |
| `ApiError`                           | [`package:net_models/net_models.dart`][net_models] — subtypes: `TransportError`, `CancellationError`, `UnexpectedError`  |
| `ApiResponse<Err, Res>`              | [`package:net_models/net_models.dart`][net_models] — subtypes: `SuccessResponse<Res>`, `FailureResponse<Err>`            |
| `FeatureApiClient<Req, Res, Err>`    | [`package:feature_api_client/feature_api_client.dart`][feature_api_client] — base class for per-endpoint API clients     |
| `NetClient` / `NetClientInterceptor` | [`package:net_client/net_client.dart`][net_client] — HTTP client and interceptor interfaces, raw request/response models |

### Adding a new feature

Create `lib/features/<feature>/` with the layers in the following order:

1. **Domain layer**
    - Feature entities in [`domain/entities/`](#entities).
    - Domain models in [`domain/models/`](#domain-models).
    - Domain services in [`domain/services/`](#domain-services).
    - Repository contracts in [`domain/repositories/`](#domain-layer).

2. **Application layer**
    - Use cases in [`application/use_cases/`](#use-cases).

3. **Data layer**
    - Data models in `data/models/`.
    - Data sources in `data/sources/`.
    - Data mappers in `data/mappers/`.
    - Repository implementations in `data/repositories/`.

4. **Infrastructure layer**
    - Port implementations in [`infrastructure/ports/`](#port-implementations).
    - Database component definitions in [`infrastructure/database/`](#database).
    - Network components in `infrastructure/network/`.
    - Platform components in `infrastructure/platform/`.

5. **Presentation layer**
    - Widgets in [`presentation/widgets/`](#widgets).
    - BLoC classes (with events and states) in [`presentation/bloc/`](#bloc-files).

   See [Presentation layer](#presentation-layer) above for more details.

6. Wire new routes in [`lib/features/app/infrastructure/config/router/routes.dart`][routes_file].

7. Register dependencies in the [feature module](#dependency-injection).

8. Add corresponding tests in [`test/features/<feature>/`][test_features].

See the [Return types in layers](#data-flow-between-layers) for information on data flow between these layers.

## Dependency injection

The DI layer is structured as follows:

```
lib/di/
├── config/
│   ├── dependencies.dart                # Injectable config (register factories/params)
│   └── dependencies.config.dart         # Generated wiring (do not edit manually)
├── modules/
│   └── <feature>_module.dart            # One module per feature
└── provider/
    ├── dependency_provider.dart         # Abstract DI provider contract
    └── dependency_provider_impl.dart    # Concrete implementation wrapping GetIt
```

### Adding a dependency

- **Existing feature** — open the feature's DI module in [`lib/di/modules/`][di_modules] and add the registration.
- **New feature** — create a module at `lib/di/modules/<feature>_module.dart`. Refer to existing modules for guidance. Simply creating the module is enough — the DI framework generates wiring when `build_runner` runs. See [Code generation](#code-generation).

### Reading a dependency

Retrieve dependencies via [`di`][di_helper]:

- `di.get<MyType>()` — returns the dependency. Throws if not registered.
- `di.getOrNull<MyType>()` — returns the dependency or `null` if not registered.

Do not use `di`'s registration methods directly — define dependencies through modules for architectural consistency.

## Flavors

Four build flavors are supported:

- `dev`: For you, the developer, to do daily development work.
- `exp`: For testers or QA people.
- `stage`: For testing release candidates in production mirrors.
- `prod`: For end users – final destination.

Each flavor has its own Firebase project, launcher icon, splash screen, and app name. Entry points are defined in [`lib/main_<flavor>.dart`][main_flavor], with corresponding run configurations in [`.run/`][run_dir] (IDEA).

## Code generation

Run the following to regenerate all generated code (JSON serializers `*.g.dart`, typesafe assets under [`lib/generated/`][generated], DI wiring, etc.):

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

These files should not be edited manually.

## Localization

ARB files live in [`lib/l10n/`][l10n]. Add, edit, or remove locale files there, then run the following command to regenerate the localization components. Alternatively, use IDE features — for example, in Android Studio under `Tools > Flutter Intl`.

```
fvm dart run intl_utils:generate
```

## Testing & coverage

- Tests use `mocktail` for mocking and `bloc_test` for BLoC unit tests.
- Coverage is collected via `flutter test --coverage` and processed with `lcov`.
- Certain directories and patterns are excluded from coverage — see [`scripts/coverage/exclusions.sh`][coverage_exclusions] for the full list.
- The [`Makefile`][makefile] provides targets for running tests with coverage:
    - `make run-tests-with-coverage`
    - `make process-coverage-data`
    - `make view-coverage`

## Code style

Analyzer configuration is based on `very_good_analysis` and `bloc_lint`. See [`analysis_options.yaml`][analysis_options] for more details.

---

[analysis_options]: analysis_options.yaml

[clean-arch]: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html

[net_models]: ../net_models/lib/net_models.dart

[dart_functionals]: ../dart_functionals/lib/dart_functionals.dart

[coverage_exclusions]: scripts/coverage/exclusions.sh

[data_domain_converters]: ../data_domain_converters/lib/data_domain_converters.dart

[di_helper]: lib/di/di.dart

[di_modules]: lib/di/modules

[feature_api_client]: ../feature_api_client/lib/feature_api_client.dart

[file_store]: ../file_store

[generated]: lib/generated

[json_serializable]: https://pub.dev/packages/json_serializable

[l10n]: lib/l10n

[main_flavor]: lib/main_dev.dart

[makefile]: Makefile

[net_client]: ../net_client/lib/net_client.dart

[preference_store]: ../preference_store

[routes_file]: lib/features/app/infrastructure/config/router/routes.dart

[run_dir]: .run

[sqlite_db]: ../sqlite_db

[test_features]: test/features
