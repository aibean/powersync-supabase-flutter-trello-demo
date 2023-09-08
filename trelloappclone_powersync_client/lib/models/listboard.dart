import 'package:powersync/sqlite3.dart' as sqlite;
import 'card.dart';

class Listboard {
  Listboard({
    required this.id,
    required this.boardId,
    required this.userId,
    required this.name,
    this.archived,
    this.cards,
  });

  final String id;

  final String boardId;

  final String userId;

  final String name;

  final bool? archived;

  List<Cardlist>? cards;

  factory Listboard.fromRow(sqlite.Row row) {
    return Listboard(
        id: row['id'],
        boardId: row['boardId'],
        userId: row['userId'],
        name: row['name'],
        archived: row['archived'] == 1,
        cards: []
    );
  }
}
