import 'solitaire_detail_model.dart';
import 'solitaire_price_model.dart';

class JewelleryState {
  final SolitaireDetail? detail;
  final SolitairePrice? price;

  const JewelleryState({this.detail, this.price});

  JewelleryState copyWith({SolitaireDetail? detail, SolitairePrice? price}) {
    return JewelleryState(
      detail: detail ?? this.detail,
      price: price ?? this.price,
    );
  }
}
