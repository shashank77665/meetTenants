import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FlatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> getFlats({
    String? location,
    String? propertyType,
  }) async {
    try {
      Query query = _firestore.collection('flats');

      if (location != null && location.isNotEmpty) {
        query = query.where('location', isEqualTo: location);
      }
      if (propertyType != null && propertyType.isNotEmpty) {
        query = query.where('propertyType', isEqualTo: propertyType);
      }

      QuerySnapshot querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      throw Exception('Error fetching flats: $e');
    }
  }

  Future<void> addToWishlist(String docId) async {
    try {
      String? userId = _auth.currentUser?.uid;

      if (userId == null) {
        throw Exception('User not logged in.');
      }

      await _firestore.collection('wishlists').doc(userId).set({
        'properties': FieldValue.arrayUnion([docId]),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error adding property to wishlist: $e');
    }
  }

  Future<void> removeFromWishlist(String docId) async {
    try {
      String? userId = _auth.currentUser?.uid;

      if (userId == null) {
        throw Exception('User not logged in.');
      }

      await _firestore.collection('wishlists').doc(userId).set({
        'properties': FieldValue.arrayRemove([docId]),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error removing property from wishlist: $e');
    }
  }

  Future<List<String>> getWishlist() async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in.');
    }

    DocumentSnapshot doc =
        await _firestore.collection('wishlists').doc(userId).get();
    List<String> wishlistProperties =
        List<String>.from(doc['properties'] ?? []);
    return wishlistProperties;
  }

  Future<List<Map<String, dynamic>>> getWishlistedProperties() async {
    try {
      String? userId = _auth.currentUser?.uid;

      if (userId == null) {
        throw Exception('User not logged in.');
      }

      // Get the user's wishlist
      DocumentSnapshot wishlistDoc =
          await _firestore.collection('wishlists').doc(userId).get();
      List<String> wishlistedPropertyIds =
          List<String>.from(wishlistDoc['properties'] ?? []);

      // Fetch the details of each wishlisted property
      List<Map<String, dynamic>> wishlistedProperties = [];

      if (wishlistedPropertyIds.isNotEmpty) {
        // Use whereIn to fetch multiple documents in a single query
        QuerySnapshot propertiesSnapshot = await _firestore
            .collection('flats')
            .where(FieldPath.documentId, whereIn: wishlistedPropertyIds)
            .get();

        wishlistedProperties = propertiesSnapshot.docs.map((doc) {
          return {
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          };
        }).toList();
      }

      return wishlistedProperties;
    } catch (e) {
      throw Exception('Error fetching wishlisted properties: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFlatsByIds(List<String> ids) async {
    try {
      // Check if the list of IDs is empty
      if (ids.isEmpty) {
        return [];
      }

      // Query Firestore to get the documents with the specified IDs
      Query query = _firestore
          .collection('flats')
          .where(FieldPath.documentId, whereIn: ids);

      // Execute the query
      QuerySnapshot querySnapshot = await query.get();

      // Map the results to a list of maps and include the document ID
      return querySnapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>, // Get the document data
                'id': doc.id, // Include the document ID
              })
          .toList();
    } catch (e) {
      // Handle any errors that occur during the fetch
      throw Exception('Error fetching flats by IDs: $e');
    }
  }
}
