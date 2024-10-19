import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meettenants/broker/view/brokerfunction.dart';
import 'package:meettenants/broker/presentation/addproperty.dart';

class BrokerListingScreen extends StatefulWidget {
  const BrokerListingScreen({super.key});

  @override
  State<BrokerListingScreen> createState() => _BrokerListingScreenState();
}

class _BrokerListingScreenState extends State<BrokerListingScreen> {
  final PropertyService _propertyService = PropertyService();
  List<Map<String, dynamic>> properties = [];
  List<String> locations = [];
  List<String> propertyTypes = [];
  List<String> tenantTypes = [];
  List<String> furnishingTypes = [];

  String? selectedLocation;
  double? minPrice;
  double? maxPrice;
  String? propertyType;
  String? tenantType;
  String? furnishingType;

  @override
  void initState() {
    super.initState();
    loadBrokerProperties();
    fetchFilterOptions(); // Fetch filter options on initialization
  }

  Future<void> loadBrokerProperties() async {
    String? brokerUid = FirebaseAuth.instance.currentUser?.uid;

    if (brokerUid != null) {
      try {
        properties = await _propertyService.getBrokerProperties(brokerUid);
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching properties: $e')),
        );
      }
    }
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

  List<Map<String, dynamic>> filterProperties() {
    return properties.where((property) {
      bool matchesPrice = true;
      bool matchesLocation = true;
      bool matchesType = true;
      bool matchesFurnishing = true;

      if (minPrice != null) {
        matchesPrice &= property['rent'] >= minPrice!;
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
                Navigator.of(context).pop(); // Close dialog
                setState(() {
                  // Reset filters if needed when dialog closes
                  selectedLocation = null;
                  propertyType = null;
                  tenantType = null;
                  furnishingType = null;
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
      appBar: AppBar(title: Text('Broker Listings')),
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
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${property['propertyType']} - ${property['location']}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text('Rent: ₹${property['rent'].toString()}'),
                                SizedBox(height: 8),
                                Text(
                                    'Tenant Type: ${property['tenantType'] ?? "N/A"}'),
                                SizedBox(height: 8),
                                Text(
                                    'Furnishing Type: ${property['furnishingType'] ?? "N/A"}'),
                                SizedBox(height: 8),
                                // Add more fields if needed, e.g., facilities, images
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPropertyScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
