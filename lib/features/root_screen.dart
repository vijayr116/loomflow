// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class HomeScreen extends StatelessWidget {
//   final Widget child;

//   const HomeScreen({super.key, required this.child});

//   int _getIndex(BuildContext context) {
//     final loc = GoRouterState.of(context).uri.toString();

//     if (loc.startsWith('/jobs')) return 1;
//     if (loc.startsWith('/weavers')) return 2;
//     if (loc.startsWith('/settings')) return 3;

//     return 0; // dashboard
//   }

//   @override
//   Widget build(BuildContext context) {
//     final index = _getIndex(context);

//     return Scaffold(
//       appBar: AppBar(
//         actions: [
//           IconButton(
//             onPressed: () {
//               FirebaseAuth.instance.signOut();
//             },
//             icon: Icon(Icons.logout),
//           ),
//         ],
//       ),
//       body: child,

//       bottomNavigationBar: NavigationBar(
//         selectedIndex: index,
//         onDestinationSelected: (i) {
//           switch (i) {
//             case 0:
//               context.go('/dashboard');
//               break;
//             case 1:
//               context.go('/jobs');
//               break;
//             case 2:
//               context.go('/weavers');
//               break;
//             case 3:
//               context.go('/settings');
//               break;
//           }
//         },
//         destinations: const [
//           NavigationDestination(icon: Icon(Icons.home), label: "Home"),
//           NavigationDestination(icon: Icon(Icons.work), label: "Jobs"),
//           NavigationDestination(icon: Icon(Icons.people), label: "Weavers"),
//           NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
//         ],
//       ),
//     );
//   }
// }

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  int _getIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();

    if (loc.startsWith('/jobs')) return 1;
    if (loc.startsWith('/weavers')) return 2;
    if (loc.startsWith('/settings')) return 3;

    return 0;
  }

  String _getTitle(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();

    if (loc.startsWith('/jobs')) return 'Jobs';

    if (loc.startsWith('/weavers')) {
      return 'Weavers';
    }

    if (loc.startsWith('/settings')) {
      return 'Settings';
    }

    return 'Dashboard';
  }

  @override
  Widget build(BuildContext context) {
    final index = _getIndex(context);

    final controller = NotchBottomBarController(index: index);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(context)),

        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: child,

      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: controller,
        color: Colors.white,
        showLabel: true,
        textOverflow: TextOverflow.visible,
        maxLine: 1,
        shadowElevation: 5,
        kBottomRadius: 28.0,
        kIconSize: 24,

        // notchShader: const SweepGradient(
        //   startAngle: 0,
        //   endAngle: pi / 2,
        //   colors: [Colors.red, Colors.green, Colors.orange],
        //   tileMode: TileMode.mirror,
        // ).createShader(Rect.fromCircle(center: Offset.zero, radius: 8.0)),
        notchColor: Colors.white,

        /// restart app if you change removeMargins
        removeMargins: true,
        bottomBarWidth: 500,
        showShadow: false,
        durationInMilliSeconds: 300,

        itemLabelStyle: const TextStyle(fontSize: 10),

        elevation: 1,

        bottomBarItems: const [
          BottomBarItem(
            inActiveItem: Icon(Icons.home_outlined),
            activeItem: Icon(Icons.home),
            itemLabel: 'Home',
          ),

          BottomBarItem(
            inActiveItem: Icon(Icons.work_outline),
            activeItem: Icon(Icons.work),
            itemLabel: 'Jobs',
          ),

          BottomBarItem(
            inActiveItem: Icon(Icons.people_outline),
            activeItem: Icon(Icons.people),
            itemLabel: 'Weavers',
          ),

          BottomBarItem(
            inActiveItem: Icon(Icons.settings_outlined),
            activeItem: Icon(Icons.settings),
            itemLabel: 'Settings',
          ),
        ],

        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/dashboard');
              break;

            case 1:
              context.go('/jobs');
              break;

            case 2:
              context.go('/weavers');
              break;

            case 3:
              context.go('/settings');
              break;
          }
        },
      ),
    );
  }
}
