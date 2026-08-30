FLUTTER := $(shell bash -c 'source ../scripts/flutter_utils.sh && get_flutter_cmd')
DART := $(shell bash -c 'source ../scripts/flutter_utils.sh && get_dart_cmd')

.PHONY: test
test:
	$(FLUTTER) test --no-test-assets

.PHONY: build-runner
build-runner:
	$(DART) run build_runner build --delete-conflicting-outputs

.PHONY: generate-strings
generate-strings:
	$(DART) run intl_utils:generate

.PHONY: run-tests-with-coverage
run-tests-with-coverage:
	@bash scripts/coverage/run_test_with_coverage.sh

.PHONY: process-coverage-data
process-coverage-data:
	@bash scripts/coverage/process_coverage_data.sh

.PHONY: enforce-coverage-threshold
enforce-coverage-threshold:
	@bash ../scripts/check_coverage.sh coverage/lcov.info 100

.PHONY: view-coverage
view-coverage: run-tests-with-coverage process-coverage-data
	@if [[ "$$OSTYPE" == "darwin"* ]]; then \
		open coverage/html/index.html; \
	else \
		echo "Coverage report at coverage/html/index.html."; \
	fi