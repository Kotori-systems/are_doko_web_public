import 'package:flutter_bloc/flutter_bloc.dart';

/// [SimpleBlocObserver]は[BlocObserver]の実装で、
/// Blocの各ライフサイクルイベントを監視します。
/// これにより、開発中にBlocの動作をより深く理解し、
/// デバッグを容易にすることができます。
class SimpleBlocObserver extends BlocObserver {
  // TODO(tanaka): #22 各BlocクラスでaddError()した時のハンドリング
}
