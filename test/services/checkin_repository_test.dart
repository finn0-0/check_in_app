import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_check_in_app/services/checkin_repository.dart';

void main() {
  late FakeFirebaseFirestore fs;
  late CheckInRepository repo;

  setUp(() {
    fs = FakeFirebaseFirestore();
    repo = CheckInRepository(firestore: fs);
  });

  group('CheckInRepository', () {
    test('writeCheckIn 同日幂等', () async {
      final today = DateTime(2026, 8, 22);
      await repo.writeCheckIn(uid: 'u1', habitId: 'h1', date: today);
      await repo.writeCheckIn(uid: 'u1', habitId: 'h1', date: today, note: 'again');
      final list = await repo.watchCheckIns('u1', 'h1').first;
      expect(list.length, 1);
      expect(list.first.id, '2026-08-22');
      expect(list.first.note, 'again');
    });

    test('不同日 -> 两条文档', () async {
      await repo.writeCheckIn(uid: 'u1', habitId: 'h1', date: DateTime(2026, 8, 22));
      await repo.writeCheckIn(uid: 'u1', habitId: 'h1', date: DateTime(2026, 8, 21));
      await repo.writeCheckIn(uid: 'u1', habitId: 'h1', date: DateTime(2026, 8, 20));
      final list = await repo.watchCheckIns('u1', 'h1').first;
      expect(list.length, 3);
      expect(list.first.id, '2026-08-22'); // 降序
      expect(list.last.id, '2026-08-20');
    });

    test('deleteCheckIn 仅移除对应日期', () async {
      await repo.writeCheckIn(uid: 'u1', habitId: 'h1', date: DateTime(2026, 8, 22));
      await repo.writeCheckIn(uid: 'u1', habitId: 'h1', date: DateTime(2026, 8, 21));
      await repo.deleteCheckIn(uid: 'u1', habitId: 'h1', date: DateTime(2026, 8, 22));
      final list = await repo.watchCheckIns('u1', 'h1').first;
      expect(list.length, 1);
      expect(list.first.id, '2026-08-21');
    });
  });
}