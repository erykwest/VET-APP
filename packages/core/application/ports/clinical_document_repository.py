from typing import Protocol

from packages.core.domain.clinical_records.models import ClinicalDocument


class ClinicalDocumentRepository(Protocol):
    def save(self, document: ClinicalDocument) -> ClinicalDocument: ...

    def list_by_pet(self, pet_id: str) -> list[ClinicalDocument]: ...
