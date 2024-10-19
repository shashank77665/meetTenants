import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PropertyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addProperty({
    required String location,
    required String propertyType,
    required String tenantType,
    required String furnishingType,
    required double rent,
    required Map<String, int> facilities,
    required List<String> fileNames,
    required String city,
  }) async {
    String? brokerUid =
        _auth.currentUser?.uid; // Get the logged-in broker's UID

    if (brokerUid != null) {
      try {
        // Verify if the user is a broker
        final isBroker = await _isUserBroker(brokerUid);
        if (!isBroker) {
          throw Exception('User is not a broker.');
        }

        // Fetch the broker's name
        final brokerName = await _getBrokerName(brokerUid);

        // Prepare the facilities map with default values for unspecified fields
        final facilityData = {
          'Sofa': facilities['Sofa'] ?? 0,
          'Fridge': facilities['Fridge'] ?? 0,
          'RO': facilities['RO'] ?? 0,
          'AC': facilities['AC'] ?? 0,
          'Geyser': facilities['Geyser'] ?? 0,
          'TV': facilities['TV'] ?? 0, // Assuming TV is 1 if not specified
          'Inverter': facilities['Inverter'] ?? 0,
          'Washing Machine': facilities['Washing Machine'] ?? 0,
          'Parking Area': facilities['Parking Area'] ?? 0,
        };

        // Create a document with the property details in the "flats" collection
        await _firestore.collection('flats').add({
          'location': location,
          'propertyType': propertyType,
          'tenantType': tenantType,
          'furnishingType': furnishingType,
          'rent': rent,
          'facilities': facilityData, // Use prepared facility data
          'addedBy': brokerUid, // Broker's UID
          'brokerName': brokerName, // Add broker's name
          'timestamp': FieldValue.serverTimestamp(), // Server timestamp
          'images': fileNames.isNotEmpty
              ? fileNames
              : [], // List of uploaded file names, empty if none
        });
      } catch (e) {
        // Handle errors
        throw Exception('Error adding property: $e');
      }
    } else {
      throw Exception('User not logged in.');
    }
  }

  Future<bool> _isUserBroker(String brokerUid) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(brokerUid).get();
    return userDoc.exists && userDoc['userType'] == 'broker';
  }

  Future<String> _getBrokerName(String brokerUid) async {
    DocumentSnapshot brokerDoc =
        await _firestore.collection('users').doc(brokerUid).get();
    if (brokerDoc.exists) {
      return brokerDoc['name'] as String;
    } else {
      throw Exception('Broker document not found for UID: $brokerUid');
    }
  }

  Future<List<Map<String, dynamic>>> getBrokerProperties(
      String brokerUid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('flats')
          .where('addedBy', isEqualTo: brokerUid) // Filter by broker UID
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Error fetching properties: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFlatsList() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('flats').get();

      // Transform each document snapshot into a map
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'docId': doc.id, // Include the document ID
        };
      }).toList();
    } catch (e) {
      throw Exception('Error fetching flats: $e');
    }
  }

  Future<List<String>> getUniqueLocations() async {
    final snapshot = await _firestore.collection('flats').get();
    final locations = <String>{}; // Use a set to ensure uniqueness

    for (var doc in snapshot.docs) {
      locations.add(doc['location'] as String);
    }
    return locations.toList();
  }

  Future<List<String>> getUniquePropertyTypes() async {
    final snapshot = await _firestore.collection('flats').get();
    final propertyTypes = <String>{}; // Use a set to ensure uniqueness

    for (var doc in snapshot.docs) {
      propertyTypes.add(doc['propertyType'] as String);
    }
    return propertyTypes.toList();
  }

  Future<List<String>> getUniqueTenantTypes() async {
    final snapshot = await _firestore.collection('flats').get();
    final tenantTypes = <String>{}; // Use a set to ensure uniqueness

    for (var doc in snapshot.docs) {
      tenantTypes.add(doc['tenantType'] as String);
    }
    return tenantTypes.toList();
  }

  Future<List<String>> getUniqueFurnishingTypes() async {
    final snapshot = await _firestore.collection('flats').get();
    final furnishingTypes = <String>{}; // Use a set to ensure uniqueness

    for (var doc in snapshot.docs) {
      furnishingTypes.add(doc['furnishingType'] as String);
    }
    return furnishingTypes.toList();
  }

  Future<void> deleteProperty(String docId) async {
    try {
      await _firestore.collection('flats').doc(docId).delete();
    } catch (e) {
      throw Exception('Error deleting property: $e');
    }
  }
}
