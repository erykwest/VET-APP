from fastapi import APIRouter

from packages.shared.config.settings import get_settings

router = APIRouter(tags=["health"])


@router.get("/")
def root() -> dict[str, str]:
    settings = get_settings()
    return {
        "status": "ok",
        "app_name": settings.app_name,
        "environment": settings.environment,
        "health_url": "/health",
        "docs_url": "/docs",
    }


@router.get("/health")
def healthcheck() -> dict[str, str]:
    settings = get_settings()
    return {"status": "ok", "app_name": settings.app_name, "environment": settings.environment}
