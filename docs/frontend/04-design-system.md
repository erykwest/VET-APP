# 04 — Design System

## Obiettivo
Trasformare il lavoro fatto in Figma in un sistema UI coerente e implementabile in Flutter senza ambiguità.

## Livelli del sistema
- **tokens**: colori, spacing, radius, typography, elevation
- **atoms**: button, input, icon, badge, avatar
- **molecules**: form row, pet card, reminder tile
- **organisms**: app bar custom, chat composer, document list section
- **layouts**: page scaffold, authenticated shell, modal layouts

## Token minimi da definire in Figma
### Colori
- primary
- secondary
- surface
- background
- success
- warning
- error
- info
- text primary
- text secondary
- border

### Typography
- display
- heading
- title
- body
- caption
- button

### Spacing
Usare scala coerente, per esempio:
- 4
- 8
- 12
- 16
- 20
- 24
- 32

### Radius
- small
- medium
- large
- pill

## Componenti prioritari per MVP
1. PrimaryButton
2. SecondaryButton
3. TextField
4. PasswordField
5. PetCard
6. ChatBubbleUser
7. ChatBubbleAssistant
8. ReminderCard
9. EmptyState
10. ErrorState
11. LoadingBlock
12. UploadTile

## Regole di implementazione
- nessun componente business-specifico nel design system
- le varianti nascono da casi d'uso ripetuti, non da eccezioni
- i nomi dei componenti Figma e Flutter devono coincidere il più possibile
- ogni componente deve definire stati: default, disabled, loading, error se applicabile

## Consegna da Figma verso codice
Per ogni componente servono:
- nome canonico
- varianti
- misure
- token usati
- comportamento atteso
- note per accessibilità
