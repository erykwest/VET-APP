from typing import Protocol

from packages.core.domain.reminders.models import Reminder


class ReminderRepository(Protocol):
    def save(self, reminder: Reminder) -> Reminder: ...

    def list_by_owner(self, owner_id: str) -> list[Reminder]: ...
