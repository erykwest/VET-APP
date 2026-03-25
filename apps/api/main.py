from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from apps.api.routes.auth import router as auth_router
from apps.api.routes.chat import router as chat_router
from apps.api.routes.conversations import router as conversations_router
from apps.api.routes.health import router as health_router
from apps.api.routes.pets import router as pets_router
from apps.api.routes.reminders import router as reminders_router
from packages.infrastructure.logging.logger import configure_logging
from packages.infrastructure.telemetry.noop import setup_telemetry
from packages.shared.config.settings import get_settings
from packages.shared.errors.base import ProviderError, ValidationError

settings = get_settings()
configure_logging(settings)
setup_telemetry(settings.enable_telemetry)

app = FastAPI(title=settings.app_name)


@app.exception_handler(ValidationError)
async def handle_validation_error(_: Request, exc: ValidationError) -> JSONResponse:
    return JSONResponse(status_code=400, content={"detail": str(exc)})


@app.exception_handler(ProviderError)
async def handle_provider_error(_: Request, exc: ProviderError) -> JSONResponse:
    return JSONResponse(status_code=502, content={"detail": str(exc)})


app.include_router(health_router)
app.include_router(auth_router)
app.include_router(pets_router)
app.include_router(conversations_router)
app.include_router(chat_router)
app.include_router(reminders_router)
