import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final VoidCallback? onEdit;
  final double radius;

  const AvatarWidget({
    super.key,
    required this.avatarUrl,
    required this.name,
    this.onEdit,
    this.radius = 40,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? 'U'
        : name
            .trim()
            .split(' ')
            .where((e) => e.isNotEmpty)
            .take(2)
            .map((e) => e[0].toUpperCase())
            .join();
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
              ? NetworkImage(avatarUrl!)
              : null,
          child: (avatarUrl == null || avatarUrl!.isEmpty)
              ? Text(initials, style: const TextStyle(fontWeight: FontWeight.bold))
              : null,
        ),
        if (onEdit != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: InkWell(
              onTap: onEdit,
              child: const CircleAvatar(
                radius: 14,
                child: Icon(Icons.edit, size: 14),
              ),
            ),
          ),
      ],
    );
  }
}
