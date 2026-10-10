import '../../../farm/data/models/farm_profile_model.dart';
import '../../../farm/data/models/farm_priorities_model.dart';
import '../models/environment_data_model.dart';

abstract class EnvironmentRepository {
  Future<EnvironmentDataModel> fetchEnvironment({
    required FarmProfileModel farmProfile,
    required FarmPrioritiesModel farmPriorities,
  });
}
