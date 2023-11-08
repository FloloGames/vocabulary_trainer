// import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:vocabulary_trainer/screens/custom_page_transition_animation.dart';
// import 'package:vocabulary_trainer/screens/home_page.dart';

// import 'settings_page.dart';

// class HomePageView extends StatefulWidget {
//   const HomePageView({super.key});

//   @override
//   State<HomePageView> createState() => _HomePageViewState();
// }

// class _HomePageViewState extends State<HomePageView> {
//   /// Controller to handle PageView and also handles initial page
//   final PageController _pageController = PageController(initialPage: 0);

//   /// Controller to handle bottom nav bar and also handles initial page
//   final _notchBottomBarController = NotchBottomBarController(index: 0);

//   final List<Widget> _bottomBarPages = [
//     const HomePage(),
//     const SettingsPage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: PageView(
//         controller: _pageController,
//         physics: const NeverScrollableScrollPhysics(),
//         children: List.generate(
//           _bottomBarPages.length,
//           (index) => _bottomBarPages[index],
//         ),
//       ),
//       extendBody: true,
//       bottomNavigationBar: AnimatedNotchBottomBar(
//         /// Provide NotchBottomBarController
//         notchBottomBarController: _notchBottomBarController,
//         color: Colors.grey,
//         showLabel: false,
//         notchColor: Colors.black87,

//         /// restart app if you change removeMargins
//         removeMargins: false,
//         bottomBarWidth: 500,
//         durationInMilliSeconds: 300,
//         bottomBarItems: [
//           BottomBarItem(
//             inActiveItem: const Icon(
//               Icons.home_filled,
//               color: Colors.white,
//             ),
//             activeItem: IconButton(
//               onPressed: () {},
//               icon: const Icon(
//                 Icons.add,
//                 color: Colors.blue,
//               ),
//             ),
//             itemLabel: 'Home',
//           ),
//           const BottomBarItem(
//             inActiveItem: Icon(
//               Icons.star,
//               color: Colors.white,
//             ),
//             activeItem: Icon(
//               Icons.star,
//               color: Colors.blueAccent,
//             ),
//             itemLabel: 'Settings',
//           ),
//           const BottomBarItem(inActiveItem: Spacer(), activeItem: Spacer()),
//         ],
//         onTap: (index) {
//           /// perform action on tab change and to update pages you can update pages without pages
//           print('current selected index $index');
//           // _pageController.jumpToPage(index);
//           _pageController.animateToPage(
//             index,
//             duration: const Duration(milliseconds: 225),
//             curve: Curves.easeIn,
//           );
//         },
//       ),
//     );
//   }

//   Widget _bottomNavigationBar(BuildContext context) {
//     return AnimatedNotchBottomBar(
//       notchBottomBarController: _notchBottomBarController,
//       onTap: (value) {},
//       bottomBarItems: [
//         BottomBarItem(
//           inActiveItem: const Icon(Icons.no_accounts),
//           activeItem: IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.home),
//           ),
//         ),
//         BottomBarItem(
//           inActiveItem: const Icon(Icons.no_accounts),
//           activeItem: IconButton(
//             onPressed: () {
//               Navigator.of(context).push(
//                 CustomPageTransitionAnimation(
//                   const SettingsPage(),
//                   const Alignment(.9, -0.9),
//                 ),
//               );
//             },
//             icon: const Icon(Icons.settings),
//           ),
//         ),
//       ],
//     );
//     // return BottomAppBar(
//     //   shape: const CircularNotchedRectangle(),
//     //   notchMargin: 6,
//     //   child: Row(
//     //     mainAxisAlignment: MainAxisAlignment.spaceAround,
//     //     children: [
//     //       IconButton(
//     //         onPressed: () {},
//     //         icon: const Icon(Icons.home),
//     //       ),
//     //       IconButton(
//     //         onPressed: () {
//     //           Navigator.of(context).push(
//     //             CustomPageTransitionAnimation(
//     //               const SettingsPage(),
//     //               const Alignment(.9, -0.9),
//     //             ),
//     //           );
//     //         },
//     //         icon: const Icon(Icons.settings),
//     //       ),
//     //     ],
//     //   ),
//     // );
//   }
// }

// class Page1 extends StatelessWidget {
//   const Page1({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         color: Colors.yellow, child: const Center(child: Text('Page 1')));
//   }
// }

// class Page2 extends StatelessWidget {
//   const Page2({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         color: Colors.green, child: const Center(child: Text('Page 2')));
//   }
// }
