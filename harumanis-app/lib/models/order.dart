class Order {
  final int id;
  final int farmId;
  final String farmName;
  final String? farmerWhatsapp;
  final int buyerId;
  final String buyerName;
  final String? buyerAddress;
  final double quantityKg;
  final double pricePerKg;
  final double totalPrice;
  final DateTime? targetHarvestDate;
  final String? notes;
  final String status;
  final String? billplzBillId;
  final bool billplzPaid;
  final DateTime? paidAt;
  final DateTime? confirmedAt;
  final DateTime? harvestedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.farmId,
    required this.farmName,
    this.farmerWhatsapp,
    required this.buyerId,
    required this.buyerName,
    this.buyerAddress,
    required this.quantityKg,
    required this.pricePerKg,
    required this.totalPrice,
    this.targetHarvestDate,
    this.notes,
    required this.status,
    this.billplzBillId,
    required this.billplzPaid,
    this.paidAt,
    this.confirmedAt,
    this.harvestedAt,
    this.deliveredAt,
    this.cancelledAt,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id'] as int,
        farmId: j['farm_id'] as int,
        farmName: j['farm_name'] as String,
        farmerWhatsapp: j['farmer_whatsapp'] as String?,
        buyerId: j['buyer_id'] as int,
        buyerName: j['buyer_name'] as String,
        buyerAddress: j['buyer_address'] as String?,
        quantityKg: (j['quantity_kg'] as num).toDouble(),
        pricePerKg: (j['price_per_kg'] as num).toDouble(),
        totalPrice: (j['total_price'] as num).toDouble(),
        targetHarvestDate: j['target_harvest_date'] != null
            ? DateTime.tryParse(j['target_harvest_date'] as String)
            : null,
        notes: j['notes'] as String?,
        status: j['status'] as String,
        billplzBillId: j['billplz_bill_id'] as String?,
        billplzPaid: j['billplz_paid'] as bool,
        paidAt: j['paid_at'] != null ? DateTime.tryParse(j['paid_at'] as String) : null,
        confirmedAt: j['confirmed_at'] != null ? DateTime.tryParse(j['confirmed_at'] as String) : null,
        harvestedAt: j['harvested_at'] != null ? DateTime.tryParse(j['harvested_at'] as String) : null,
        deliveredAt: j['delivered_at'] != null ? DateTime.tryParse(j['delivered_at'] as String) : null,
        cancelledAt: j['cancelled_at'] != null ? DateTime.tryParse(j['cancelled_at'] as String) : null,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}
