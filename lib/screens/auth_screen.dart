// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';
// import '../styles/app_theme.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final AuthService _authService = AuthService();
//   bool _isLoading = false;

//   Future<void> _handleGoogleSignIn() async {
//     setState(() => _isLoading = true);
//     await _authService.signInWithGoogle();
//     // Auth state change will handle navigation via AuthGate
//     if (mounted) setState(() => _isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Row(
//         children: [
//           // Left Side - Branding / Image
//           Expanded(
//             flex: 3,
//             child: Container(
//               color: AppTheme.primary,
//               child: Stack(
//                 children: [
//                   Positioned.fill(
//                     child: Opacity(
//                       opacity: 0.1,
//                       child: Icon(Icons.school, size: 400, color: Colors.white),
//                     ),
//                   ),
//                   Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(Icons.school, size: 80, color: Colors.white),
//                         const SizedBox(height: 24),
//                         Text(
//                           'SAMS',
//                           style: Theme.of(context).textTheme.displayLarge
//                               ?.copyWith(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'Smart Approval Management System',
//                           style: Theme.of(context).textTheme.headlineSmall
//                               ?.copyWith(color: Colors.white70),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Right Side - Login Form
//           Expanded(
//             flex: 2,
//             child: Center(
//               child: Container(
//                 constraints: const BoxConstraints(maxWidth: 400),
//                 padding: const EdgeInsets.all(48),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Text(
//                       'Welcome Back',
//                       style: Theme.of(context).textTheme.headlineMedium
//                           ?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: AppTheme.textDark,
//                           ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Please sign in to continue',
//                       style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                         color: AppTheme.textLight,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 48),

//                     // Google Sign In Button
//                     ElevatedButton(
//                       onPressed: _isLoading ? null : _handleGoogleSignIn,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         foregroundColor: Colors.black87,
//                         elevation: 2,
//                         padding: const EdgeInsets.symmetric(vertical: 20),
//                         side: BorderSide(color: Colors.grey.shade300),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: _isLoading
//                           ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(strokeWidth: 2),
//                             )
//                           : const Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.g_mobiledata,
//                                   size: 28,
//                                 ), // Placeholder for Google Icon
//                                 SizedBox(width: 12),
//                                 Text(
//                                   'Sign in with Google',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                     ),

//                     const SizedBox(height: 32),
//                     Text(
//                       'By continuing, you agree to our Terms of Service and Privacy Policy.',
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: AppTheme.textLight,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }