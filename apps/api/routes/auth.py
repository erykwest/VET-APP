from fastapi import APIRouter

from apps.api.dependencies.container import get_container

router = APIRouter(prefix="/auth", tags=["auth"])


@router.get("/me")
def get_me() -> dict[str, str]:
    user = get_container().auth_provider.get_current_user()
    return user.model_dump()
