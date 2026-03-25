from supabase import Client, create_client

from packages.shared.config.settings import Settings


def build_supabase_client(settings: Settings) -> Client:
    return create_client(settings.supabase_url, settings.supabase_service_role_key)


def build_supabase_public_client(settings: Settings) -> Client:
    return create_client(settings.supabase_url, settings.supabase_anon_key)
