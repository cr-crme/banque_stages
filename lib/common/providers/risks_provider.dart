import 'package:crcrme_banque_stages/screens/ref_sst/common/card_sst.dart';

import 'package:crcrme_banque_stages/crcrme_enhanced_containers/lib/list_provided.dart';

class RisksProvider extends ListProvided<CardSST> {
  /// This examples shows how ot implement a [ListProvided] of some [ItemSerializable].
  /// ([MyRandomItem] in the current case).
  ///

  /// This is a necessary override to use [ListProvided] as the enhanced provider
  /// need to know how to deserialize the [ItemSerializable].
  ///
  /// Usually, the item knows how deserialize itself, so it is simply a matter
  /// of calling that constructor.
  ///
  @override
  CardSST deserializeItem(data) {
    return CardSST.fromSerialized(data);
  }
}
