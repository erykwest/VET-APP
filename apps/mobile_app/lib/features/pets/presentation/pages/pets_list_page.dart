import 'package:flutter/material.dart';

import '../../data/pet_demo_store.dart';
import '../../domain/pet_models.dart';
import '../widgets/pet_avatar.dart';
import '../widgets/pet_sections.dart';
import '../widgets/pets_scaffold.dart';
import '../widgets/pets_state_views.dart';
import 'pet_create_page.dart';
import 'pet_detail_page.dart';

class PetsListPage extends StatefulWidget {
  const PetsListPage({
    super.key,
    this.state = PetsScreenStatus.success,
    this.errorMessage = 'Al momento non riesco a caricare i profili pet.',
  });

  final PetsScreenStatus state;
  final String errorMessage;

  @override
  State<PetsListPage> createState() => _PetsListPageState();
}

class _PetsListPageState extends State<PetsListPage> {
  String _selectedSpecies = 'Tutti';
  List<PetProfile> _pets = PetDemoStore.instance.list();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _pets = PetDemoStore.instance.list(species: _selectedSpecies);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return PetsScaffold(
      title: "I tuoi pet, in un colpo d'occhio.",
      subtitle:
          'Qui trovi i profili disponibili, le prossime scadenze e il pet in evidenza nella preview locale.',
      actions: [
        IconButton(
          onPressed: () => _openCreate(context),
          icon: const Icon(Icons.add_circle_outline_rounded),
          color: Colors.white,
          style: IconButton.styleFrom(backgroundColor: const Color(0xFF163A35)),
        ),
      ],
      body: switch (state) {
        PetsScreenStatus.loading =>
          const PetsLoadingView(label: 'Carico la lista pet...'),
        PetsScreenStatus.error => PetsErrorView(
            title: 'Pet non disponibili',
            subtitle: widget.errorMessage,
            actionLabel: 'Indietro',
            onRetry: () => Navigator.of(context).maybePop(),
          ),
        PetsScreenStatus.empty => PetsEmptyView(
            title: 'Nessun pet ancora',
            subtitle:
                'Crea il primo profilo per tenere sotto controllo salute, note e scadenze.',
            actionLabel: 'Crea pet',
            onAction: () => _openCreate(context),
          ),
        PetsScreenStatus.success => _PetsListContent(
            pets: _pets,
            selectedSpecies: _selectedSpecies,
            onSpeciesChanged: (species) {
              setState(() {
                _selectedSpecies = species;
                _pets = PetDemoStore.instance.list(species: _selectedSpecies);
              });
            },
            onAddPet: () => _openCreate(context),
            onOpenPet: (pet) => _openDetail(context, pet),
          ),
      },
    );
  }

  Future<void> _openCreate(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PetCreatePage()),
    );
    if (!mounted) return;
    _reload();
  }

  Future<void> _openDetail(BuildContext context, PetProfile pet) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => PetDetailPage(pet: pet)),
    );
    if (!mounted) return;
    _reload();
  }
}

class _PetsListContent extends StatelessWidget {
  const _PetsListContent({
    required this.pets,
    required this.selectedSpecies,
    required this.onSpeciesChanged,
    required this.onAddPet,
    required this.onOpenPet,
  });

  final List<PetProfile> pets;
  final String selectedSpecies;
  final ValueChanged<String> onSpeciesChanged;
  final VoidCallback onAddPet;
  final ValueChanged<PetProfile> onOpenPet;

