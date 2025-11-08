---
name: firebase-integration
description: Production-ready Firebase integration patterns for authentication, Firestore database, Cloud Storage, and security rules in Flutter applications
---

# Firebase Integration Skill

This skill provides comprehensive Firebase integration expertise for building secure, scalable backend services for Flutter applications.

## Core Competencies

### 1. Firebase Configuration

#### Project Setup
```dart
// firebase_options.dart (auto-generated, never commit)
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }
}
```

#### Secure Initialization
```dart
// main.dart
Future<void> initializeFirebase() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Configure settings
    await _configureFirebaseSettings();
    
    // Initialize services
    await _initializeServices();
    
  } catch (e) {
    // Handle initialization errors gracefully
    print('Firebase initialization failed: $e');
    // Consider offline mode or limited functionality
  }
}

Future<void> _configureFirebaseSettings() async {
  // Firestore settings
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  // Auth settings
  await FirebaseAuth.instance.setLanguageCode('en');
  
  // Performance monitoring
  await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
}
```

### 2. Authentication Patterns

#### Secure Auth Service
```dart
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Current user
  User? get currentUser => _auth.currentUser;
  
  // Email/Password Registration
  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update profile
      await credential.user?.updateDisplayName(displayName);
      
      // Send verification email
      await credential.user?.sendEmailVerification();
      
      // Create user document
      await _createUserDocument(credential.user!);
      
      return AuthResult.success(user: credential.user!);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        error: _handleAuthError(e),
      );
    }
  }
  
  // Secure sign-in with rate limiting
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Check rate limiting
    if (await _isRateLimited(email)) {
      return AuthResult.failure(
        error: AuthError(
          code: 'rate-limited',
          message: 'Too many attempts. Please try again later.',
        ),
      );
    }
    
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Check if email is verified
      if (!credential.user!.emailVerified) {
        await _auth.signOut();
        return AuthResult.failure(
          error: AuthError(
            code: 'email-not-verified',
            message: 'Please verify your email before signing in.',
          ),
        );
      }
      
      return AuthResult.success(user: credential.user!);
    } on FirebaseAuthException catch (e) {
      await _recordFailedAttempt(email);
      return AuthResult.failure(
        error: _handleAuthError(e),
      );
    }
  }
  
  // Google Sign-In
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Trigger authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return AuthResult.failure(
          error: AuthError(
            code: 'google-signin-cancelled',
            message: 'Google sign-in was cancelled',
          ),
        );
      }
      
      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Create/update user document
      await _createOrUpdateUserDocument(userCredential.user!);
      
      return AuthResult.success(user: userCredential.user!);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        error: _handleAuthError(e),
      );
    }
  }
  
  // Secure password reset
  Future<void> sendPasswordResetEmail(String email) async {
    // Validate email format
    if (!_isValidEmail(email)) {
      throw AuthError(
        code: 'invalid-email',
        message: 'Please enter a valid email address',
      );
    }
    
    // Check rate limiting
    if (await _isPasswordResetRateLimited(email)) {
      throw AuthError(
        code: 'rate-limited',
        message: 'Please wait before requesting another reset',
      );
    }
    
    await _auth.sendPasswordResetEmail(email: email);
    await _recordPasswordResetRequest(email);
  }
}
```

### 3. Firestore Database

#### Data Models & Converters
```dart
// Firestore converter for type-safe data
class GenerationConverter {
  static GenerationModel fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return GenerationModel.fromMap({
      ...data,
      'id': snapshot.id,
      'createdAt': (data['createdAt'] as Timestamp).toDate(),
      'completedAt': data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
    });
  }
  
  static Map<String, dynamic> toFirestore(
    GenerationModel generation,
    SetOptions? options,
  ) {
    final data = generation.toMap();
    
    // Convert dates to timestamps
    data['createdAt'] = Timestamp.fromDate(generation.createdAt);
    if (generation.completedAt != null) {
      data['completedAt'] = Timestamp.fromDate(generation.completedAt!);
    }
    
    // Remove client-only fields
    data.remove('localPath');
    
    // Add server timestamp for updates
    data['updatedAt'] = FieldValue.serverTimestamp();
    
    return data;
  }
}

// Type-safe collection references
extension FirestoreCollections on FirebaseFirestore {
  CollectionReference<GenerationModel> get generations =>
      collection('generations').withConverter<GenerationModel>(
        fromFirestore: GenerationConverter.fromFirestore,
        toFirestore: GenerationConverter.toFirestore,
      );
  
  CollectionReference<UserModel> get users =>
      collection('users').withConverter<UserModel>(
        fromFirestore: UserConverter.fromFirestore,
        toFirestore: UserConverter.toFirestore,
      );
}
```

