from dataclasses import dataclass


@dataclass(slots=True)
class DashboardCard:
    title: str
    description: str
