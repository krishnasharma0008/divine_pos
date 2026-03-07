// ─── Feedback Form Data Models ───────────────────────────────────────────────

class CustomerFeedbackData {
  //final int? orderno;
  final String customer_type; // Q3
  final String customer_name; // Q5
  final String contact_no; // Q6
  final String email; // Q7
  final int experience_rating; // Q1
  final String discovery_source; // Q2
  final String occasion;

  const CustomerFeedbackData({
    //required this.orderno,
    required this.customer_type,
    required this.customer_name,
    required this.contact_no,
    required this.email,
    required this.experience_rating,
    required this.discovery_source,
    required this.occasion,
  });

  Map<String, dynamic> toJson() => {
    //'orderno': orderno,
    'customer_type': customer_type,
    'customer_name': customer_name,
    'contact_no': contact_no,
    'email': email,
    'experience_rating': experience_rating,
    'discovery_source': discovery_source,
    'occasion': occasion,
  };
}

// ─── Purchase Category: Ready Product / Exchange (product_detail rows) ──────

class ProductDetail {
  final String uid;
  final double mrp;

  const ProductDetail({required this.uid, required this.mrp});

  Map<String, dynamic> toJson() => {
    'detail': uid, // DB / API expects "detail"
    'price': mrp.toStringAsFixed(2), // "5000.00"
  };
}

// ─── Purchase Category: Upgrade ──────────────────────────────────────────────

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

/// Full data for an Upgrade purchase (internal UI model)
class UpgradeData {
  /// Q10 – old product being exchanged
  final OldProductEntry oldProduct;

  /// Q11 – sub-category (Ready Product | Order)
  final UpgradeSubCategory subCategory;

  /// Q12 – order amount (only when subCategory == order)
  final double? orderAmount;

  /// New products added via UID table (only when subCategory == readyProduct)
  final List<ProductDetail> newProducts;

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

// ─── Purchase Category: PYDS ─────────────────────────────────────────────────

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

// ─── Purchase Category Enum ──────────────────────────────────────────────────

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
  final String sales_by;
  final PurchaseCategory purchase_category;

  /// Populated when category is readyProduct or exchange
  final List<ProductDetail> products;

  /// Populated when category is upgrade
  final UpgradeData? upgradeData;

  /// Populated when category is pyds
  final PydsData? pydsData;

  const SalesExecutiveData({
    required this.sales_by,
    required this.purchase_category,
    this.products = const [],
    this.upgradeData,
    this.pydsData,
  });

  double get totalMrp {
    switch (purchase_category) {
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
      'sales_by': sales_by,
      'purchase_category': purchase_category.name.toLowerCase(),
    };

    switch (purchase_category) {
      case PurchaseCategory.readyProduct:
      case PurchaseCategory.exchange:
        base['product_detail'] = products.isEmpty
            ? null
            : products.map((p) => p.toJson()).toList();
        base['product_tot_qty'] = totalUids;
        base['product_tot_amt'] = totalMrp;
        break;

      // Upgrade: flatten UpgradeData into top-level fields
      case PurchaseCategory.upgrade:
        final u = upgradeData;
        if (u != null) {
          base['product_detail'] = u.newProducts.isEmpty
              ? null
              : u.newProducts.map((p) => p.toJson()).toList();
          base['product_tot_qty'] = u.newProducts.length;
          base['product_tot_amt'] = u.newProducts.fold(
            0.0,
            (s, p) => s + p.mrp,
          );
          base['old_product_code'] = u.oldProduct.uid;
          base['old_product_price'] = u.oldProduct.mrp;
          base['purchase_type'] = 'new';
          base['order_price'] = u.orderAmount ?? 0;
          base['upgrade_price'] = u.upgradeAmount;
        }
        break;

      // PYDS: flatten to product_detail / totals
      case PurchaseCategory.pyds:
        final p = pydsData;
        if (p != null) {
          base['product_detail'] = p.products.isEmpty
              ? null
              : p.products
                    .map(
                      (e) => {
                        'detail': e.label,
                        'price': e.mrp.toStringAsFixed(2),
                      },
                    )
                    .toList();
          base['product_tot_qty'] = p.products.length;
          base['product_tot_amt'] = p.totalMrp;
        }
        break;
    }

    return base;
  }
}

// ─── Top-level combined form data ────────────────────────────────────────────

class FeedbackFormData {
  final CustomerFeedbackData customer;
  final SalesExecutiveData sales;

  const FeedbackFormData({required this.customer, required this.sales});

  Map<String, dynamic> toJson() => {...customer.toJson(), ...sales.toJson()};
}