#### Efficient Queries
```dart
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Paginated query with real-time updates
  Stream<List<GenerationModel>> getUserGenerations({
    required String userId,
    int limit = 20,
    GenerationModel? lastGeneration,
  }) {
    Query<GenerationModel> query = _firestore.generations
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    
    if (lastGeneration != null) {
      query = query.startAfterDocument(
        lastGeneration.reference as DocumentSnapshot<GenerationModel>,
      );
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
  
  // Compound queries with indexes
  Future<List<GenerationModel>> searchGenerations({
    required String userId,
    required String searchTerm,
    String? style,
    GenerationStatus? status,
  }) async {
    Query<GenerationModel> query = _firestore.generations
        .where('userId', isEqualTo: userId);
    
    // Add filters
    if (style != null) {
      query = query.where('style', isEqualTo: style);
    }
    
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    
    // Execute query
    final snapshot = await query.get();
    
    // Client-side text search (Firestore doesn't support full-text search)
    return snapshot.docs
        .map((doc) => doc.data())
        .where((gen) => 
            gen.prompt.toLowerCase().contains(searchTerm.toLowerCase()) ||
            gen.tags?.any((tag) => 
                tag.toLowerCase().contains(searchTerm.toLowerCase())) == true)
        .toList();
  }
  
  // Batch operations
  Future<void> batchUpdateGenerations({
    required List<String> generationIds,
    required Map<String, dynamic> updates,
  }) async {
    final batch = _firestore.batch();
    
    for (final id in generationIds) {
      final docRef = _firestore.generations.doc(id);
      batch.update(docRef, {
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    
    await batch.commit();
  }
  
  // Transaction example
  Future<void> incrementUserGenerationCount(String userId) async {
    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(
        _firestore.users.doc(userId),
      );
      
      if (!userDoc.exists) {
        throw Exception('User not found');
      }
      
      final currentCount = userDoc.data()!.totalGenerations;
      final freeGenerationsUsed = userDoc.data()!.freeGenerationsUsed;
      
      transaction.update(userDoc.reference, {
        'totalGenerations': currentCount + 1,
        'freeGenerationsUsed': freeGenerationsUsed < 3 
            ? freeGenerationsUsed + 1 
            : freeGenerationsUsed,
        'lastGenerationAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
```

### 4. Cloud Storage

