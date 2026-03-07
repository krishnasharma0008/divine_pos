import 'package:flutter/material.dart';

Future<void> showFeedbackSuccessDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => const _FeedbackSuccessDialog(),
  );
}

class _FeedbackSuccessDialog extends StatelessWidget {
  const _FeedbackSuccessDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 48, 32, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Teal circle with checkmark ──────────────────────────────
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7CC8BE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 32),

                // ── Message ─────────────────────────────────────────────────
                const Text(
                  'Thank you for sharing your feedback with us !!!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Bottom indicator bar ─────────────────────────────────────
                Container(
                  width: 120,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBEE4DD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),

          // ── Close button ────────────────────────────────────────────────
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              icon: const Icon(Icons.close, size: 20, color: Color(0xFF9E9E9E)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
