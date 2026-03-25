import streamlit as st

from packages.bootstrap.container import get_container
from packages.core.application.services.create_pet_profile import CreatePetProfileInput
from packages.core.application.services.create_reminder import CreateReminderInput
from packages.core.application.services.list_pet_profiles import ListPetProfilesInput
from packages.core.application.services.list_reminders import ListRemindersInput
from packages.core.application.services.send_chat_message import SendChatMessageInput
from packages.shared.errors.base import VetAppError
from apps.streamlit_app.view_models.dashboard import DashboardCard

st.set_page_config(page_title="Vet App MVP", layout="wide")

container = get_container()
user = container.auth_provider.get_current_user()

st.title("Vet App MVP")
st.caption("Streamlit e solo client di validazione. La logica vive nei package applicativi.")

st.subheader(f"Benvenuto, {user.email}")
st.warning("Auth e LLM sono stub demo per il bootstrap iniziale.")

cards = [
    DashboardCard("Autenticazione", "Sessione demo pronta per i flussi protetti."),
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
