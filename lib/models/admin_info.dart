/// A user currently holding the `admin` custom claim — returned by the
/// `listAdmins` Cloud Function (Firebase custom claims can't be queried from
/// Firestore or the client SDK directly).
class AdminInfo {
  final String uid;
  final String? email;
  final bool disabled;

  const AdminInfo({required this.uid, this.email, this.disabled = false});

  factory AdminInfo.fromMap(Map<String, dynamic> map) => AdminInfo(
    uid: map['uid'] as String,
    email: map['email'] as String?,
    disabled: map['disabled'] as bool? ?? false,
  );
}
