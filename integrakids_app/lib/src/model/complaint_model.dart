
class ComplaintModel {
  final String complaint;

  ComplaintModel({required this.complaint});

  factory ComplaintModel.fromMap(Map<String, dynamic> json) {
    switch (json) {
      case {
        'complaint': String complaint,
      }:
        return ComplaintModel(
          complaint: complaint,
        );
      default:
        throw ArgumentError('Invalid Json');
    }
  }
}