from fastapi import APIRouter

from apps.api.dependencies.container import get_container
from apps.api.schemas.clinical_records import (
    CreateClinicalDocumentRequest,
    UpdatePetHealthProfileRequest,
)
from packages.core.application.services.create_clinical_document import (
    CreateClinicalDocumentInput,
)
from packages.core.application.services.get_pet_health_profile import (
    GetPetHealthProfileInput,
)
from packages.core.application.services.list_clinical_documents import (
    ListClinicalDocumentsInput,
)
from packages.core.application.services.list_clinical_timeline import (
    ListClinicalTimelineInput,
)
from packages.core.application.services.update_pet_health_profile import (
    UpdatePetHealthProfileInput,
)

router = APIRouter(prefix="/pets/{pet_id}", tags=["clinical-records"])


@router.get("/health-profile")
def get_health_profile(pet_id: str) -> dict[str, object]:
    container = get_container()
    user = container.auth_provider.get_current_user()
    result = container.get_pet_health_profile_service().execute(
        GetPetHealthProfileInput(owner_id=user.id, pet_id=pet_id)
    )
    return result.model_dump()


@router.patch("/health-profile")
def update_health_profile(
    pet_id: str, request: UpdatePetHealthProfileRequest
) -> dict[str, object]:
    container = get_container()
    user = container.auth_provider.get_current_user()
    result = container.update_pet_health_profile_service().execute(
        UpdatePetHealthProfileInput(
            owner_id=user.id,
            pet_id=pet_id,
            **request.model_dump(exclude_unset=True),
        )
    )
    return result.model_dump()


@router.get("/clinical-documents")
def list_clinical_documents(pet_id: str) -> dict[str, object]:
    container = get_container()
    user = container.auth_provider.get_current_user()
    result = container.list_clinical_documents_service().execute(
        ListClinicalDocumentsInput(owner_id=user.id, pet_id=pet_id)
    )
    return result.model_dump()


@router.post("/clinical-documents")
def create_clinical_document(
    pet_id: str, request: CreateClinicalDocumentRequest
) -> dict[str, object]:
    container = get_container()
    user = container.auth_provider.get_current_user()
    result = container.create_clinical_document_service().execute(
        CreateClinicalDocumentInput(
            owner_id=user.id,
            pet_id=pet_id,
            **request.model_dump(),
        )
    )
    return result.model_dump()


@router.get("/timeline")
def list_clinical_timeline(pet_id: str) -> dict[str, object]:
    container = get_container()
    user = container.auth_provider.get_current_user()
    result = container.list_clinical_timeline_service().execute(
        ListClinicalTimelineInput(owner_id=user.id, pet_id=pet_id)
    )
    return result.model_dump()