  @override
  Widget build(BuildContext context) {
    final visiblePets = pets;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PetSection(
            title: 'Filtro rapido',
            subtitle: 'Scegli la specie che vuoi vedere per prima.',
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _SpeciesFilterChip(
                    label: 'Tutti',
                    selected: selectedSpecies == 'Tutti',
                    onTap: () => onSpeciesChanged('Tutti'),
                  ),
                  ...PetDemoStore.speciesOptions.map(
                    (option) => _SpeciesFilterChip(
                      label: option.label,
                      selected: selectedSpecies == option.label,
                      onTap: () => onSpeciesChanged(option.label),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          PetSection(
            title: 'Panoramica preview',
            subtitle:
                'Mostriamo subito il pet in evidenza, una scadenza vicina e i numeri chiave della preview locale.',
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  PetMetricChip(
                    label: 'Pet registrati',
                    value: '${PetDemoStore.instance.list().length}',
                    backgroundColor: Color(0xFFE1F0EA),
                  ),
                  PetMetricChip(
                    label: 'Scadenze vicine',
                    value: '1',
                    backgroundColor: Color(0xFFF6EADF),
                  ),
                  PetMetricChip(
                    label: 'Note cliniche',
                    value: '1',
                    backgroundColor: Color(0xFFF5F0D8),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          PetSection(
            title: 'Profili visibili',
            subtitle: selectedSpecies == 'Tutti'
                ? 'Tutti i profili disponibili nella preview locale.'
                : 'Stai guardando solo i profili ${selectedSpecies.toLowerCase()} della preview locale.',
            trailing: _SectionBadge(label: '${visiblePets.length} visibili'),
            children: [
              PetMetricChip(
                label: 'Profili filtrati',
                value: '${visiblePets.length}',
                backgroundColor: const Color(0xFFE1F0EA),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PetSection(
            title: 'In primo piano',
            subtitle:
                'Il pet più in vista della selezione corrente, con i dettagli che contano davvero.',
            trailing: _SectionBadge(label: '1 card'),
            children: [
              if (visiblePets.isNotEmpty)
                _FeaturedPetCard(
                  pet: visiblePets.first,
                  onTap: () => onOpenPet(visiblePets.first),
                )
              else
                const Text(
                  'Nessun pet disponibile per questo filtro.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5C726D),
                  ),
                ),
              if (visiblePets.length > 1) ...[
                const SizedBox(height: 14),
                const Text(
                  'Altri profili',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7C8F89),
                  ),
                ),
                const SizedBox(height: 10),
                ...visiblePets.skip(1).map(
                      (pet) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PetListCard(
                          pet: pet,
                          onTap: () => onOpenPet(pet),
                        ),
                      ),
                    ),
              ],
              const SizedBox(height: 8),
              PetActionButton(
                label: 'Aggiungi pet',
                icon: Icons.add_rounded,
                primary: true,
                onPressed: onAddPet,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeaturedPetCard extends StatelessWidget {
  const _FeaturedPetCard({
    required this.pet,
    required this.onTap,
  });

  final PetProfile pet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FBF8),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE4DDD2)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10163A35),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PetAvatar(
                    label: pet.avatarEmoji,
                    backgroundColor: pet.accentColor,
                    size: 72,
                    imageDataUrl: pet.profileImageDataUrl,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _DemoPill(label: 'Preview'),
                        const SizedBox(height: 8),
                        Text(
                          pet.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF173A35),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pet.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5C726D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF7C8F89)),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _InfoChip(
                      label: pet.healthBadge,
                      backgroundColor: const Color(0xFFE1F0EA)),
                  _InfoChip(
                      label: pet.weightLabel,
                      backgroundColor: const Color(0xFFF6EADF)),
                  _InfoChip(
                      label: pet.birthDateLabel,
                      backgroundColor: const Color(0xFFF5F0D8)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                pet.medicalNote,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF5C726D),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE4DDD2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_available_outlined,
                        size: 18, color: Color(0xFF2D6B60)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        pet.nextVisitLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF173A35),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PetListCard extends StatelessWidget {
  const _PetListCard({
    required this.pet,
    required this.onTap,
  });

  final PetProfile pet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFDFC),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE4DDD2)),
          ),
          child: Row(
            children: [
              PetAvatar(
                label: pet.avatarEmoji,
                backgroundColor: pet.accentColor,
                size: 64,
                imageDataUrl: pet.profileImageDataUrl,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF173A35),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pet.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5C726D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pet.medicalNote,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF7C8F89),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pet.nextVisitLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7C8F89),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF7C8F89)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.backgroundColor,
  });

  final String label;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF173A35),
        ),
      ),
    );
  }
}

class _SectionBadge extends StatelessWidget {
  const _SectionBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF2E9DE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF6C4A36),
        ),
      ),
    );
  }
}

class _DemoPill extends StatelessWidget {
  const _DemoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF163A35),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _SpeciesFilterChip extends StatelessWidget {
  const _SpeciesFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      onSelected: (_) => onTap(),
      label: Text(label),
      selectedColor: const Color(0xFF163A35),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xFF173A35),
        fontWeight: FontWeight.w700,
      ),
      backgroundColor: const Color(0xFFF4EFE7),
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? const Color(0xFF163A35) : const Color(0xFFE4DDD2),
        ),
      ),
    );
  }
}
