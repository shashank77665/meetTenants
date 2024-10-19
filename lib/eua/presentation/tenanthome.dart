import 'package:flutter/material.dart';
import 'package:meettenants/broker/view/brokerfunction.dart';
import 'package:meettenants/eua/view/tenantfunction.dart';

class TenantHome extends StatefulWidget {
  const TenantHome({super.key});

  @override
  State<TenantHome> createState() => _TenantHomeState();
}

class _TenantHomeState extends State<TenantHome> {
  final FlatsService _flatsService = FlatsService();
  final PropertyService _propertyService = PropertyService();
  List<Map<String, dynamic>> properties = [];
  List<String> locations = [];
  List<String> propertyTypes = [];
  List<String> tenantTypes = [];
  List<String> furnishingTypes = [];
  List<String> wishlist = []; // List to store wishlist property IDs

  String? selectedLocation;
  double? minPrice;
  double? maxPrice;
  String? propertyType;
  String? tenantType;
  String? furnishingType;

  @override
  void initState() {
    super.initState();
    loadProperties();
    fetchFilterOptions(); // Fetch filter options
    fetchWishlist(); // Fetch the wishlist when initializing
  }

  Future<void> fetchFilterOptions() async {
    try {
      locations = await _propertyService.getUniqueLocations();
      propertyTypes = await _propertyService.getUniquePropertyTypes();
      tenantTypes = await _propertyService.getUniqueTenantTypes();
      furnishingTypes = await _propertyService.getUniqueFurnishingTypes();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching filter options: $e')),
      );
    }
  }

  // Future<void> fetchFilterOptions() async {
  //   try {
  //     // Fetching filter options from Firestore
  //     final locationsSnapshot =
  //         await _flatsService._firestore.collection('locations').get();
  //     final propertyTypesSnapshot =
  //         await _flatsService._firestore.collection('propertyTypes').get();
  //     final tenantTypesSnapshot =
  //         await _flatsService._firestore.collection('tenantTypes').get();
  //     final furnishingTypesSnapshot =
  //         await _flatsService._firestore.collection('furnishingTypes').get();

  //     setState(() {
  //       locations = locationsSnapshot.docs.map((doc) => doc.id).toList();
  //       propertyTypes =
  //           propertyTypesSnapshot.docs.map((doc) => doc.id).toList();
  //       tenantTypes = tenantTypesSnapshot.docs.map((doc) => doc.id).toList();
  //       furnishingTypes =
  //           furnishingTypesSnapshot.docs.map((doc) => doc.id).toList();
  //     });
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error fetching filter options: $e')),
  //     );
  //   }
  // }

  Future<void> loadProperties() async {
    try {
      properties = await _flatsService.getFlats();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching properties: $e')),
      );
    }
  }

  Future<void> fetchWishlist() async {
    try {
      wishlist = await _flatsService.getWishlist(); // Fetch wishlist correctly
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching wishlist: $e')),
      );
    }
  }

  Future<void> _toggleWishlist(String docId) async {
    if (wishlist.contains(docId)) {
      await _removeFromWishlist(docId);
    } else {
      await _addToWishlist(docId);
    }
  }

  Future<void> _addToWishlist(String docId) async {
    try {
      await _flatsService.addToWishlist(docId);
      wishlist.add(docId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to wishlist.')),
      );
      setState(() {}); // Refresh UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding to wishlist: $e')),
      );
    }
  }

  Future<void> _removeFromWishlist(String docId) async {
    try {
      await _flatsService.removeFromWishlist(docId);
      wishlist.remove(docId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed from wishlist.')),
      );
      setState(() {}); // Refresh UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing from wishlist: $e')),
      );
    }
  }

  // Filter properties based on selected criteria
  List<Map<String, dynamic>> filterProperties() {
    return properties.where((property) {
      bool matchesPrice = true;
      bool matchesLocation = true;
      bool matchesType = true;
      bool matchesFurnishing = true;

      if (minPrice != null) {
        matchesPrice = property['rent'] >= minPrice!;
      }
      if (maxPrice != null) {
        matchesPrice &= property['rent'] <= maxPrice!;
      }
      if (selectedLocation != null) {
        matchesLocation &= property['location'] == selectedLocation;
      }
      if (propertyType != null) {
        matchesType &= property['propertyType'] == propertyType;
      }
      if (tenantType != null) {
        matchesType &= property['tenantType'] == tenantType;
      }
      if (furnishingType != null) {
        matchesFurnishing &= property['furnishingType'] == furnishingType;
      }

      return matchesPrice &&
          matchesLocation &&
          matchesType &&
          matchesFurnishing;
    }).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Filters'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButton<String>(
                  hint: Text('Select Location'),
                  value: selectedLocation,
                  items: locations
                      .map((loc) => DropdownMenuItem(
                            value: loc,
                            child: Text(loc),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLocation = value;
                    });
                  },
                ),
                DropdownButton<String>(
                  hint: Text('Select Property Type'),
                  value: propertyType,
                  items: propertyTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      propertyType = value;
                    });
                  },
                ),
                DropdownButton<String>(
                  hint: Text('Select Tenant Type'),
                  value: tenantType,
                  items: tenantTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      tenantType = value;
                    });
                  },
                ),
                DropdownButton<String>(
                  hint: Text('Select Furnishing Type'),
                  value: furnishingType,
                  items: furnishingTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      furnishingType = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  selectedLocation = null;
                  propertyType = null;
                  tenantType = null;
                  furnishingType = null;
                });
              },
              child: Text('Clear Filters'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  // This will refresh the filtered properties when applying filters
                });
              },
              child: Text('Apply Filters'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProperties = filterProperties();

    return Scaffold(
      appBar: AppBar(title: Text('Tenant Listings')),
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _showFilterDialog,
              child: Text('Set Filters'),
            ),
            Expanded(
              child: filteredProperties.isNotEmpty
                  ? ListView.builder(
                      itemCount: filteredProperties.length,
                      itemBuilder: (context, index) {
                        final property = filteredProperties[index];
                        final docId =
                            property['id']; // Ensure you have the document ID

                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${property['propertyType'] ?? "N/A"} - ${property['location'] ?? "Unknown"}',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
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
                                  ],
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: IconButton(
                                    icon: Icon(
                                      wishlist.contains(docId)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: wishlist.contains(docId)
                                          ? Colors.red
                                          : null,
                                    ),
                                    onPressed: () => _toggleWishlist(docId),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(child: Text('No properties found.')),
            ),
          ],
        ),
      ),
    );
  }
}
