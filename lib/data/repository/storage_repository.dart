import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageRepository {
  final FirebaseStorage _storage;

  StorageRepository({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Upload image file with optional real-time progress callback
  Future<String> uploadEventImage(
    File file,
    String eventId, {
    void Function(double progress)? onProgress,
  }) async {
    final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('events/$eventId/images/$fileName');
    
    final uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.totalBytes > 0) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        }
      });
    }

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Upload video file with optional real-time progress callback
  Future<String> uploadEventVideo(
    File file,
    String eventId, {
    void Function(double progress)? onProgress,
  }) async {
    final fileName = 'vid_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final ref = _storage.ref().child('events/$eventId/videos/$fileName');
    
    final uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: 'video/mp4'),
    );

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.totalBytes > 0) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        }
      });
    }

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}
