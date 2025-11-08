import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // User operations
  static Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }
  
  static Future<void> createUser(Map<String, dynamic> userData) async {
    try {
      await _firestore
          .collection('users')
          .doc(userData['id'])
          .set(userData);
    } catch (e) {
      print('Error creating user: $e');
      throw e;
    }
  }
  
  static Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update(updates);
    } catch (e) {
      print('Error updating user: $e');
      throw e;
    }
  }
  
  // Generation operations
  static Future<String> createGeneration(Map<String, dynamic> generationData) async {
    try {
      final docRef = await _firestore
          .collection('generations')
          .add(generationData);
      return docRef.id;
    } catch (e) {
      print('Error creating generation: $e');
      throw e;
    }
  }
  
  static Future<void> updateGeneration(String generationId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('generations')
          .doc(generationId)
          .update(updates);
    } catch (e) {
      print('Error updating generation: $e');
      throw e;
    }
  }
  
  static Future<List<Map<String, dynamic>>> getUserGenerations(String userId, {int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection('generations')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return querySnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      print('Error getting user generations: $e');
      return [];
    }
  }
  
  static Future<void> deleteGeneration(String generationId) async {
    try {
      await _firestore
          .collection('generations')
          .doc(generationId)
          .delete();
    } catch (e) {
      print('Error deleting generation: $e');
      throw e;
    }
  }
  
  // Subscription operations
  static Future<Map<String, dynamic>?> getActiveSubscription(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: ['active', 'trial'])
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return {...doc.data(), 'id': doc.id};
      }
      return null;
    } catch (e) {
      print('Error getting subscription: $e');
      return null;
    }
  }
  
  static Future<String> createSubscription(Map<String, dynamic> subscriptionData) async {
    try {
      final docRef = await _firestore
          .collection('subscriptions')
          .add(subscriptionData);
      return docRef.id;
    } catch (e) {
      print('Error creating subscription: $e');
      throw e;
    }
  }
  
  static Future<void> updateSubscription(String subscriptionId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('subscriptions')
          .doc(subscriptionId)
          .update(updates);
    } catch (e) {
      print('Error updating subscription: $e');
      throw e;
    }
  }
  
  // Storage operations for images
  static Future<String> uploadImage({
    required String userId,
    required String generationId,
    required Uint8List imageData,
    required String mimeType,
  }) async {
    try {
      final String fileName = '${generationId}_${DateTime.now().millisecondsSinceEpoch}.png';
      final String path = 'generations/$userId/$fileName';
      
      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(
        contentType: mimeType,
        customMetadata: {
          'userId': userId,
          'generationId': generationId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
      
      final uploadTask = ref.putData(imageData, metadata);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }
  
  static Future<String> uploadImageFile({
    required String userId,
    required String generationId,
    required File imageFile,
    required String mimeType,
  }) async {
    try {
      final String fileName = '${generationId}_${DateTime.now().millisecondsSinceEpoch}.png';
      final String path = 'generations/$userId/$fileName';
      
      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(
        contentType: mimeType,
        customMetadata: {
          'userId': userId,
          'generationId': generationId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
      
      final uploadTask = ref.putFile(imageFile, metadata);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image file: $e');
      throw e;
    }
  }
  
  static Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
      // Don't throw - image might already be deleted
    }
  }
  
  // Analytics events
  static Future<void> logGenerationEvent({
    required String userId,
    required String style,
    required String quality,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection('analytics').add({
        'userId': userId,
        'event': 'generation_created',
        'style': style,
        'quality': quality,
        'metadata': metadata,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging analytics: $e');
      // Don't throw - analytics shouldn't break the app
    }
  }
  
  // Real-time listeners
  static Stream<DocumentSnapshot> getUserStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }
  
  static Stream<QuerySnapshot> getUserGenerationsStream(String userId) {
    return _firestore
        .collection('generations')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  
  static Stream<QuerySnapshot> getSubscriptionStream(String userId) {
    return _firestore
        .collection('subscriptions')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }
}
