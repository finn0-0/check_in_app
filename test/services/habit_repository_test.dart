import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_check_in_app/services/habit_repository.dart';

void main() {
  late FakeFirebaseFirestore fs;
  late HabitRepository repo;

  setUp(() {
    fs = FakeFirebaseFirestore();
    repo = HabitRepository(firestore: fs);
  });

  group('HabitRepository', () {
    test('create 返回 doc id 且可被 watchHabits 看到', () async {
      final id = await repo.create(
        uid: 'u1',
        name: '早起',
        iconKey: 'wb_sunny',
        colorValue: 0xFF66BB6A,
      );
      expect(id, isNotEmpty);

      final list = await repo.watchHabits('u1').first;
      expect(list.length, 1);
      expect(list.first.id, id);
      expect(list.first.name, '早起');
      expect(list.first.archived, false);
    });

    test('archive 通过 watchActiveHabits 隐藏', () async {
      final id = await repo.create(
        uid: 'u1',
        name: '跑步',
        iconKey: 'directions_run',
        colorValue: 0xFFEF5350,
      );

      final activeBefore = await repo.watchActiveHabits('u1').first;
      expect(activeBefore.length, 1);

      await repo.setArchived('u1', id, true);

      final activeAfter = await repo.watchActiveHabits('u1').first;
      expect(activeAfter, isEmpty);

      final archivedAfter = await repo.watchArchivedHabits('u1').first;
      expect(archivedAfter.length, 1);
      expect(archivedAfter.first.archived, true);
    });

    test('create 多次递增 sortOrder', () async {
      await repo.create(uid: 'u1', name: 'A', iconKey: 'k', colorValue: 0xFF000000);
      await repo.create(uid: 'u1', name: 'B', iconKey: 'k', colorValue: 0xFF000000);
      await repo.create(uid: 'u1', name: 'C', iconKey: 'k', colorValue: 0xFF000000);

      final list = await repo.watchHabits('u1').first;
      expect(list.map((h) => h.sortOrder).toList(), [0, 1, 2]);
      expect(list.map((h) => h.name).toList(), ['A', 'B', 'C']);
    });

    test('delete 永久移除', () async {
      final id = await repo.create(
        uid: 'u1',
        name: 'X',
        iconKey: 'k',
        colorValue: 0xFF000000,
      );
      await repo.delete('u1', id);
      final after = await repo.watchHabits('u1').first;
      expect(after, isEmpty);
      expect(await repo.getById('u1', id), isNull);
    });
  });
}