// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email,
      String password,
      ) async {
    try {
      developer.log('Attempting to sign in with email: $email');

      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      developer.log('Sign in successful for user: ${result.user?.uid}');
      return result;
    } on FirebaseAuthException catch (e) {
      developer.log('FirebaseAuthException during sign in: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      developer.log('Unexpected error during sign in: $e');
      throw Exception('An unexpected error occurred during sign in: ${e.toString()}');
    }
  }

  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
      String email,
      String password,
      String fullName,
      String branch,
      int semester,
      ) async {
    UserCredential? result;

    try {
      developer.log('Attempting to create user with email: $email');

      // Step 1: Create the user account
      result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      developer.log('User account created successfully: ${result.user?.uid}');

      if (result.user != null) {
        try {
          // Step 2: Update display name
          developer.log('Updating display name to: $fullName');
          await result.user!.updateDisplayName(fullName);

          // Step 3: Create user document in Firestore
          developer.log('Creating user document in Firestore');
          await _createUserDocument(
            result.user!,
            fullName,
            branch,
            semester,
          );

          developer.log('User creation process completed successfully');
        } catch (e) {
          // If Firestore creation fails, we should clean up the auth user
          developer.log('Error in post-creation steps: $e');
          try {
            await result.user!.delete();
            developer.log('Cleaned up auth user due to Firestore error');
          } catch (deleteError) {
            developer.log('Failed to clean up auth user: $deleteError');
          }
          throw e;
        }
      }

      return result;
    } on FirebaseAuthException catch (e) {
      developer.log('FirebaseAuthException during user creation: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      developer.log('Unexpected error during user creation: $e');
      throw Exception('An unexpected error occurred during user creation: ${e.toString()}');
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(
      User user,
      String fullName,
      String branch,
      int semester,
      ) async {
    try {
      developer.log('Creating Firestore document for user: ${user.uid}');

      final userData = <String, dynamic>{
        'uid': user.uid,
        'email': user.email ?? '',
        'fullName': fullName,
        'name': fullName,
        'branch': branch,
        'semester': semester,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'profileImageUrl': null,
        'isActive': true,
        'isEmailVerified': user.emailVerified,
        'role': 'student',
      };

      developer.log('User data prepared: $userData');

      await _firestore.collection('users').doc(user.uid).set(userData);

      developer.log('Firestore document created successfully');
    } catch (e) {
      developer.log('Error creating Firestore document: $e');
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      developer.log('Attempting to sign out');
      await _firebaseAuth.signOut();
      developer.log('Sign out successful');
    } catch (e) {
      developer.log('Error during sign out: $e');
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      developer.log('Sending password reset email to: $email');
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      developer.log('Password reset email sent successfully');
    } on FirebaseAuthException catch (e) {
      developer.log('FirebaseAuthException during password reset: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      developer.log('Unexpected error during password reset: $e');
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? fullName,
    String? branch,
    int? semester,
    String? profileImageUrl,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      developer.log('Updating profile for user: ${user.uid}');

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (fullName != null) {
        updateData['fullName'] = fullName;
        updateData['name'] = fullName;
        await user.updateDisplayName(fullName);
      }
      if (branch != null) updateData['branch'] = branch;
      if (semester != null) updateData['semester'] = semester;
      if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;

      await _firestore.collection('users').doc(user.uid).update(updateData);
      developer.log('Profile updated successfully');
    } catch (e) {
      developer.log('Error updating profile: $e');
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      developer.log('Fetching user data for: ${user.uid}');

      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data();
        if (data is Map<String, dynamic>) {
          developer.log('User data fetched successfully');
          return data;
        } else {
          developer.log('Document data is not Map<String, dynamic>: ${data.runtimeType}');
        }
      } else {
        developer.log('User document does not exist');
      }
      return null;
    } catch (e) {
      developer.log('Error fetching user data: $e');
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  // Get user data stream
  Stream<DocumentSnapshot> getUserDataStream() {
    final user = currentUser;
    if (user == null) throw Exception('No user logged in');

    developer.log('Creating user data stream for: ${user.uid}');
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      developer.log('Deleting account for user: ${user.uid}');

      // Delete user document from Firestore first
      await _firestore.collection('users').doc(user.uid).delete();
      developer.log('Firestore document deleted');

      // Delete user account
      await user.delete();
      developer.log('User account deleted');
    } catch (e) {
      developer.log('Error deleting account: $e');
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  // Change password
  Future<void> changePassword(String newPassword) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      developer.log('Changing password for user: ${user.uid}');
      await user.updatePassword(newPassword);
      developer.log('Password changed successfully');
    } on FirebaseAuthException catch (e) {
      developer.log('FirebaseAuthException during password change: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      developer.log('Unexpected error during password change: $e');
      throw Exception('Failed to change password: ${e.toString()}');
    }
  }

  // Re-authenticate user
  Future<void> reauthenticateUser(String password) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      if (user.email == null) {
        throw Exception('User email not available for re-authentication');
      }

      developer.log('Re-authenticating user: ${user.uid}');

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      developer.log('Re-authentication successful');
    } on FirebaseAuthException catch (e) {
      developer.log('FirebaseAuthException during re-authentication: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      developer.log('Unexpected error during re-authentication: $e');
      throw Exception('Re-authentication failed: ${e.toString()}');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    developer.log('Handling FirebaseAuthException: ${e.code} - ${e.message}');

    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please log in again.';
      case 'invalid-credential':
        return 'The provided credentials are invalid.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'internal-error':
        return 'An internal error occurred. Please try again.';
      default:
        return 'Authentication failed: ${e.message ?? 'Unknown error'}';
    }
  }
}