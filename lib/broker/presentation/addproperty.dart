import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:meettenants/broker/view/brokerfunction.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  String location = '';
  final String city = 'Kharar';
  String propertyType = '1BHK';
  String tenantType = 'students';
  String furnishingType = 'fully furnished';
  double rent = 0;
  Map<String, int> facilities = {
    'Sofa': 0,
    'Fridge': 0,
    'RO': 0,
    'AC': 0,
    'Geyser': 0,
    'TV': 1,
    'Inverter': 0,
    'Washing Machine': 0,
    'Parking Area': 0,
  };

  List<String> fileNames = [];
  final PropertyService _propertyService = PropertyService();

  Future<void> uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        fileNames.addAll(result.paths.whereType<String>());
      });
    }
  }

  Future<void> submitProperty() async {
    try {
      await _propertyService.addProperty(
        location: location,
        propertyType: propertyType,
        tenantType: tenantType,
        furnishingType: furnishingType,
        rent: rent,
        facilities: facilities,
        fileNames: fileNames,
        city: city,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Property added successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding property: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Property')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Location'),
              onChanged: (value) {
                location = value;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'City'),
              initialValue: city,
              readOnly: true,
            ),
            DropdownButtonFormField<String>(
              value: propertyType,
              decoration: InputDecoration(labelText: 'Property Type'),
              items: ['1BHK', '2BHK', '3BHK', 'Kothi']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  propertyType = value!;
                });
              },
            ),
            DropdownButtonFormField<String>(
              value: tenantType,
              decoration: InputDecoration(labelText: 'Tenant Type'),
              items: ['students', 'family', 'couple', 'anyone']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  tenantType = value!;
                });
              },
            ),
            DropdownButtonFormField<String>(
              value: furnishingType,
              decoration: InputDecoration(labelText: 'Furnishing Type'),
              items: ['fully furnished', 'semi-furnished']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  furnishingType = value!;
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Rent'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                rent = double.tryParse(value) ?? 0;
              },
            ),
            SizedBox(height: 16),
            Text('Facilities', style: TextStyle(fontSize: 18)),
            ...facilities.keys.map((facility) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(facility),
                  if (facility == 'Sofa' ||
                      facility == 'AC' ||
                      facility == 'Geyser' ||
                      facility == 'Washing Machine')
                    Row(
                      children: [
                        Text('Count:'),
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (facilities[facility]! > 0) {
                                facilities[facility] =
                                    facilities[facility]! - 1;
                              }
                            });
                          },
                        ),
                        Text('${facilities[facility]}'),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              facilities[facility] = facilities[facility]! + 1;
                            });
                          },
                        ),
                      ],
                    ),
                  if (facility == 'TV' ||
                      facility == 'Inverter' ||
                      facility == 'Parking Area')
                    Switch(
                      value: facilities[facility]! > 0,
                      onChanged: (value) {
                        setState(() {
                          facilities[facility] = value ? 1 : 0;
                        });
                      },
                    ),
                  // Add toggle buttons for Fridge and RO
                  if (facility == 'Fridge' || facility == 'RO')
                    Switch(
                      value: facilities[facility]! > 0,
                      onChanged: (value) {
                        setState(() {
                          facilities[facility] = value ? 1 : 0;
                        });
                      },
                    ),
                ],
              );
            }).toList(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadFile,
              child: Text('Upload Files'),
            ),
            SizedBox(height: 20),
            Text('Uploaded Files:'),
            ...fileNames.map((fileName) => Text(fileName)).toList(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitProperty,
              child: Text('Submit Property'),
            ),
          ],
        ),
      ),
    );
  }
}
