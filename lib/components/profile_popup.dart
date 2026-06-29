import 'package:flutter/material.dart';
import 'package:flashgamer/services/auth_service.dart';

void showProfilePopup({
  required BuildContext context,
  required String nome,
  required int lv,
  required int xp,
  required int saldo,
  required int diasSeguidos,
}) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFDB2777)]),
                boxShadow: [ BoxShadow(color: const Color(0xFF7C3AED).withAlpha(40), blurRadius: 10) ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(3),
                child: CircleAvatar(
                  backgroundColor: Color(0xFF3B1564),
                  child: Icon(Icons.person_rounded, color: Colors.white, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              nome,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Nível $lv',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED)),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE9D5FF).withAlpha(120)),
              ),
              child: Column(
                children: [
                  _buildStatRow('XP Atual', '$xp XP'),
                  const SizedBox(height: 8),
                  _buildStatRow('Saldo', '$saldo Moedas'),
                  const SizedBox(height: 8),
                  _buildStatRow('Ofensiva', '$diasSeguidos dias 🔥'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await AuthService.logout();
                  if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(
                  'LOGOUT / SAIR',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildStatRow(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
      ),
      Text(
        value,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E1B4B)),
      ),
    ],
  );
}
