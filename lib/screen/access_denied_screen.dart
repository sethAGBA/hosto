import 'package:flutter/material.dart';

class AccessDeniedScreen extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onRequestAccess;

  const AccessDeniedScreen({super.key, required this.title, this.onBack, this.onRequestAccess});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, color: Color(0xFFEF4444), size: 48),
            const SizedBox(height: 12),
            Text(
              'Acces refuse',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Vous n'avez pas les droits pour acceder a $title.",
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (onBack != null)
              ElevatedButton(
                onPressed: onBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5A4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Retour tableau de bord'),
              ),
            if (onRequestAccess != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onRequestAccess,
                child: const Text('Demander acces', style: TextStyle(color: Color(0xFF0EA5A4))),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
