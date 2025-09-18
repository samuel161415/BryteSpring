import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart'; // Add Dio import
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/verse.dart';
import '../../domain/repositories/verse_repository.dart';
import '../datasources/verse_remote_data_source.dart';
import '../models/verse_model.dart';
import '../../../../core/services/token_service.dart';

class VerseRepositoryImpl implements VerseRepository {
  final VerseRemoteDataSource remoteDataSource;
  final TokenService tokenService;
  // final NetworkInfo networkInfo; // You can inject a network info service

  VerseRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenService,
    // required this.networkInfo,
  });

  @override
  Future<Either<Failure, Verse>> createVerse(Verse verse) async {
    // if (await networkInfo.isConnected) {
    try {
      final verseModel = VerseModel(
        verseId: verse.verseId,
        name: verse.name,
        subdomain: verse.subdomain,
        email: verse.email,
        organizationName: verse.organizationName,
        logo: verse.logo,
        color: verse.color,
        colorName: verse.colorName,
        channels: verse.channels,
        assets: verse.assets,
        branding: verse.branding,
        initialChannels: verse.initialChannels,
        isNeutralView: verse.isNeutralView,
      );

      // Create the remote data source with the token service
      final tokenAwareDataSource = VerseRemoteDataSourceImpl(
        dio: Dio(), // Create new Dio instance
        tokenService: tokenService,
      );

      final remoteVerse = await tokenAwareDataSource.createVerse(verseModel);
      return Right(remoteVerse);
    } on ServerException {
      return Left(ServerFailure("unknown error"));
    }
    // } else {
    //   return Left(ServerFailure()); // Or a specific NetworkFailure
    // }
  }
}
