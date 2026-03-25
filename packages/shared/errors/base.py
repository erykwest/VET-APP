class VetAppError(Exception):
    """Base application error."""


class ValidationError(VetAppError):
    """Raised when a domain invariant is violated."""


class ProviderError(VetAppError):
    """Raised when an external provider fails."""
