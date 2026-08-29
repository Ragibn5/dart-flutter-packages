# dart-flutter-packages

A curated collection of Dart and Flutter packages designed to streamline development, promote code
reuse, enforce architectural consistency, and standardize best practices across projects.

---

## Package List

### Core Packages

Foundational utilities and infrastructure packages with minimal dependencies. These packages form
the base layer and are intended to be reusable across all projects.

- [`dart_functionals`](dart_functionals)
- [`extended_string`](extended_string)
- [`collection_utils`](collection_utils)
- [`extended_datetime`](extended_datetime)
- [`color_utils`](color_utils)
- [`loghub`](loghub)
- [`mutex`](mutex)
- [`data_domain_converters`](data_domain_converters)
- [`net_models`](net_models)
- [`generator_core`](generator_core)
- [`analysis_server_plugin_core`](analysis_server_plugin_core)
- [`analysis_plugin_test_helper`](analysis_plugin_test_helper)

---

### Intermediate Packages

Built on top of the core layer. These packages provide higher-level tooling, UI components, code
generation utilities, and architectural support.

- [`net_kit`](net_kit)
- [`parser_core`](parser_core)
- [`json_coder`](json_coder)
- [`json_parser_annotations`](json_coder/json_parser_annotations)
- [`json_parser_linter`](json_coder/json_parser_linter)
- [`json_parser_generator`](json_coder/json_parser_generator)
- [`file_store`](file_store)
- [`json_converters`](json_converters)
- [`preference_store`](preference_store)
- [`sqlite_db`](sqlite_db)
- [`base_auth_interceptor`](base_auth_interceptor)
- [`feature_api_client`](feature_api_client)
- [`nav_router`](nav_router)
- [`infinity_radio_group`](infinity_radio_group)
- [`infinity_selection_group`](infinity_selection_group)
- [`infinity_menu`](infinity_menu)
- [`alerty`](alerty)
- [`snacker`](snacker)
- [`clean_arch_linter`](clean_arch_linter)

---

### Application / Integration

Top-level integration or reference implementation packages that may depend on multiple core and
intermediate packages.

- [`app_template`](app_template)
- [`analytics`](analytics)
- [`crashlytics`](crashlytics)

---

## Using Packages

### Internal Usage

Refer to each package’s individual documentation for setup and usage instructions.

### Public Usage

Some packages may be available on pub.dev. Please check individual package documentation for
availability and installation details.

---

## Development

### Setup

#### 1. Clone the repository

Using HTTPS:

```bash
git clone https://github.com/Ragibn5/dart-flutter-packages.git
```

Or, using SSH:

```bash
git clone git@github.com:Ragibn5/dart-flutter-packages.git
```

#### 2. Open desired package in IDE

Open the package you want to work on (for example `net_kit`) with your IDE.

#### 3. Install dependencies for desired package:

```bash
# From package's root directory
flutter pub get
```

Or, if using [`FVM`](https://fvm.app):

```bash
# From package's root directory
fvm flutter pub get
```

### Contributing

1. Create a new branch for your changes:
    ```bash
    git checkout -b feature/<package-name>/branch-name
    ```
2. Make your changes within the appropriate package directory
3. Update readme, examples, tests and documentations as needed
4. Create a pull request with a clear description of your changes

## License

Click [here](LICENSE) to see the license.

## Contact

For internal inquiries about these packages, please contact me at ragibn5@gmail.com.