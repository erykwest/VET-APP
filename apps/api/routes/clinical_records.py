import base64

from fastapi import APIRouter

from apps.api.dependencies.container import get_container
from apps.api.schemas.clinical_records import (
    CreateClinicalEventRequest,
    CreateClinicalDocumentRequest,
    UploadClinicalDocumentRequest,
    UpdateClinicalEventRequest,
    UpdatePetHealthProfileRequest,
)
from packages.core.application.services.create_clinical_document import (
    CreateClinicalDocumentInput,
)
from packages.core.application.services.create_clinical_event import (
    CreateClinicalEventInput,
)
from packages.core.application.services.delete_clinical_event import (
    DeleteClinicalEventInput,
)
from packages.core.application.services.get_pet_health_profile import (
    GetPetHealthProfileInput,
)
from packages.core.application.services.list_clinical_documents import (
    ListClinicalDocumentsInput,
)
from packages.core.application.services.list_clinical_events import (
    ListClinicalEventsInput,
)
from packages.core.application.services.list_clinical_timeline import (
    ListClinicalTimelineInput,
)
from packages.core.application.services.update_clinical_event import (
    UpdateClinicalEventInput,
)
from packages.core.application.services.update_pet_health_profile import (
    UpdatePetHealthProfileInput,
)
from packages.core.application.services.upload_clinical_document import (
    UploadClinicalDocumentInput,
)
from packages.shared.errors.base import ValidationError

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


@router.post("/clinical-documents/upload")
def upload_clinical_document(
    pet_id: str,
    request: UploadClinicalDocumentRequest,
) -> dict[str, object]:
    container = get_container()
    user = container.auth_provider.get_current_user()
    content = base64.b64decode(request.content_base64.encode("utf-8"))
    result = container.upload_clinical_document_service().execute(
        UploadClinicalDocumentInput(
            owner_id=user.id,
            pet_id=pet_id,
            title=request.title,
            document_type=request.document_type,
            document_date=request.document_date,
            filename=request.filename,
            content=content,
            content_type=request.content_type,
            summary=request.summary,
            source=request.source,
            extracted_text_summary=request.extracted_text_summary,
            status=request.status,
            verified_by_user=request.verified_by_user,
        )
    )
    return result.model_dump()


@router.get("/clinical-events")
def list_clinical_events(pet_id: str) -> dict[str, object]:
    container = get_container()
    user = container.auth_provider.get_current_user()
    result = container.list_clinical_events_service().execute(
        ListClinicalEventsInput(owner_id=user.id, pet_id=pet_id)
    )
    return result.model_dump()


@router.post("/clinical-events")
def create_clinical_event(
    pet_id: str,
    request: CreateClinicalEventRequest,
) -> dict[str, object]:
    container = get_container()
    user = container.auth_provider.get_current_user()
    result = container.create_clinical_event_service().execute(
        CreateClinicalEventInput(owner_id=user.id, pet_id=pet_id, **request.model_dump())
    )
    return result.model_dump()


@router.patch("/clinical-events/{event_id}")
def update_clinical_event(
    pet_id: str,
    event_id: str,
    request: UpdateClinicalEventRequest,
) -> dict[str, object]:
    container = get_container()
    user = container.auth_provider.get_current_user()
    events = container.list_clinical_events_service().execute(
        ListClinicalEventsInput(owner_id=user.id, pet_id=pet_id)
    )
    if not any(event.id == event_id for event in events.events):
        raise ValidationError("clinical_event not found")
    result = container.update_clinical_event_service().execute(
        UpdateClinicalEventInput(
            owner_id=user.id,
            event_id=event_id,
            **request.model_dump(exclude_unset=True),
        )
    )
    return result.model_dump()


@router.delete("/clinical-events/{event_id}")
def delete_clinical_event(pet_id: str, event_id: str) -> dict[str, object]:
    container = get_container()
    user = container.auth_provider.get_current_user()
    events = container.list_clinical_events_service().execute(
        ListClinicalEventsInput(owner_id=user.id, pet_id=pet_id)
    )
    if not any(event.id == event_id for event in events.events):
        raise ValidationError("clinical_event not found")
    result = container.delete_clinical_event_service().execute(
        DeleteClinicalEventInput(owner_id=user.id, event_id=event_id)
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
