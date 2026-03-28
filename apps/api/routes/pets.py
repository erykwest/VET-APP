from fastapi import APIRouter

from apps.api.dependencies.container import get_container
from apps.api.schemas.pets import CreatePetProfileRequest
from packages.core.application.services.create_pet_profile import CreatePetProfileInput
from packages.core.application.services.get_pet_profile import GetPetProfileInput
from packages.core.application.services.list_pet_profiles import ListPetProfilesInput
from packages.core.application.services.update_pet_profile import UpdatePetProfileInput
from packages.infrastructure.persistence.demo_seed import build_demo_seed
from packages.shared.config.settings import get_settings

router = APIRouter(prefix="/pets", tags=["pets"])


@router.get("")
def list_pets() -> dict[str, object]:
    container = get_container()
    user = container.auth_provider.get_current_user()
    _ensure_demo_pet_profiles(container, owner_id=user.id)
    result = container.list_pet_profiles_service().execute(
        ListPetProfilesInput(owner_id=user.id)
    )
    return result.model_dump()


@router.get("/{pet_id}")
def get_pet(pet_id: str) -> dict[str, object]:
    result = get_container().get_pet_profile_service().execute(GetPetProfileInput(pet_id=pet_id))
    return result.model_dump()


@router.post("")
def create_pet(request: CreatePetProfileRequest) -> dict[str, object]:
    container = get_container()
    user = container.auth_provider.get_current_user()
    result = container.create_pet_profile_service().execute(
        CreatePetProfileInput(owner_id=user.id, **request.model_dump())
    )
    return result.model_dump()


@router.put("/{pet_id}")
def update_pet(pet_id: str, request: CreatePetProfileRequest) -> dict[str, object]:
    result = get_container().update_pet_profile_service().execute(
        UpdatePetProfileInput(pet_id=pet_id, **request.model_dump())
    )
    return result.model_dump()


def _ensure_demo_pet_profiles(container: object, *, owner_id: str) -> None:
    settings = get_settings()
    if owner_id != settings.bootstrap_user_id:
        return

    existing = container.list_pet_profiles_service().execute(
        ListPetProfilesInput(owner_id=owner_id)
    )
    if existing.pet_profiles:
        return

    seed = build_demo_seed(owner_id)
    for pet_payload in seed.pet_profiles[:2]:
        container.create_pet_profile_service().execute(
            CreatePetProfileInput(
                owner_id=owner_id,
                name=str(pet_payload["name"]),
                species=str(pet_payload["species"]),
                breed=pet_payload.get("breed"),
                age_years=pet_payload.get("age_years"),
                notes=pet_payload.get("notes"),
            )
        )
