import 'package:flutter/material.dart';
import 'package:meettenants/eua/view/tenantfunction.dart';

class TenantSaved extends StatefulWidget {
  const TenantSaved({super.key});

  @override
  State<TenantSaved> createState() => _TenantSavedState();
}

class _TenantSavedState extends State<TenantSaved> {
  final FlatsService _flatsService = FlatsService();
  List<Map<String, dynamic>> wishlistedProperties = [];

  @override
  void initState() {
    super.initState();
    fetchWishlistedProperties();
  }

  Future<void> fetchWishlistedProperties() async {
    try {
      // Fetch the wishlist from the FlatsService
      List<String> wishlistIds = await _flatsService.getWishlist();

      // Now fetch the details for these IDs
      wishlistedProperties = await _flatsService.getFlatsByIds(wishlistIds);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching wishlisted properties: $e')),
      );
    }
  }

  Future<void> _removeFromWishlist(String docId) async {
    try {
      await _flatsService.removeFromWishlist(docId);
      wishlistedProperties.removeWhere((property) => property['id'] == docId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed from wishlist.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              // Re-add the property back to the wishlist
              await _flatsService.addToWishlist(docId);
              // Fetch the property details again
              List<Map<String, dynamic>> fetchedProperty =
                  await _flatsService.getFlatsByIds([docId]);
              wishlistedProperties.addAll(fetchedProperty);
              setState(() {}); // Refresh UI
            },
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      setState(() {}); // Refresh UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing from wishlist: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Saved Properties')),
      body: SafeArea(
        child: wishlistedProperties.isNotEmpty
            ? ListView.builder(
                itemCount: wishlistedProperties.length,
                itemBuilder: (context, index) {
                  final property = wishlistedProperties[index];
                  final docId = property['id'];

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${property['propertyType'] ?? "N/A"} - ${property['location'] ?? "Unknown"}',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                              'Rent: ₹${property['rent']?.toString() ?? "N/A"}'),
                          SizedBox(height: 8),
                          Text(
                              'Tenant Type: ${property['tenantType'] ?? "N/A"}'),
                          SizedBox(height: 8),
                          Text(
                              'Furnishing Type: ${property['furnishingType'] ?? "N/A"}'),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _removeFromWishlist(docId),
                            child: Text('Remove from Wishlist'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : Center(child: Text('No saved properties.')),
      ),
    );
  }
}
