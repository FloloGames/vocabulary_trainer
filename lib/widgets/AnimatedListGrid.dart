// import 'package:flutter/material.dart';

// class AnimatedListGrid extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final listProvider = Provider.of<ListProvider>(context);

//     return StaggeredGridView.countBuilder(
//       crossAxisCount: 2,
//       itemCount: listProvider.items.length,
//       itemBuilder: (context, index) => _buildListItem(context, index),
//       staggeredTileBuilder: (index) => StaggeredTile.fit(1),
//     );
//   }

//   Widget _buildListItem(BuildContext context, int index) {
//     final listProvider = Provider.of<ListProvider>(context);
//     final item = listProvider.items[index];

//     return Dismissible(
//       key: Key(item.text),
//       onDismissed: (direction) {
//         listProvider.removeItem(index);
//       },
//       background: Container(color: Colors.red),
//       child: Card(
//         elevation: 4,
//         child: ListTile(
//           contentPadding: EdgeInsets.all(8),
//           title: Text(item.text),
//         ),
//       ),
//     );
//   }
// }
