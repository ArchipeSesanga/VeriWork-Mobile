import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class SelfieService {
  // Azure Cognitive Services Face API
  static const String _baseUrl =
      "https://veriworkface.cognitiveservices.azure.com";

  // Your Azure subscription key
  static const String _subscriptionKey =
      "7YpvVuEXRisLzkGgCITn45Zqs5LawczwLgpGve5F7ofr2Y1pc7B1JQQJ99BJACYeBjFXJ3w3AAAKACOGT5yC";
  static const String _region = "eastus";

  Future<Map<String, dynamic>> uploadSelfie(File selfieFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Face Detection endpoint - detects if there's a face in the image
      final uri =
          Uri.parse("$_baseUrl/face/v1.0/detect").replace(queryParameters: {
        'returnFaceId': 'true',
        'returnFaceLandmarks': 'false',
        'returnFaceAttributes': 'age,gender,glasses,emotion',
        'recognitionModel': 'recognition_04', // Latest model
        'detectionModel': 'detection_03',
      });

      // Read image as bytes for Azure API
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
            'Azure Face API failed: ${response.statusCode} - ${response.body}');
      }

      final responseData = jsonDecode(response.body);

      // Handle Azure Face API response (returns array of faces)
      return _handleAzureResponse(responseData);
    } catch (e) {
      throw Exception('Selfie upload failed: $e');
    }
  }

  Map<String, dynamic> _handleAzureResponse(dynamic azureResponse) {
    if (azureResponse is List) {
      if (azureResponse.isEmpty) {
        throw Exception(
            'No face detected in the image. Please ensure your face is clearly visible.');
      } else if (azureResponse.length > 1) {
        throw Exception(
            'Multiple faces detected. Please capture only your face in the selfie.');
      }

      // Single face detected - success!
      final faceData = azureResponse[0];
      return {
        'success': true,
        'faceId': faceData['faceId'],
        'faceDetected': true,
        'verificationStatus':
            'pending', // Will verify against employee photo later
        'faceAttributes': faceData['faceAttributes'],
        'message': 'Face detected successfully!',
        'confidence': 0.95, // High confidence for single face detection
      };
    }

    throw Exception('Unexpected response format from Azure Face API');
  }

  // Optional: Method to verify against a reference face (if you have employee photos)
  Future<Map<String, dynamic>> verifyAgainstReference(
      String detectedFaceId, String referenceFaceId) async {
    try {
      final uri = Uri.parse("$_baseUrl/face/v1.0/verify");

      final requestBody = jsonEncode({
        'faceId1': detectedFaceId,
        'faceId2': referenceFaceId,
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

      final verificationResult = jsonDecode(response.body);

      return {
        'success': true,
        'isIdentical': verificationResult['isIdentical'],
        'confidence': verificationResult['confidence'],
        'verificationStatus':
            verificationResult['isIdentical'] ? 'verified' : 'rejected',
        'message': verificationResult['isIdentical']
            ? 'Face verification successful!'
            : 'Face does not match employee records.',
      };
    } catch (e) {
      throw Exception('Face verification error: $e');
    }
  }
}
