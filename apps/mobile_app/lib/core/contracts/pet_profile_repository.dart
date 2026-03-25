import '../../shared/types/result.dart';
import '../models/pet_profile.dart';

abstract class PetProfileRepository {
  Future<Result<List<PetProfile>>> listPets();

  Future<Result<PetProfile>> createPet(PetProfile pet);

  Future<Result<PetProfile>> updatePet(PetProfile pet);
}
