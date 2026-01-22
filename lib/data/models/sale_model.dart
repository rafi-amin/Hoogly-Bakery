/// Model mapped to the `sales` table.
class SaleModel {
  const SaleModel({
    this.id,
    required this.invoiceNo,
    required this.createdAt,
    required this.saleType,
    required this.subtotal,
    required this.discountType,
    required this.discountValue,
    required this.total,
    required this.paymentMethod,
    required this.paidAmount,
    required this.dueAmount,
    this.cashierId,
    this.customerName,
    this.customerPhone,
    this.note,
  });

  final int? id;
  final String invoiceNo;
  final DateTime createdAt;
  final String saleType;
  final double subtotal;
  final String discountType;
  final double discountValue;
  final double total;
  final String paymentMethod;
  final double paidAmount;
  final double dueAmount;
  final int? cashierId;
  final String? customerName;
  final String? customerPhone;
  final String? note;

  factory SaleModel.fromMap(Map<String, Object?> map) {
    final invoiceNo = map['invoice_no'];
    final createdAt = map['created_at'];
    final saleType = map['sale_type'];
    final subtotal = map['subtotal'];
    final discountType = map['discount_type'];
    final discountValue = map['discount_value'];
    final total = map['total'];
    final paymentMethod = map['payment_method'];
    final paidAmount = map['paid_amount'];
    final dueAmount = map['due_amount'];

    if (invoiceNo == null ||
        createdAt == null ||
        saleType == null ||
        subtotal == null ||
        discountType == null ||
        discountValue == null ||
        total == null ||
        paymentMethod == null ||
        paidAmount == null ||
        dueAmount == null) {
      throw ArgumentError('Missing required sale fields in map: $map');
    }

    return SaleModel(
      id: map['id'] as int?,
      invoiceNo: invoiceNo as String,
      createdAt: DateTime.parse(createdAt as String),
      saleType: saleType as String,
      subtotal: (subtotal as num).toDouble(),
      discountType: discountType as String,
      discountValue: (discountValue as num).toDouble(),
      total: (total as num).toDouble(),
      paymentMethod: paymentMethod as String,
      paidAmount: (paidAmount as num).toDouble(),
      dueAmount: (dueAmount as num).toDouble(),
      cashierId: map['cashier_id'] as int?,
      customerName: map['customer_name'] as String?,
      customerPhone: map['customer_phone'] as String?,
      note: map['note'] as String?,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'invoice_no': invoiceNo,
        'created_at': createdAt.toIso8601String(),
        'sale_type': saleType,
        'subtotal': subtotal,
        'discount_type': discountType,
        'discount_value': discountValue,
        'total': total,
        'payment_method': paymentMethod,
        'paid_amount': paidAmount,
        'due_amount': dueAmount,
        'cashier_id': cashierId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'note': note,
      };

  SaleModel copyWith({
    int? id,
    String? invoiceNo,
    DateTime? createdAt,
    String? saleType,
    double? subtotal,
    String? discountType,
    double? discountValue,
    double? total,
    String? paymentMethod,
    double? paidAmount,
    double? dueAmount,
    int? cashierId,
    String? customerName,
    String? customerPhone,
    String? note,
  }) {
    return SaleModel(
      id: id ?? this.id,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      createdAt: createdAt ?? this.createdAt,
      saleType: saleType ?? this.saleType,
      subtotal: subtotal ?? this.subtotal,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paidAmount: paidAmount ?? this.paidAmount,
      dueAmount: dueAmount ?? this.dueAmount,
      cashierId: cashierId ?? this.cashierId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      note: note ?? this.note,
    );
  }
}

