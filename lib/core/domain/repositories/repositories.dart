import 'package:either_dart/either.dart';
import 'package:sistema_ies/core/domain/utils/responses.dart';

abstract class RepositoryPort {
  Future<Either<Failure, Success>> initRepositoryCaches();
}