#### Secure File Management
```dart
class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Upload with progress tracking
  Future<String> uploadGenerationImage({
    required String userId,
    required String generationId,
    required Uint8List imageData,
    required String mimeType,
    Function(double progress)? onProgress,
  }) async {
    try {
      // Create secure path
      final path = 'users/$userId/generations/$generationId/image.png';
      final ref = _storage.ref(path);
      
      // Set metadata
      final metadata = SettableMetadata(
        contentType: mimeType,
        customMetadata: {
          'userId': userId,
          'generationId': generationId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
      
      // Create upload task
      final uploadTask = ref.putData(imageData, metadata);
      
      // Track progress
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });
      
      // Wait for completion
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw StorageException(
        message: 'Failed to upload image: ${e.message}',
        code: e.code,
      );
    }
  }
  
  // Generate signed URL with expiration
  Future<String> getTemporaryUrl({
    required String path,
    Duration expiration = const Duration(hours: 1),
  }) async {
    final ref = _storage.ref(path);
    
    // This would require Cloud Functions for true signed URLs
    // For now, return regular download URL
    return await ref.getDownloadURL();
  }
  
  // Delete with error handling
  Future<void> deleteGenerationImages({
    required String userId,
    required String generationId,
  }) async {
    try {
      final basePath = 'users/$userId/generations/$generationId';
      
      // List all files in the generation folder
      final listResult = await _storage.ref(basePath).listAll();
      
      // Delete all files
      final deleteFutures = listResult.items.map((ref) => ref.delete());
      await Future.wait(deleteFutures);
      
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') {
        throw StorageException(
          message: 'Failed to delete images: ${e.message}',
          code: e.code,
        );
      }
      // Ignore if files don't exist
    }
  }
  
  // Storage management
  Future<StorageStats> getUserStorageStats(String userId) async {
    try {
      final userPath = 'users/$userId';
      final listResult = await _storage.ref(userPath).listAll();
      
      int totalSize = 0;
      int fileCount = 0;
      
      for (final item in listResult.items) {
        final metadata = await item.getMetadata();
        totalSize += metadata.size ?? 0;
        fileCount++;
      }
      
      return StorageStats(
        totalBytes: totalSize,
        fileCount: fileCount,
        formattedSize: _formatBytes(totalSize),
      );
    } catch (e) {
      throw StorageException(
        message: 'Failed to calculate storage stats',
      );
    }
  }
}
```

### 5. Security Rules

#### Firestore Security Rules
```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth != null && request.auth.uid == userId;
    }
    
    function isValidGeneration() {
      return request.resource.data.keys().hasAll([
        'userId', 'prompt', 'status', 'createdAt'
      ]) &&
      request.resource.data.userId == request.auth.uid &&
      request.resource.data.prompt is string &&
      request.resource.data.prompt.size() > 0 &&
      request.resource.data.prompt.size() <= 500;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isOwner(userId);
      allow create: if isOwner(userId) && 
        request.resource.data.keys().hasAll([
          'email', 'displayName', 'createdAt'
        ]);
      allow update: if isOwner(userId) &&
        // Prevent updating sensitive fields
        !request.resource.data.diff(resource.data).affectedKeys()
          .hasAny(['freeGenerationsUsed', 'isPro', 'subscriptionId']);
    }
    
    // Generations collection
    match /generations/{generationId} {
      allow read: if isAuthenticated() && 
        resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated() && isValidGeneration();
      allow update: if isOwner(resource.data.userId) &&
        // Only allow specific field updates
        request.resource.data.diff(resource.data).affectedKeys()
          .hasOnly(['isFavorite', 'tags', 'localPath']);
      allow delete: if isOwner(resource.data.userId);
    }
    
    // Admin collection (read-only for users)
    match /admin/{document=**} {
      allow read: if false;  // Admin SDK only
      allow write: if false;
    }
    
    // Public data (cached, read-only)
    match /public/{document=**} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

#### Storage Security Rules
```javascript
// storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth != null && request.auth.uid == userId;
    }
    
    function isValidImage() {
      return request.resource.contentType.matches('image/.*') &&
             request.resource.size < 10 * 1024 * 1024; // 10MB max
    }
    
    // User uploads
    match /users/{userId}/{allPaths=**} {
      allow read: if isOwner(userId);
      allow write: if isOwner(userId) && isValidImage();
      allow delete: if isOwner(userId);
    }
    
    // Public assets (read-only)
    match /public/{allPaths=**} {
      allow read: if true;
      allow write: if false;
    }
    
    // Temporary uploads (auto-deleted after 24h)
    match /temp/{userId}/{allPaths=**} {
      allow read: if isOwner(userId);
      allow write: if isOwner(userId) && isValidImage();
      // Cloud Function handles cleanup
    }
  }
}
```

### 6. Real-time Synchronization

#### Live Data Streams
```dart
class RealtimeSync {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, StreamSubscription> _subscriptions = {};
  
