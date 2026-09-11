# dev_tools Coverage Report: Bash/CI Orchestration → dev_tools Commands

Scope: complex orchestration currently implemented as bash scripts / CI steps in
`dart-flutter-packages` and `app_template`, that should be re-implemented as
testable dev_tools commands. The rule going forward: only genuinely complex,
multi-step orchestration goes through dev_tools — not one-liners that bash/git
already handle natively.

## Current bash/CI inventory

| Source                                            | Purpose                                     | Covered by dev_tools today?                    |
|---------------------------------------------------|---------------------------------------------|------------------------------------------------|
| `scripts/run_all_tests.sh`                        | Discover + classify + run all package tests | No                                             |
| `scripts/publish.sh`                              | Interactive package publish flow            | Yes (`publish`)                                |
| `scripts/check_coverage.sh`                       | Enforce coverage threshold                  | Yes (`coverage enforce`)                       |
| `scripts/git_utils.sh detect_folder_changes`      | CI folder-change detection (PR-aware base)  | Partially (`git changes`, static refs)         |
| `app_template/scripts/whitelabel/*` (~15 files)   | Interactive project-setup wizard            | No                                             |
| `app_template/scripts/firebase/firebase_setup.sh` | Per-flavor `flutterfire configure`          | No                                             |
| `app_template/scripts/coverage/*`                 | run / process / generate / enforce          | Yes (`coverage run/process/genreport/enforce`) |
| `.github/workflows/validate-release-merge.yml`    | Parse + validate release branch             | Use cases exist, no command                    |
| `.github/workflows/create-release-tag.yml`        | Extract + create + push release tag         | Use cases exist, no command                    |
| `.github/workflows/app-template-ci.yml`           | PR-aware change detection + coverage steps  | Mostly yes                                     |

## Tier 1 — definitely should come in

### 1. `app-template setup` — the whitelabel wizard

Replaces `app_template/scripts/whitelabel/*` (~15 files): menu loop, template
copy to a target directory outside the template, project clean, Dart + platform
package renames (incl. Android source-set directory moves + text replace), guided
steps (app name, launcher icon, splash icon, Firebase), finalize, exit. The most
complex and brittle bash in the repo.

Reuses existing use cases:

- `FindProjectRoot`
- `ReplaceTextInScope`
- `GetCurrentDartPackage`, `GetCurrentPlatformPackage`
- `ConfirmYesNo`, `PromptWithDefault`
- `FindFvmAwareDartCommand`, `FindFvmAwareFlutterCommand`
- `InteractiveProcessRunner`

New use cases to add:

- `ResolveTargetDirectory` — resolve/validate target, copy template
- `RemoveGeneratedArtifacts` — the `cleanProject` step
- `RenamePlatformPackage` — Android source-set dir moves + text replace
- `RestorePbxprojSwiftAsset` — the fragile `project.pbxproj` sed bug-fix in `guide_launcher_icon.sh`
- `FirebaseSetupForFlavor` — `flutterfire configure` per flavor
- The print-only guides (app name, launcher icon, splash icon)

### 2. `test all` — recursive test runner

Replaces `scripts/run_all_tests.sh`. Real orchestration: discovery via
`pubspec.yaml`, classification (flutter vs dart vs no-tests), per-package
fvm-aware command resolution, sequential execution, aggregate pass/fail summary
with non-zero exit code.

Reuses:

- `FindProjectRoot`
- `FindFvmAwareDartCommand`, `FindFvmAwareFlutterCommand`

New use cases to add:

- `DiscoverPackages`
- `ClassifyPackage`
- `RunPackageTests` (with an aggregate result type)

## Tier 2 — good additions, moderate complexity

### 3. `release validate` + `release tag`

Replaces the bash in `validate-release-merge.yml` and `create-release-tag.yml`.
CI currently inlines `parse_release_branch` + `validate_package_path` and manual
tag creation.

Reuses:

- `ParseReleaseBranch`
- `ValidatePackagePath`
- `GetPackageName`, `GetPackageVersion`
- `HasCleanWorkingTree`
- `RunPublishFlow`

### 4. `firebase setup`

Replaces `app_template/scripts/firebase/firebase_setup.sh`. Reads env-file
defaults per flavor, prompts with fallbacks, runs `flutterfire configure` for
dev/exp/stage/prod. Also reusable as a wizard step.

Reuses:

- `PromptWithDefault`, `ConfirmYesNo`
- `FindFvmAware*Command`

## Tier 3 — borderline, propose to skip

- **PR-aware base for `git changes`**: `git_utils.sh` switches to
  `origin/${GITHUB_BASE_REF}` under GitHub Actions. dev_tools `git changes` uses
  static refs. Would require a new command (modifying the existing command is out
  of scope for additions-only). Near-one-liner in bash.
- **`coverage process` exclusions from a file**: dev_tools takes `--exclusions`
  as arguments; `app_template` keeps them in `scripts/coverage/exclusions.env`.
  Small addition, borderline value.

## Reuse map (existing dev_tools use cases)

| Use case                                                       | Used by new flow                             |
|----------------------------------------------------------------|----------------------------------------------|
| `FindProjectRoot`                                              | test all, app-template setup, firebase setup |
| `ReplaceTextInScope`                                           | app-template setup (dart/platform renames)   |
| `GetCurrentDartPackage` / `GetCurrentPlatformPackage`          | app-template setup                           |
| `ConfirmYesNo` / `PromptWithDefault`                           | app-template setup, firebase setup           |
| `FindFvmAwareDartCommand` / `FindFvmAwareFlutterCommand`       | test all, app-template setup                 |
| `InteractiveProcessRunner`                                     | app-template setup                           |
| `ParseReleaseBranch` / `ValidatePackagePath`                   | release validate/tag                         |
| `GetPackageName` / `GetPackageVersion` / `HasCleanWorkingTree` | release validate/tag                         |
| `RunPublishFlow`                                               | (publish flow — see next milestone)          |

## Next milestone: publish flow modifications

Before implementing the tiers above, make the agreed adjustments to the publish
flow in dev_tools (see discussion), then return to this report to execute
Tiers 1 and 2.