import streamlit as st

from apps.streamlit_app.view_models.dashboard import DashboardCard
from packages.bootstrap.container import get_container
from packages.core.application.services.create_pet_profile import CreatePetProfileInput
from packages.core.application.services.create_reminder import CreateReminderInput
from packages.core.application.services.list_pet_profiles import ListPetProfilesInput
from packages.core.application.services.list_reminders import ListRemindersInput
from packages.core.application.services.send_chat_message import SendChatMessageInput
from packages.shared.auth_context import access_token_context
from packages.shared.errors.base import AuthenticationError, VetAppError

st.set_page_config(page_title="Vet App MVP", layout="wide")

container = get_container()

if "access_token" not in st.session_state:
    st.session_state.access_token = None

st.title("Vet App MVP")
st.caption("Streamlit usa auth reale Supabase, mantenendo il core applicativo separato dalla UI.")

if not st.session_state.access_token:
    st.subheader("Accedi con Supabase")
    login_col, signup_col = st.columns(2)

    with login_col:
        with st.form("login_form"):
            login_email = st.text_input("Email")
            login_password = st.text_input("Password", type="password")
            if st.form_submit_button("Login"):
                try:
                    session = container.auth_provider.sign_in_with_password(login_email, login_password)
                    st.session_state.access_token = session.access_token
                    st.rerun()
                except VetAppError as exc:
                    st.error(str(exc))

    with signup_col:
        with st.form("signup_form"):
            signup_email = st.text_input("Nuova email")
            signup_password = st.text_input("Nuova password", type="password")
            if st.form_submit_button("Sign up"):
                try:
                    session = container.auth_provider.sign_up(signup_email, signup_password)
                    if session is None:
                        st.success("Registrazione inviata. Conferma l'email se Supabase lo richiede.")
                    else:
                        st.session_state.access_token = session.access_token
                        st.rerun()
                except VetAppError as exc:
                    st.error(str(exc))

    st.stop()

with access_token_context(st.session_state.access_token):
    try:
        user = container.auth_provider.get_current_user()
    except AuthenticationError as exc:
        st.error(str(exc))
        st.session_state.access_token = None
        st.stop()

    st.subheader(f"Benvenuto, {user.email}")

    if st.button("Logout"):
        st.session_state.access_token = None
        st.rerun()

    cards = [
        DashboardCard("Autenticazione", "Sessione Supabase reale tramite email e password."),
        DashboardCard("Profilo pet", "Creazione e consultazione profili via application service."),
        DashboardCard("Chat", "Messaggi gestiti tramite servizio applicativo e adapter LLM."),
    ]

    for card in cards:
        st.markdown(f"### {card.title}")
        st.write(card.description)

    left_col, right_col = st.columns(2)

    with left_col:
        st.markdown("### Crea profilo pet")
        with st.form("create_pet"):
            pet_name = st.text_input("Nome")
            pet_species = st.text_input("Specie", value="dog")
            pet_breed = st.text_input("Razza")
            pet_age = st.number_input("Eta", min_value=0, max_value=40, value=2)
            pet_notes = st.text_area("Note")
            if st.form_submit_button("Salva pet"):
                try:
                    result = container.create_pet_profile_service().execute(
                        CreatePetProfileInput(
                            owner_id=user.id,
                            name=pet_name,
                            species=pet_species,
                            breed=pet_breed or None,
                            age_years=pet_age,
                            notes=pet_notes or None,
                        )
                    )
                    st.success(f"Creato pet: {result.pet_profile.name}")
                except VetAppError as exc:
                    st.error(str(exc))

        pets = container.list_pet_profiles_service().execute(ListPetProfilesInput(owner_id=user.id)).pet_profiles
        pet_options = {pet.name: pet.id for pet in pets}
        st.markdown("### Pet disponibili")
        if pets:
            st.json([pet.model_dump() for pet in pets])
        else:
            st.info("Nessun pet creato ancora.")

    with right_col:
        selected_pet_name = st.selectbox("Pet attivo", options=list(pet_options) or ["Nessuno"])
        selected_pet_id = pet_options.get(selected_pet_name)

        st.markdown("### Chat demo")
        with st.form("chat_form"):
            chat_message = st.text_area("Messaggio")
            if st.form_submit_button("Invia messaggio"):
                try:
                    result = container.send_chat_message_service().execute(
                        SendChatMessageInput(
                            owner_id=user.id,
                            pet_id=selected_pet_id or "",
                            user_message=chat_message,
                        )
                    )
                    st.success(result.reply.content)
                except VetAppError as exc:
                    st.error(str(exc))

        st.markdown("### Reminder demo")
        with st.form("reminder_form"):
            reminder_title = st.text_input("Titolo reminder", value="Controllo")
            reminder_due_date = st.date_input("Data")
            reminder_notes = st.text_input("Note reminder")
            if st.form_submit_button("Crea reminder"):
                try:
                    result = container.create_reminder_service().execute(
                        CreateReminderInput(
                            owner_id=user.id,
                            pet_id=selected_pet_id or "",
                            title=reminder_title,
                            due_date=reminder_due_date,
                            notes=reminder_notes or None,
                        )
                    )
                    st.success(f"Reminder creato: {result.reminder.title}")
                except VetAppError as exc:
                    st.error(str(exc))

        reminders = container.list_reminders_service().execute(
            ListRemindersInput(owner_id=user.id)
        ).reminders
        if reminders:
            st.json([reminder.model_dump(mode="json") for reminder in reminders])
