import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data class to hold the fetched location details
class LocationDetails {
  final String placeName;
  final String admin1Name;
  final String countryCode;

  LocationDetails({
    required this.placeName,
    required this.admin1Name,
    required this.countryCode,
  });

  // Factory constructor to create LocationDetails from Firestore document data
  factory LocationDetails.fromFirestore(
    Map<String, dynamic> data,
    String inputCountryCode,
  ) {
    return LocationDetails(
      placeName: data['place_name'] as String? ?? 'Unknown Place',
      admin1Name: data['admin1_name'] as String? ?? 'Unknown Region',
      // We use the inputCountryCode because the document's country_code might differ or be redundant
      countryCode: inputCountryCode,
    );
  }

  @override
  String toString() => '$placeName, $admin1Name - $countryCode';
}

// --- Riverpod Providers ---

// Provider for FirebaseFirestore instance (can be defined here or in a shared providers file)
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// FutureProvider to get location details directly from Firestore
// Takes a Map {'zipCode': String, 'countryCode': String} as a parameter
final locationDetailsProvider = FutureProvider.family<
  LocationDetails,
  Map<String, String>
>((ref, params) async {
  final zipCode = params['zipCode'];
  final countryCode =
      params['countryCode']?.toUpperCase(); // Normalize country code

  print(
    '[LocationProvider] Attempting to fetch for zip: $zipCode, country: $countryCode',
  );

  if (zipCode == null ||
      zipCode.isEmpty ||
      countryCode == null ||
      countryCode.isEmpty) {
    print(
      '[LocationProvider] Error: Invalid parameters zip: $zipCode, country: $countryCode',
    );
    throw ArgumentError(
      'Zip code and country code must be provided and valid.',
    );
  }

  final firestore = ref.watch(firebaseFirestoreProvider);
  String collectionName;

  switch (countryCode) {
    case 'USA':
      collectionName = 'us_zip_codes';
      break;
    case 'CAD': // Changed from CAN to CAD. Ensure UserProfile.country stores "CAD" for Canada.
      collectionName = 'ca_zip_codes';
      break;
    case 'ESP':
      collectionName = 'es_zip_codes';
      break;
    default:
      print('[LocationProvider] Error: Unsupported country code: $countryCode');
      throw ArgumentError('Unsupported country code: $countryCode');
  }

  try {
    print(
      '[LocationProvider] Querying collection: $collectionName, doc: $zipCode',
    );
    final docSnapshot =
        await firestore.collection(collectionName).doc(zipCode).get();
    print(
      '[LocationProvider] Snapshot exists: ${docSnapshot.exists}, data: ${docSnapshot.data()}',
    );

    if (docSnapshot.exists && docSnapshot.data() != null) {
      print('[LocationProvider] Document found. Mapping to LocationDetails.');
      return LocationDetails.fromFirestore(docSnapshot.data()!, countryCode);
    } else {
      print(
        '[LocationProvider] Error: Document not found for zip: $zipCode, country: $countryCode, collection: $collectionName',
      );
      throw Exception(
        'Location details not found for $zipCode in $countryCode.',
      );
    }
  } on FirebaseException catch (e) {
    print(
      '[LocationProvider] FirebaseException for $zipCode, $countryCode: ${e.code} - ${e.message}',
    );
    throw Exception('Failed to fetch location from database: ${e.message}');
  } catch (e) {
    print(
      '[LocationProvider] Generic Exception for $zipCode, $countryCode: $e',
    );
    throw Exception(
      'An unexpected error occurred while fetching location details.',
    );
  }
});
