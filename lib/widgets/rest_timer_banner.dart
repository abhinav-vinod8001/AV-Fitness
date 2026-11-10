import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/rest_timer_provider.dart';

class RestTimerBanner extends ConsumerWidget {
  const RestTimerBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(restTimerProvider);

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      child: !timerState.isActive
          ? const SizedBox.shrink()
          : Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    const Icon(Icons.timer),
                    const SizedBox(width: 8),
                    Text(
                      'Rest: ${timerState.formattedTime}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => ref.read(restTimerProvider.notifier).subtractTime(30),
                      tooltip: '-30s',
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => ref.read(restTimerProvider.notifier).addTime(30),
                      tooltip: '+30s',
                    ),
                    TextButton(
                      onPressed: () => ref.read(restTimerProvider.notifier).stop(),
                      child: const Text('SKIP'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
