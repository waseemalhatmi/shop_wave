import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../data/datasources/notifications_remote_data_source.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import 'dart:async';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final remoteDataSource = NotificationsRemoteDataSourceImpl(supabase);
  return NotificationsRepositoryImpl(remoteDataSource);
});

class UserNotifications extends AsyncNotifier<List<NotificationEntity>> {
  @override
  Future<List<NotificationEntity>> build() async {
    final repository = ref.watch(notificationsRepositoryProvider);
    final result = await repository.getNotifications();
    return result.fold<List<NotificationEntity>>(
      (failure) => throw Exception(failure.message),
      (notifications) => notifications,
    );
  }

  Future<void> markAsRead(String id) async {
    final repository = ref.read(notificationsRepositoryProvider);
    await repository.markAsRead(id);
    
    // Update local state optimistically
    final currentList = state.value ?? [];
    state = AsyncValue.data(
      currentList.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList(),
    );
  }

  Future<void> markAllAsRead() async {
    final repository = ref.read(notificationsRepositoryProvider);
    await repository.markAllAsRead();

    // Update local state optimistically
    final currentList = state.value ?? [];
    state = AsyncValue.data(
      currentList.map((n) => n.copyWith(isRead: true)).toList(),
    );
  }
}

final userNotificationsProvider = AsyncNotifierProvider<UserNotifications, List<NotificationEntity>>(() {
  return UserNotifications();
});
