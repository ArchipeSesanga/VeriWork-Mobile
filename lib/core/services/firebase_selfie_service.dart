import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class SelfieService {
  // Azure Cognitive Services Face API
  static const String _baseUrl =
      "https://veriworkface.cognitiveservices.azure.com";
  static const String _subscriptionKey =
      "7YpvVuEXRisLzkGgCITn45Zqs5LawczwLgpGve5F7ofr2Y1pc7B1JQQJ99BJACYeBjFXJ3w3AAAKACOGT5yC";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> uploadSelfie(File selfieFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Step 1: Detect face in the selfie
      final detectionResult = await _detectFace(selfieFile);
      final detectedFaceId = detectionResult['faceId'];

      // Step 2: Get employee's reference Face ID from Firestore
      final employeeFaceId = await _getEmployeeFaceId(user.uid);

      if (employeeFaceId == null) {
        // No reference photo - store this as reference for future
        await _storeReferenceFaceId(user.uid, detectedFaceId);
        return {
          'success': true,
          'faceDetected': true,
          'verificationStatus': 'pending',
          'message':
              'First-time verification. Reference photo saved for future.',
          'isFirstTime': true,
        };
      }

      // Step 3: Compare selfie with employee reference photo
      final verificationResult =
          await _verifyFaces(detectedFaceId, employeeFaceId);

      return {
        'success': true,
        'faceDetected': true,
        'isIdentical': verificationResult['isIdentical'],
        'confidence': verificationResult['confidence'],
        'verificationStatus':
            verificationResult['isIdentical'] ? 'verified' : 'rejected',
        'message': verificationResult['isIdentical']
            ? 'Identity verified successfully!'
            : 'Face does not match employee records.',
      };
    } catch (e) {
      throw Exception('Selfie verification failed: $e');
    }
  }

  Future<Map<String, dynamic>> _detectFace(File selfieFile) async {
    final uri =
        Uri.parse("$_baseUrl/face/v1.0/detect").replace(queryParameters: {
      'returnFaceId': 'true',
      'returnFaceLandmarks': 'false',
      'recognitionModel': 'recognition_04',
      'detectionModel': 'detection_03',
    });

    final imageBytes = await selfieFile.readAsBytes();

    final response = await http.post(
      uri,
      headers: {
        'Ocp-Apim-Subscription-Key': _subscriptionKey,
        'Content-Type': 'application/octet-stream',
      },
      body: imageBytes,
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Face detection failed: ${response.statusCode} - ${response.body}');
    }

    final responseData = jsonDecode(response.body);

    if (responseData is List) {
      if (responseData.isEmpty) {
        throw Exception(
            'No face detected in the image. Please ensure your face is clearly visible.');
      } else if (responseData.length > 1) {
        throw Exception(
            'Multiple faces detected. Please capture only your face in the selfie.');
      }

      return {
        'faceId': responseData[0]['faceId'],
        'faceRectangle': responseData[0]['faceRectangle'],
      };
    }

    throw Exception('Unexpected response format from Azure Face API');
  }

  Future<String?> _getEmployeeFaceId(String userId) async {
    try {
      final doc = await _firestore.collection('Users').doc(userId).get();
      return doc.data()?['azureFaceId'] as String?;
    } catch (e) {
      print('Error getting employee Face ID: $e');
      return null;
    }
  }

  Future<void> _storeReferenceFaceId(String userId, String faceId) async {
    try {
      await _firestore.collection('Users').doc(userId).update({
        'azureFaceId': faceId,
        'referencePhotoStored': true,
        'lastVerificationUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error storing reference Face ID: $e');
      throw Exception('Failed to save reference photo');
    }
  }

  Future<Map<String, dynamic>> _verifyFaces(
      String faceId1, String faceId2) async {
    final uri = Uri.parse("$_baseUrl/face/v1.0/verify");

    final requestBody = jsonEncode({
      'faceId1': faceId1,
      'faceId2': faceId2,
    });

    final response = await http.post(
      uri,
      headers: {
        'Ocp-Apim-Subscription-Key': _subscriptionKey,
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Face verification failed: ${response.statusCode} - ${response.body}');
    }

    return jsonDecode(response.body);
  }
}
