import 'package:flutter/material.dart';

class RouteTile extends StatelessWidget {
  final String name;
  final String area;
  final double rating;
  final VoidCallback onTap;

  const RouteTile({
    super.key,
    required this.name,
    required this.area,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.route),
        title: Text(name),
        subtitle: Text(area),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            Text(rating.toString()),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
