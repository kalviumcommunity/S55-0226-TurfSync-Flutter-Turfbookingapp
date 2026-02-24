import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../models/practice_session_model.dart';

/// Displays a practice session as a card with join/leave functionality.
class SessionCard extends StatelessWidget {
  final PracticeSessionModel session;
  final String currentUserId;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;
  final VoidCallback? onDelete;
  final bool isCoachView;

  const SessionCard({
    super.key,
    required this.session,
    required this.currentUserId,
    this.onTap,
    this.onJoin,
    this.onLeave,
    this.onDelete,
    this.isCoachView = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasJoined = session.hasPlayerJoined(currentUserId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ───
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: AppColors.accentOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'by ${session.coachName}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  if (isCoachView && onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error),
                      onPressed: onDelete,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // ─── Details ───
              if (session.description.isNotEmpty) ...[
                Text(
                  session.description,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],

              Row(
                children: [
                  Icon(Icons.sports_soccer,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(session.turfName,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 16),
                  Icon(Icons.calendar_today,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(AppDateUtils.formatShortDate(session.date),
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${session.startTime} – ${session.endTime}',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ─── Players & Action ───
              Row(
                children: [
                  // Player count
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: session.isFull
                          ? AppColors.error.withOpacity(0.1)
                          : AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${session.currentPlayerCount}/${session.maxPlayers} Players',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: session.isFull
                            ? AppColors.error
                            : AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Join / Leave button
                  if (!isCoachView) ...[
                    if (hasJoined)
                      TextButton.icon(
                        onPressed: onLeave,
                        icon: const Icon(Icons.exit_to_app, size: 18),
                        label: const Text('Leave'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                      )
                    else if (!session.isFull)
                      ElevatedButton.icon(
                        onPressed: onJoin,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Join'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                        ),
                      )
                    else
                      const Text(
                        'Full',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
