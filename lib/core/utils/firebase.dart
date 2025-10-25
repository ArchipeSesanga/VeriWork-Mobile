import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

// Collection refs
CollectionReference usersRef = firestore.collection('users');
CollectionReference adminsRef = firestore.collection('admins');
CollectionReference appointmentsRef = firestore.collection("appointments");
CollectionReference reviewsRef = firestore.collection('reviews');