  // Sync generation status
  Stream<GenerationModel?> syncGenerationStatus(String generationId) {
    return _firestore.generations
        .doc(generationId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return snapshot.data();
        });
  }
  
  // Multi-document sync
  void syncUserActivity({
    required String userId,
    required Function(UserActivity) onActivity,
  }) {
    // Listen to multiple collections
    final streams = [
      _firestore.generations
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots(),
      
      _firestore.collection('user_sessions')
          .where('userId', isEqualTo: userId)
          .where('active', isEqualTo: true)
          .snapshots(),
    ];
    
    // Combine streams
    _subscriptions['userActivity'] = 
        CombineLatestStream.list(streams).listen((snapshots) {
      final latestGeneration = snapshots[0].docs.isNotEmpty
          ? GenerationConverter.fromFirestore(snapshots[0].docs.first, null)
          : null;
      
      final activeSessions = snapshots[1].docs.length;
      
      onActivity(UserActivity(
        lastGeneration: latestGeneration,
        activeSessions: activeSessions,
        lastActiveAt: DateTime.now(),
      ));
    });
  }
  
  // Cleanup subscriptions
  void dispose() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}
```

### 7. Offline Support

#### Offline Persistence
```dart
class OfflineManager {
  static Future<void> configureOfflineSupport() async {
    // Enable offline persistence
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 100 * 1024 * 1024, // 100MB cache
    );
    
