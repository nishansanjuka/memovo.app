import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mobile/core/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the current user safely
    final user = ClerkAuth.userOf(context);
    final authState = ClerkAuth.of(context);

    // Handle null user case
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Default avatar if none provided (could use initials)
    final userImage = user.imageUrl;
    final userName = user.firstName ?? user.username ?? "User";
    final userEmail =
        user.emailAddresses?.map((email) => email.emailAddress).join(", ") ??
        "";

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Memovo",
          style: TextStyle(color: AppTheme.textColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.textColor),
            onPressed: () async {
              await authState.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    backgroundImage: userImage != null
                        ? NetworkImage(userImage)
                        : null,
                    child: userImage == null
                        ? Text(
                            userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              fontSize: 32,
                              color: AppTheme.primaryColor,
                            ),
                          )
                        : null,
                  ),
                  const Gap(16),
                  Text(
                    "Hello, $userName!",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  if (userEmail.isNotEmpty) ...[
                    const Gap(8),
                    Text(
                      userEmail,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.subTextColor,
                      ),
                    ),
                  ],
                  const Gap(24),
                  // Use Clerk's native user button for profile management
                  const ClerkUserButton(),
                ],
              ),
            ),
            const Gap(32),
            // Placeholder for app content
            const Text("Your memories will appear here."),
          ],
        ),
      ),
    );
  }
}
