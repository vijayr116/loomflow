import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class JobModel extends Equatable {
  final String id;
  final String weaverId;
  final String sellerId;
  final String weaverName;
  final String designImage;
  final String materialDetails;
  final double advanceAmount;
  final double totalAmount;
  final String status;
  final DateTime createdAt;

  const JobModel({
    required this.id,
    required this.weaverId,
    required this.sellerId,
    required this.weaverName,
    required this.designImage,
    required this.materialDetails,
    required this.advanceAmount,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  factory JobModel.fromMap(Map<String, dynamic> map, String docId) {
    return JobModel(
      id: docId,
      weaverId: map['weaverId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      weaverName: map['weaverName'] ?? '',
      designImage: map['designImage'] ?? '',
      materialDetails: map['materialDetails'] ?? '',
      advanceAmount: (map['advanceAmount'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'CREATED',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weaverId': weaverId,
      'sellerId': sellerId,
      'weaverName': weaverName,
      'designImage': designImage,
      'materialDetails': materialDetails,
      'advanceAmount': advanceAmount,
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  JobModel copyWith({
    String? weaverId,
    String? id,
    String? sellerId,
    String? weaverName,
    String? designImage,
    String? materialDetails,
    double? advanceAmount,
    double? totalAmount,
    String? status,
    DateTime? createdAt,
  }) {
    return JobModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      weaverId: weaverId ?? this.weaverId,
      weaverName: weaverName ?? this.weaverName,
      designImage: designImage ?? this.designImage,
      materialDetails: materialDetails ?? this.materialDetails,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    sellerId,
    weaverId,
    weaverName,
    designImage,
    materialDetails,
    advanceAmount,
    totalAmount,
    status,
    createdAt,
  ];
}
