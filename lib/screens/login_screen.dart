import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoggingIn = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Center(
        child: Container(
          width: isMobile ? size.width * 0.95 : 1100,
          height: isMobile ? size.height * 0.95 : 600,
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFF333333)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 4,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFBF953F), Color(0xFFFCF6BA), Color(0xFFB38728), Color(0xFFFBF5B7), Color(0xFFAA771C)],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  if (!isMobile)
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: const Color(0xFF0A0A0A),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Opacity(
                              opacity: 0.1,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [Color(0xFFD4AF37), Colors.transparent],
                                    radius: 0.7,
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.02),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/logo-booking.png',
                                      width: 150,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37), size: 70),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                const Text(
                                  'PLUSH NAIL BAR',
                                  style: TextStyle(
                                    color: Color(0xFFD4AF37),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Turn Management System',
                                  style: TextStyle(
                                    color: Colors.white24,
                                    fontSize: 10,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 24.0 : 48.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '1. Select Salon Location',
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: provider.salons.map((salon) {
                              final isSelected = provider.currentSalon?.id == salon.id;
                              return ChoiceChip(
                                label: Text(salon.name),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) provider.setCurrentSalon(salon);
                                },
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white54,
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                selectedColor: const Color(0xFFD4AF37),
                                backgroundColor: Colors.white.withOpacity(0.05),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                showCheckmark: false,
                                side: BorderSide(
                                  color: isSelected ? const Color(0xFFD4AF37) : Colors.white10,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 32),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '2. Staff Login',
                                              style: TextStyle(
                                                color: Color(0xFFD4AF37),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 2,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            TextField(
                                              controller: _usernameController,
                                              style: const TextStyle(color: Colors.white, fontSize: 13),
                                              decoration: _inputDecoration('Username'),
                                            ),
                                            const SizedBox(height: 12),
                                            TextField(
                                              controller: _passwordController,
                                              obscureText: true,
                                              style: const TextStyle(color: Colors.white, fontSize: 13),
                                              decoration: _inputDecoration('Password'),
                                            ),
                                            if (provider.loginError != null)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  provider.loginError!,
                                                  style: const TextStyle(color: Colors.redAccent, fontSize: 10),
                                                ),
                                              ),
                                            const SizedBox(height: 24),
                                            SizedBox(
                                              width: double.infinity,
                                              height: 50,
                                              child: ElevatedButton(
                                                onPressed: _isLoggingIn ? null : _handleLogin,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFFD4AF37),
                                                  foregroundColor: Colors.black,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                  elevation: 10,
                                                ),
                                                child: _isLoggingIn
                                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                                                    : const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!isMobile) const SizedBox(width: 32),
                                      if (!isMobile)
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                '3. General Access',
                                                style: TextStyle(
                                                  color: Colors.white24,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 2,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              SizedBox(
                                                width: double.infinity,
                                                height: 50,
                                                child: OutlinedButton(
                                                  onPressed: () => provider.loginAsGuest(),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: Colors.white70,
                                                    side: const BorderSide(color: Colors.white10),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                  ),
                                                  child: const Text('TURN TABLE VIEW', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (isMobile) const SizedBox(height: 32),
                                  if (isMobile)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '3. General Access',
                                          style: TextStyle(
                                            color: Colors.white24,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: OutlinedButton(
                                            onPressed: () => provider.loginAsGuest(),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.white70,
                                              side: const BorderSide(color: Colors.white10),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            child: const Text('TURN TABLE VIEW', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              'AUTHORIZED PERSONNEL ONLY',
                              style: TextStyle(
                                color: Colors.white10,
                                fontSize: 9,
                                letterSpacing: 3,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1)),
    );
  }

  Future<void> _handleLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) return;
    setState(() => _isLoggingIn = true);
    await Provider.of<AppProvider>(context, listen: false).login(
      _usernameController.text,
      _passwordController.text,
    );
    if (mounted) setState(() => _isLoggingIn = false);
  }
}
