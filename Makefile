PYTHON ?= python
UV ?= uv
FLUTTER_DART_DEFINES ?=
DEMO_API_BASE_URL ?= http://127.0.0.1:8000

setup:
	$(UV) sync --all-extras

format:
	$(UV) run ruff format .

lint:
	$(UV) run ruff check .

typecheck:
	$(UV) run mypy apps packages tests

test:
	$(UV) run pytest

run-api:
	$(UV) run uvicorn apps.api.main:app --reload

run-web:
	cd apps/mobile_app && flutter pub get && flutter run $(FLUTTER_DART_DEFINES) -d chrome

run-web-supabase:
	cd apps/mobile_app && flutter pub get && flutter run --dart-define=SUPABASE_URL=$(SUPABASE_URL) --dart-define=SUPABASE_ANON_KEY=$(SUPABASE_ANON_KEY) --dart-define=API_BASE_URL=$(API_BASE_URL) -d chrome

run-web-server:
	cd apps/mobile_app && flutter pub get && flutter run $(FLUTTER_DART_DEFINES) -d web-server --web-hostname 127.0.0.1 --web-port 8080

run-web-server-supabase:
	cd apps/mobile_app && flutter pub get && flutter run --dart-define=SUPABASE_URL=$(SUPABASE_URL) --dart-define=SUPABASE_ANON_KEY=$(SUPABASE_ANON_KEY) --dart-define=API_BASE_URL=$(API_BASE_URL) -d web-server --web-hostname 127.0.0.1 --web-port 8080

build-web:
	cd apps/mobile_app && flutter pub get && flutter build web $(FLUTTER_DART_DEFINES)

build-web-supabase:
	cd apps/mobile_app && flutter pub get && flutter build web --dart-define=SUPABASE_URL=$(SUPABASE_URL) --dart-define=SUPABASE_ANON_KEY=$(SUPABASE_ANON_KEY) --dart-define=API_BASE_URL=$(API_BASE_URL)

run-web-persistent-demo:
	cd apps/mobile_app && flutter pub get && flutter run --dart-define=API_BASE_URL=$(DEMO_API_BASE_URL) --dart-define=DEMO_BYPASS_AUTH=true -d chrome

run-web-server-persistent-demo:
	cd apps/mobile_app && flutter pub get && flutter run --dart-define=API_BASE_URL=$(DEMO_API_BASE_URL) --dart-define=DEMO_BYPASS_AUTH=true -d web-server --web-hostname 127.0.0.1 --web-port 8080
