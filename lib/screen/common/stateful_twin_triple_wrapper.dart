import 'package:are_doko_web/screen/common/stateful_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// TODO(tanaka): #19 1Screenに対して複数のCubitを紐づけるのは厳しそう。（Cubitの数が固定のWrapperならできた）
class StatefulTwinTripleWrapper<
    TCubit1 extends Cubit<TState1>,
    TState1,
    TCubit2 extends Cubit<TState2>,
    TState2,
    TCubit3 extends Cubit<TState3>,
    TState3> extends StatelessWidget {
  final Widget Function(BuildContext) childBuilder;
  final List<BlocProvider> providers;
  final List<BlocListener> listeners;
  final void Function(BuildContext) onInit;
  final void Function()? onDispose;

  const StatefulTwinTripleWrapper({
    Key? key,
    required this.providers,
    required this.listeners,
    required this.childBuilder,
    required this.onInit,
    this.onDispose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: providers,
      child: BlocBuilder<TCubit1, TState1>(
        builder: (context, state) {
          return BlocBuilder<TCubit2, TState2>(
            builder: (context, state) {
              return BlocBuilder<TCubit3, TState3>(
                builder: (context, state) {
                  return StatefulWrapper(
                    onInit: onInit,
                    buildContext: context,
                    onDispose: onDispose,
                    child: MultiBlocListener(
                      listeners: listeners,
                      child: childBuilder(context),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
