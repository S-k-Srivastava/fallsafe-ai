import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Large start/stop control button
class ControlButton extends StatelessWidget {
  final bool isRunning;
  final bool isEnabled;
  final VoidCallback onPressed;

  const ControlButton({
    super.key,
    required this.isRunning,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isRunning ? AppPalette.danger : AppPalette.safe,
          disabledBackgroundColor: Theme.of(context).disabledColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                key: ValueKey(isRunning),
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              isRunning ? 'Stop Detection' : 'Start Detection',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
