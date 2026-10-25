import 'package:easy_transit/providers/bookmarks.dart';
import 'package:easy_transit/screens/plan.dart';
import 'package:easy_transit/screens/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookmarkRow extends ConsumerWidget {
  final Orientation orientation;

  const BookmarkRow({super.key, this.orientation = Orientation.portrait});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icons = <Widget>[];
    final bookmarks = ref.watch(bookmarkProvider);
    for (final bookmark in bookmarks) {
      icons.add(
        TextButton(
          key: ValueKey(bookmark.hashCode),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlanRoutePage(to: bookmark.location, bookmark: bookmark),
              ),
            );
          },
          child: Text(
            bookmark.emoji,
            semanticsLabel: bookmark.name,
            style: TextStyle(fontSize: 40.0, color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
      );
    }

    icons.add(Spacer());
    icons.add(IconButton(
      icon: Icon(Icons.search),
      iconSize: 40.0,
      color: Colors.black,
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchPage()));
      },
    ));

    return Flex(
      direction: orientation == Orientation.portrait ? Axis.horizontal : Axis.vertical,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: icons,
    );
  }
}
