from __future__ import annotations

from dataclasses import dataclass
from datetime import UTC, date, datetime, time, timedelta
from typing import Any


@dataclass(frozen=True)
class DemoSeedBundle:
    pet_profiles: tuple[dict[str, Any], ...]
    conversations: tuple[dict[str, Any], ...]
    reminders: tuple[dict[str, Any], ...]


def build_demo_seed(owner_id: str, *, today: date | None = None) -> DemoSeedBundle:
    seed_day = today or date.today()

    moka_pet_id = "pet-moka"
    oliver_pet_id = "pet-oliver"

    pet_profiles = (
        {
            "id": moka_pet_id,
            "owner_id": owner_id,
            "name": "Moka",
            "species": "Cane",
            "breed": "Meticcio - Media",
            "age_years": 5,
            "notes": "Stomaco delicato, dieta leggera e controllo periodico gia pianificato.",
        },
        {
            "id": oliver_pet_id,
            "owner_id": owner_id,
            "name": "Oliver",
            "species": "Gatto",
            "breed": "Europeo a pelo corto",
            "age_years": 6,
            "notes": "Vita in casa, toelettatura regolare e attenzione ai controlli dentali.",
        },
    )

    conversations = (
        {
            "id": "conv-1",
            "owner_id": owner_id,
            "pet_id": moka_pet_id,
            "title": "Moka - appetito e controllo",
            "messages": [
                _message(
                    "assistant",
                    "Raccontami pure cosa stai osservando: appetito, energia, acqua e feci ci aiutano a capire subito se serve una visita o basta monitorare.",
                    seed_day,
                    hour=9,
                    minute=12,
                ),
                _message(
                    "user",
                    "Da ieri mangia meno del solito ma resta vivace. Devo preoccuparmi subito?",
                    seed_day,
                    hour=9,
                    minute=13,
                ),
                _message(
                    "assistant",
                    "Se non ci sono vomito, abbattimento o dolore evidente, in genere conviene monitorare 24 ore e tenere nota di appetito, acqua e feci. Se qualcosa peggiora, contatta il veterinario.",
                    seed_day,
                    hour=9,
                    minute=14,
                ),
            ],
        },
        {
            "id": "conv-3",
            "owner_id": owner_id,
            "pet_id": oliver_pet_id,
            "title": "Oliver - controllo dentale",
            "messages": [
                _message(
                    "assistant",
                    "Posso sintetizzare il referto in tre punti: quadro clinico, terapia e prossimi controlli. Se vuoi, preparo anche una versione breve da condividere.",
                    seed_day - timedelta(days=1),
                    hour=17,
                    minute=5,
                ),
                _message(
                    "user",
                    "Si, dammi la versione breve.",
                    seed_day - timedelta(days=1),
                    hour=17,
                    minute=6,
                ),
                _message(
                    "assistant",
                    "In breve: quadro stabile, terapia leggera per pochi giorni e controllo di follow-up gia programmato.",
                    seed_day - timedelta(days=1),
                    hour=17,
                    minute=7,
                ),
            ],
        },
    )

    reminders = (
        {
            "id": "moka-richiamo-vaccinale",
            "owner_id": owner_id,
            "pet_id": moka_pet_id,
            "title": "Richiamo vaccinale di Moka",
            "due_date": (seed_day + timedelta(days=12)).isoformat(),
            "notes": "Ogni 12 mesi | Programmato | Ricorrente ogni 12 mesi | Documento gia caricato in cartella per la prossima visita.",
        },
        {
            "id": "oliver-controllo-dentale",
            "owner_id": owner_id,
            "pet_id": oliver_pet_id,
            "title": "Controllo dentale di Oliver",
            "due_date": (seed_day + timedelta(days=7)).isoformat(),
            "notes": "Promemoria manuale | Vicino | Promemoria una tantum | Rivedi andamento e note cliniche prima della chiamata.",
        },
    )

    return DemoSeedBundle(
        pet_profiles=pet_profiles,
        conversations=conversations,
        reminders=reminders,
    )


def _message(role: str, content: str, day: date, *, hour: int, minute: int) -> dict[str, str]:
    created_at = datetime.combine(day, time(hour=hour, minute=minute), tzinfo=UTC)
    return {
        "id": f"{role}-{day.isoformat()}-{hour:02d}{minute:02d}",
        "role": role,
        "content": content,
        "created_at": created_at.isoformat(),
    }
