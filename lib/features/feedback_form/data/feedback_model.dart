// ─── Feedback Form Data Models ───────────────────────────────────────────────

class CustomerFeedbackData {
  final String name;
  final String mobile;
  final String email;
  final int rating;
  final String? heardFrom;
  final String? customerType;
  final String? occasion;

  const CustomerFeedbackData({
    required this.name,
    required this.mobile,
    required this.email,
    required this.rating,
    this.heardFrom,
    this.customerType,
    this.occasion,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'mobile': mobile,
    'email': email,
    'rating': rating,
    'heard_from': heardFrom,
    'customer_type': customerType,
    'occasion': occasion,
  };
}

// ─── Purchase Category: Ready Product / Exchange (generic UID) ────────────────

class ProductUIDEntry {
  final String uid;
  final double mrp;

  const ProductUIDEntry({required this.uid, required this.mrp});

  Map<String, dynamic> toJson() => {'uid': uid, 'mrp': mrp};
}

// ─── Purchase Category: Upgrade ───────────────────────────────────────────────

/// The old product being traded in during an Upgrade
class OldProductEntry {
  final String uid;
  final double mrp;

  const OldProductEntry({required this.uid, required this.mrp});

  Map<String, dynamic> toJson() => {'uid': uid, 'mrp': mrp};
}

/// Sub-category chosen in Q11 when Upgrade is selected
enum UpgradeSubCategory { readyProduct, order }

extension UpgradeSubCategoryX on UpgradeSubCategory {
  String get label =>
      this == UpgradeSubCategory.readyProduct ? 'Ready Product' : 'Order';
}

/// Full data for an Upgrade purchase
class UpgradeData {
  /// Q10 – old product being exchanged
  final OldProductEntry oldProduct;

  /// Q11 – sub-category (Ready Product | Order)
  final UpgradeSubCategory subCategory;

  /// Q12 – order amount (only when subCategory == order)
  final double? orderAmount;

  /// New products added via UID table (only when subCategory == readyProduct)
  final List<ProductUIDEntry> newProducts;

  const UpgradeData({
    required this.oldProduct,
    required this.subCategory,
    this.orderAmount,
    this.newProducts = const [],
  });

  /// Upgrade Amount = newValue − oldMRP  (clamped to 0)
  double get upgradeAmount {
    final newValue = subCategory == UpgradeSubCategory.order
        ? (orderAmount ?? 0)
        : newProducts.fold(0.0, (s, p) => s + p.mrp);
    final diff = newValue - oldProduct.mrp;
    return diff < 0 ? 0 : diff;
  }

  Map<String, dynamic> toJson() => {
    'old_product': oldProduct.toJson(),
    'sub_category': subCategory.label,
    if (subCategory == UpgradeSubCategory.order) 'order_amount': orderAmount,
    if (subCategory == UpgradeSubCategory.readyProduct)
      'new_products': newProducts.map((p) => p.toJson()).toList(),
    'upgrade_amount': upgradeAmount,
  };
}

// ─── Purchase Category: PYDS ──────────────────────────────────────────────────

/// A single diamond configured via the shape / carat / color / clarity sliders
class PydsProductEntry {
  final String shape; // e.g. 'Round'
  final String carat; // e.g. '2.00'
  final String color; // e.g. 'E'
  final String clarity; // e.g. 'VVS2'
  final double mrp;

  const PydsProductEntry({
    required this.shape,
    required this.carat,
    required this.color,
    required this.clarity,
    required this.mrp,
  });

  /// Human-readable label shown in the product table
  String get label => '$shape ${carat}ct $color $clarity';

  /// Installment = 8% of MRP
  double get installment => mrp * 0.08;

  /// Down payment = 20% of MRP
  double get downPayment => mrp * 0.20;

  Map<String, dynamic> toJson() => {
    'shape': shape,
    'carat': carat,
    'color': color,
    'clarity': clarity,
    'mrp': mrp,
    'installment': installment,
    'down_payment': downPayment,
    'label': label,
  };
}

/// Aggregated PYDS data for a submission
class PydsData {
  final List<PydsProductEntry> products;

  const PydsData({required this.products});

  double get totalMrp => products.fold(0, (s, p) => s + p.mrp);
  double get totalDownPayment => products.fold(0, (s, p) => s + p.downPayment);
  double get totalInstallment => products.fold(0, (s, p) => s + p.installment);

  Map<String, dynamic> toJson() => {
    'products': products.map((p) => p.toJson()).toList(),
    'total_mrp': totalMrp,
    'total_down_payment': totalDownPayment,
    'total_installment': totalInstallment,
  };
}

// ─── Purchase Category Enum ───────────────────────────────────────────────────

enum PurchaseCategory { readyProduct, upgrade, pyds, exchange }

extension PurchaseCategoryX on PurchaseCategory {
  String get label => switch (this) {
    PurchaseCategory.readyProduct => 'Ready Product',
    PurchaseCategory.upgrade => 'Upgrade',
    PurchaseCategory.pyds => 'PYDS',
    PurchaseCategory.exchange => 'Exchange',
  };

  static PurchaseCategory fromLabel(String label) => switch (label) {
    'Ready Product' => PurchaseCategory.readyProduct,
    'Upgrade' => PurchaseCategory.upgrade,
    'PYDS' => PurchaseCategory.pyds,
    'Exchange' => PurchaseCategory.exchange,
    _ => PurchaseCategory.readyProduct,
  };
}

// ─── Sales Executive Data (all categories) ───────────────────────────────────

class SalesExecutiveData {
  final String salesStaff;
  final PurchaseCategory purchaseCategory;

  /// Populated when category is readyProduct or exchange
  final List<ProductUIDEntry> products;

  /// Populated when category is upgrade
  final UpgradeData? upgradeData;

  /// Populated when category is pyds
  final PydsData? pydsData;

  const SalesExecutiveData({
    required this.salesStaff,
    required this.purchaseCategory,
    this.products = const [],
    this.upgradeData,
    this.pydsData,
  });

  double get totalMrp {
    switch (purchaseCategory) {
      case PurchaseCategory.readyProduct:
      case PurchaseCategory.exchange:
        return products.fold(0, (s, p) => s + p.mrp);
      case PurchaseCategory.upgrade:
        return upgradeData?.upgradeAmount ?? 0;
      case PurchaseCategory.pyds:
        return pydsData?.totalMrp ?? 0;
    }
  }

  int get totalUids => products.length;

  Map<String, dynamic> toJson() {
    final base = <String, dynamic>{
      'sales_staff': salesStaff,
      'purchase_category': purchaseCategory.label,
    };

    switch (purchaseCategory) {
      case PurchaseCategory.readyProduct:
      case PurchaseCategory.exchange:
        base['products'] = products.map((p) => p.toJson()).toList();
        base['total_uids'] = totalUids;
        base['total_mrp'] = totalMrp;
        break;
      case PurchaseCategory.upgrade:
        base['upgrade'] = upgradeData?.toJson();
        break;
      case PurchaseCategory.pyds:
        base['pyds'] = pydsData?.toJson();
        break;
    }

    return base;
  }
}

// ─── Top-level combined form data ─────────────────────────────────────────────

class FeedbackFormData {
  final CustomerFeedbackData customer;
  final SalesExecutiveData sales;

  const FeedbackFormData({required this.customer, required this.sales});

  Map<String, dynamic> toJson() => {...customer.toJson(), ...sales.toJson()};
}