    // Configure auth persistence
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }
  
  // Sync queue for offline actions
  static Future<void> queueOfflineAction({
    required OfflineAction action,
    required Map<String, dynamic> data,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing queue
    final queueJson = prefs.getString('offline_queue') ?? '[]';
    final queue = List<Map<String, dynamic>>.from(jsonDecode(queueJson));
    
    // Add new action
    queue.add({
      'id': const Uuid().v4(),
      'action': action.name,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Save updated queue
    await prefs.setString('offline_queue', jsonEncode(queue));
  }
  
  // Process offline queue when online
  static Future<void> processOfflineQueue() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;
    
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString('offline_queue') ?? '[]';
    final queue = List<Map<String, dynamic>>.from(jsonDecode(queueJson));
    
    final processed = <String>[];
    
    for (final item in queue) {
      try {
        await _processOfflineItem(item);
        processed.add(item['id']);
      } catch (e) {
        print('Failed to process offline item: $e');
      }
    }
    
    // Remove processed items
    queue.removeWhere((item) => processed.contains(item['id']));
    await prefs.setString('offline_queue', jsonEncode(queue));
  }
}
```

### 8. Analytics & Monitoring

#### Firebase Analytics Integration
```dart
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  // Track generation events
  static Future<void> logGenerationStarted({
    required String model,
    required String style,
    required GenerationMode mode,
  }) async {
    await _analytics.logEvent(
      name: 'generation_started',
      parameters: {
        'model': model,
        'style': style,
        'mode': mode.name,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  // Track conversions
  static Future<void> logSubscriptionStarted({
    required String plan,
    required double price,
    required String currency,
  }) async {
    await _analytics.logEvent(
      name: 'begin_checkout',
      parameters: {
        'value': price,
        'currency': currency,
        'items': [
          {
            'item_id': plan,
            'item_name': 'PrintCraft Pro Subscription',
            'item_category': 'subscription',
            'price': price,
          }
        ],
      },
    );
  }
  
  // User properties
  static Future<void> setUserProperties({
    required bool isPro,
    required int totalGenerations,
    required String preferredStyle,
  }) async {
    await _analytics.setUserProperty(
      name: 'subscription_status',
      value: isPro ? 'pro' : 'free',
    );
    
    await _analytics.setUserProperty(
      name: 'generation_tier',
      value: _getGenerationTier(totalGenerations),
    );
    
    await _analytics.setUserProperty(
      name: 'preferred_style',
      value: preferredStyle,
    );
  }
}
```

### 9. Cloud Functions Integration

#### Function Triggers
```dart
// Cloud Function examples (TypeScript)
/*
// Thumbnail generation on upload
export const generateThumbnail = functions.storage
  .object()
  .onFinalize(async (object) => {
    if (!object.contentType?.startsWith('image/')) return;
    
    const filePath = object.name!;
    const fileName = path.basename(filePath);
    const bucketName = object.bucket;
    
    // Generate thumbnail
    const tempFilePath = path.join(os.tmpdir(), fileName);
    const thumbnailPath = filePath.replace('/image.png', '/thumbnail.png');
    
    await storage.bucket(bucketName).file(filePath).download({
      destination: tempFilePath,
    });
    
    await sharp(tempFilePath)
      .resize(200, 200)
      .toFile(tempFilePath + '_thumb');
    
    await storage.bucket(bucketName).upload(tempFilePath + '_thumb', {
      destination: thumbnailPath,
      metadata: { contentType: 'image/png' },
    });
  });

// Cleanup old generations
export const cleanupOldGenerations = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - 30);
    
    const snapshot = await firestore
      .collection('generations')
      .where('createdAt', '<', cutoffDate)
      .where('isFavorite', '==', false)
      .limit(100)
      .get();
    
    const batch = firestore.batch();
    
    for (const doc of snapshot.docs) {
      batch.delete(doc.ref);
      // Also delete storage files
    }
    
    await batch.commit();
  });
*/
```

### 10. Error Handling

#### Comprehensive Error Management
```dart
class FirebaseErrorHandler {
  static AppError handleError(dynamic error) {
    if (error is FirebaseAuthException) {
      return _handleAuthError(error);
    } else if (error is FirebaseException) {
      return _handleFirebaseError(error);
    } else {
      return AppError(
        code: 'unknown',
        message: 'An unexpected error occurred',
        originalError: error,
      );
    }
  }
  
  static AppError _handleAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return AppError(
          code: error.code,
          message: 'No account found with this email',
          userAction: UserAction.checkEmail,
        );
      case 'wrong-password':
        return AppError(
          code: error.code,
          message: 'Incorrect password',
          userAction: UserAction.checkPassword,
        );
      case 'email-already-in-use':
        return AppError(
          code: error.code,
          message: 'An account already exists with this email',
          userAction: UserAction.tryLogin,
        );
      case 'network-request-failed':
        return AppError(
          code: error.code,
          message: 'Network error. Please check your connection',
          userAction: UserAction.checkNetwork,
        );
      default:
        return AppError(
          code: error.code,
          message: error.message ?? 'Authentication failed',
        );
    }
  }
}
```

## Best Practices

### Security
1. **Never trust client data** - Validate everything server-side
2. **Use security rules** extensively - They're your first line of defense
3. **Implement rate limiting** for sensitive operations
4. **Sanitize user input** before storing
5. **Use least privilege** principle for all permissions

### Performance
1. **Enable offline persistence** for better UX
2. **Use compound indexes** for complex queries
3. **Paginate large collections** (limit to 20-50 items)
4. **Cache frequently accessed data** locally
5. **Batch operations** when possible

### Cost Optimization
1. **Monitor usage** in Firebase Console
2. **Set budget alerts** for all services
3. **Use Cloud Functions** for heavy processing
4. **Implement data retention** policies
5. **Optimize image storage** with compression

## Common Patterns

### User Onboarding
```dart
Future<void> onboardNewUser(User firebaseUser) async {
  final batch = FirebaseFirestore.instance.batch();
  
  // Create user document
  final userRef = FirebaseFirestore.instance.users.doc(firebaseUser.uid);
  batch.set(userRef, UserModel.newUser(firebaseUser).toMap());
  
  // Create initial data
  final welcomeRef = FirebaseFirestore.instance.generations.doc();
  batch.set(welcomeRef, GenerationModel.welcome(firebaseUser.uid).toMap());
  
  // Set analytics
  await AnalyticsService.logSignUp(method: 'email');
  
  await batch.commit();
}
```

### Data Migration
```dart
Future<void> migrateUserData(String fromVersion, String toVersion) async {
  final users = await FirebaseFirestore.instance.users.get();
  
  for (final userDoc in users.docs) {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final userData = userDoc.data();
      
      // Apply migrations based on versions
      if (fromVersion == '1.0.0' && toVersion == '2.0.0') {
        userData['newField'] = 'defaultValue';
        userData['schemaVersion'] = '2.0.0';
      }
      
      transaction.update(userDoc.reference, userData.toMap());
    });
  }
}
```