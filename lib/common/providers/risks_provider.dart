import 'package:crcrme_banque_stages/screens/ref_sst/common/Risk.dart';

import 'package:crcrme_banque_stages/crcrme_enhanced_containers/lib/list_provided.dart';

class RisksProvider extends ListProvided<Risk> {
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
  Risk deserializeItem(data) => Risk.fromSerialized(data);
}
