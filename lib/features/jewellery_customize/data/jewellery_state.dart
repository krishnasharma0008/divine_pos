import '../data/jewellery_detail_model.dart';
import '../data/jewellery_price_model.dart';

class JewelleryState {
  final JewelleryDetail? detail;
  final JewelleryPrice? price;

  const JewelleryState({this.detail, this.price});

  JewelleryState copyWith({JewelleryDetail? detail, JewelleryPrice? price}) {
    return JewelleryState(
      detail: detail ?? this.detail,
      price: price ?? this.price,
    );
  }
}
