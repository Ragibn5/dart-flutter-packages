/// Shared developer tooling for Dart and Flutter projects.
library;

export 'src/use_cases/common/cmd_installation_checker.dart';
export 'src/use_cases/common/confirm_yes_no.dart';
export 'src/use_cases/common/find_fvm_aware_dart_command.dart';
export 'src/use_cases/common/find_fvm_aware_flutter_command.dart';
export 'src/use_cases/common/find_project_root.dart';
export 'src/use_cases/common/get_current_dart_package.dart';
export 'src/use_cases/common/get_current_platform_package.dart';
export 'src/use_cases/common/prompt_with_default.dart';
export 'src/use_cases/common/text_utils.dart';
export 'src/use_cases/coverage/calculate_coverage.dart';
export 'src/use_cases/coverage/check_coverage_with_threshold.dart';
export 'src/use_cases/coverage/process_coverage_data.dart';
export 'src/use_cases/coverage/run_flutter_test_with_coverage.dart';
export 'src/use_cases/git/detect_changes_in_folder.dart';
export 'src/use_cases/git/get_current_branch.dart';
export 'src/use_cases/git/has_clean_working_tree.dart';
export 'src/use_cases/publish/get_package_name.dart';
export 'src/use_cases/publish/get_package_version.dart';
export 'src/use_cases/publish/parse_release_branch.dart';
export 'src/use_cases/publish/publish_validation_exception.dart';
export 'src/use_cases/publish/run_publish_flow.dart';
export 'src/use_cases/publish/validate_package_path.dart';
