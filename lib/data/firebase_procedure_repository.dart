import 'package:cloud_firestore/cloud_firestore.dart';
import '../state/in_memory_procedures.dart';

class FirebaseProcedureRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveProcedure({
    required ProcedureDraft procedure,
    required String adminUid,
  }) async {
    await _firestore.collection('procedures').add(
          procedure.toJson(adminUid: adminUid),
        );
  }
}
