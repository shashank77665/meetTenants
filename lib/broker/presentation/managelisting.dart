import 'package:flutter/material.dart';
import 'package:meettenants/broker/view/brokerfunction.dart';

class ManageListing extends StatefulWidget {
  const ManageListing({super.key});

  @override
  _ManageListingState createState() => _ManageListingState();
}

class _ManageListingState extends State<ManageListing> {
  final PropertyService _propertyService = PropertyService();
  List<Map<String, dynamic>> properties = [];
  Map<String, dynamic>? deletedProperty;

  @override
  void initState() {
    super.initState();
    fetchProperties(); // Fetch properties when the widget is initialized
  }

  Future<void> fetchProperties() async {
    try {
      properties = await _propertyService.getFlatsList();
      // Include the document ID in the properties map
      properties = properties.map((property) {
        return {
          'docId': property['docId'], // Ensure to include docId
          ...property,
        };
      }).toList();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching properties: $e')),
      );
    }
  }

  Future<void> deleteProperty(String docId) async {
    try {
      deletedProperty =
          properties.firstWhere((property) => property['docId'] == docId);
      await _propertyService.deleteProperty(docId);
      setState(() {
        properties.removeWhere((property) => property['docId'] == docId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Flats Removed'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              _undoDelete();
            },
          ),
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting property: $e')),
      );
    }
  }

  void _undoDelete() {
    if (deletedProperty != null) {
      setState(() {
        properties.add(deletedProperty!);
        deletedProperty = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Listings')),
      body: ListView.builder(
        itemCount: properties.length,
        itemBuilder: (context, index) {
          final property = properties[index];

          return GestureDetector(
            onLongPress: () {
              _showPopupMenu(property['docId'], context);
            },
            child: Card(
              child: ListTile(
                title: Text(
                    '${property['propertyType']} - ${property['location']}'),
                subtitle: Text('Rent: ₹${property['rent']}'),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {},
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPopupMenu(String docId, BuildContext context) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        overlay.size.width - 100.0, // Adjust according to your layout
        100.0, // Adjust vertically if needed
        0.0,
        0.0,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete'),
        ),
      ],
    ).then((value) {
      if (value == 'delete') {
        _showDeleteConfirmation(docId);
      }
    });
  }

  void _showDeleteConfirmation(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this property?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteProperty(docId);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
