import '../../export/export.dart';

class FirebaseApiAdmin {
  Stream<List<Admin>> fetchRegularAdminsStream() {
    try {
      // Get a reference to the collection
      CollectionReference adminsCollection =
          FirebaseFirestore.instance.collection('admins');

      // Create a query to filter regular admins (exclude super_admins)
      Query query = adminsCollection.where('role', isEqualTo: 'regular_admin');
      return query.snapshots().map((QuerySnapshot querySnapshot) {
        // Convert each document snapshot to an Admin object
        return querySnapshot.docs.map((DocumentSnapshot document) {
          return Admin.fromJson(document.data() as Map<String, dynamic>);
        }).toList();
      });
    } catch (error) {
      debugPrint('Error fetching data: $error');
      rethrow; // Rethrow the error to propagate it to the caller
    }
  }

  Future<void> deleteAdminById(String adminId) async {
    try {
      // Get a reference to the document using its ID
      DocumentReference adminRef =
          FirebaseFirestore.instance.collection('admins').doc(adminId);

      // Check admin authentication state
      if (FirebaseAuth.instance.currentUser != null) {
        // Re-authenticate the admin to ensure recent authentication
        // This step may not be necessary if you are sure the admin is authenticated
        // Delete the admin document
        await adminRef.delete();
        debugPrint('Admin with ID $adminId deleted successfully.');
      } else {
        debugPrint('Admin is not authenticated.');
        // Handle the case where the admin is not authenticated
      }
    } catch (error) {
      // Error handling
      debugPrint('Error deleting admin: $error');
      rethrow; // Rethrow the error to propagate it to the caller
    }
  }

  Future<List<Admin>> fetchRegularAdmins() async {
    try {
      // Get a reference to the collection
      CollectionReference adminsCollection =
          FirebaseFirestore.instance.collection('admins');

      // Query only regular admins (exclude super_admins)
      QuerySnapshot querySnapshot = await adminsCollection
          .where('role', isEqualTo: 'regular_admin')
          .get();

      // Convert each document to Admin object
      List<Admin> regularAdmins = querySnapshot.docs
          .map((DocumentSnapshot document) =>
              Admin.fromJson(document.data() as Map<String, dynamic>))
          .toList();

      return regularAdmins; // Return the list of regular admins
    } catch (error) {
      // Error handling
      debugPrint('Error fetching data: $error');
      rethrow; // Rethrow the error to propagate it to the caller
    }
  }

  Future<Admin?> fetchAdminById(String adminId) async {
    try {
      // Get a reference to the super admin document
      DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
          .collection('admins')
          .doc(adminId)
          .get();

      // Check if the document exists
      if (adminSnapshot.exists) {
        // Convert the document data into an Admin object
        Admin superAdmin =
            Admin.fromJson(adminSnapshot.data() as Map<String, dynamic>);
        return superAdmin;
      } else {
        // Return null if the document does not exist
        return null;
      }
    } catch (error) {
      debugPrint('Error fetching super admin: $error');
      rethrow;
    }
  }

  // Update admin approval status in Firestore
  Future<void> updateAdminApproval(String adminId, bool isApproved) async {
    try {
      // Get a reference to the admin document
      DocumentReference adminRef =
          FirebaseFirestore.instance.collection('admins').doc(adminId);

      // Update the 'approved' field
      await adminRef.update({'approved': isApproved});
    } catch (error) {
      debugPrint('Error updating admin approval in Firestore: $error');
      rethrow;
    }
  }

  
}
