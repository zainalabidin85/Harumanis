class FarmOrder {
  final int id;
  final int farmId;
  final int buyerId;
  final String buyerName;
  final String? buyerAddress;
  final double quantityKg;
  final double pricePerKg;
  final double totalPrice;
  final String status;
  final bool billplzPaid;
  final String? notes;
  final DateTime? targetHarvestDate;
  final DateTime? paidAt;
  final DateTime createdAt;

  const FarmOrder({
    required this.id,
    required this.farmId,
    required this.buyerId,
    required this.buyerName,
    this.buyerAddress,
    required this.quantityKg,
    required this.pricePerKg,
    required this.totalPrice,
    required this.status,
    required this.billplzPaid,
    required this.createdAt,
    this.notes,
    this.targetHarvestDate,
    this.paidAt,
  });

  factory FarmOrder.fromJson(Map<String, dynamic> j) => FarmOrder(
        id: j['id'] as int,
        farmId: j['farm_id'] as int,
        buyerId: j['buyer_id'] as int,
        buyerName: j['buyer_name'] as String? ?? 'Unknown',
        buyerAddress: j['buyer_address'] as String?,
        quantityKg: (j['quantity_kg'] as num).toDouble(),
        pricePerKg: (j['price_per_kg'] as num).toDouble(),
        totalPrice: (j['total_price'] as num).toDouble(),
        status: j['status'] as String,
        billplzPaid: j['billplz_paid'] as bool? ?? false,
        notes: j['notes'] as String?,
        targetHarvestDate: j['target_harvest_date'] != null
            ? DateTime.parse(j['target_harvest_date'] as String)
            : null,
        paidAt: j['paid_at'] != null
            ? DateTime.parse(j['paid_at'] as String)
            : null,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  FarmOrder copyWith({String? status}) => FarmOrder(
        id: id,
        farmId: farmId,
        buyerId: buyerId,
        buyerName: buyerName,
        buyerAddress: buyerAddress,
        quantityKg: quantityKg,
        pricePerKg: pricePerKg,
        totalPrice: totalPrice,
        status: status ?? this.status,
        billplzPaid: billplzPaid,
        notes: notes,
        targetHarvestDate: targetHarvestDate,
        paidAt: paidAt,
        createdAt: createdAt,
      );
}
