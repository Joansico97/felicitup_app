clean:
	@echo "╠ Cleaning project..."
	flutter clean
	@echo "╠ Get dependencies..."
	flutter pub get
	@echo "🟢 Finished clean"

gen:
	@echo "╠ Running generator..."
	dart run build_runner build --delete-conflicting-outputs
	@echo "🟢 Finished gen"

gen_l10n:
	@echo "╠ Generating translations..."
	dart run intl_utils:generate
	@echo "🟢 Finished gen translations"

fix_gen:
	@echo "╠ Fixing gen..."
	mkdir ./.dart_tool/flutter_gen
	echo "version: 1.0.0" > ./.dart_tool/flutter_gen/pubspec.yaml
	@echo "🟢 Finished Fixing gen"

test:
	@echo "╠ Running tests..."
	flutter test
	@echo "🟢 Finished tests"

coverage:
	@echo "╠ Running tests with coverage..."
	flutter test --coverage
	@echo "╠ Generating HTML report..."
	@which genhtml > /dev/null 2>&1 && genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html || echo "ℹ️ lcov (genhtml) not installed. Coverage generated at coverage/lcov.info"
	@echo "🟢 Finished coverage report"

deploy_functions:
	@echo "╠ Installing functions dependencies..."
	npm --prefix functions install
	@echo "╠ Deploying Cloud Functions..."
	firebase deploy --only functions
	@echo "🟢 Finished functions deploy"