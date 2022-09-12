import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stream_agram/components/profile/profile.dart';
import 'package:stream_agram/components/search/search_page.dart';
import 'package:stream_agram/components/timeline/timeline_page.dart';

import '../../app/app.dart';
import '../app_widgets/app_widgets.dart';
import '../new_post/new_post.dart';

/// HomeScreen of the application.
///
/// Provides Navigation to various pages in the application and maintains their
/// state.
///
/// Default first page is [TimelinePage].
class HomeScreen extends StatefulWidget {
  /// Creates a new [HomeScreen]
  const HomeScreen({Key? key}) : super(key: key);

  /// List of pages available from the home screen.
  static const List<Widget> _homePages = <Widget>[
    _KeepAlivePage(child: TimelinePage()),
    _KeepAlivePage(child: SearchPage()),
    _KeepAlivePage(child: ProfilePage())
  ];

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).appBarTheme.iconTheme!.color!;
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Stream-agram', style: GoogleFonts.grandHotel(fontSize: 32)),
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TapFadeIcon(
              onTap: () => Navigator.of(context).push(NewPostScreen.route),
              icon: Icons.add_circle_outline,
              iconColor: iconColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TapFadeIcon(
              onTap: () async {
                context.removeAndShowSnackbar('Not part of the demo');
              },
              icon: Icons.favorite_outline,
              iconColor: iconColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TapFadeIcon(
              onTap: () =>
                  context.removeAndShowSnackbar('Not part of the demo'),
              icon: Icons.call_made,
              iconColor: iconColor,
            ),
          ),
        ],
      ),
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: HomeScreen._homePages,
      ),
      bottomNavigationBar: _StreamagramBottomNavBar(
        pageController: pageController,
      ),
    );
  }
}

class _StreamagramBottomNavBar extends StatefulWidget {
  const _StreamagramBottomNavBar({
    Key? key,
    required this.pageController,
  }) : super(key: key);

  final PageController pageController;

  @override
  State<_StreamagramBottomNavBar> createState() =>
      _StreamagramBottomNavBarState();
}

class _StreamagramBottomNavBarState extends State<_StreamagramBottomNavBar> {
  void _onNavigationItemTapped(int index) {
    widget.pageController.jumpToPage(index);
  }

  @override
  void initState() {
    super.initState();
    widget.pageController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: (Theme.of(context).brightness == Brightness.dark)
                ? AppColors.ligthGrey.withOpacity(0.5)
                : AppColors.faded.withOpacity(0.5),
            blurRadius: 1,
          ),
        ],
      ),
      child: BottomNavigationBar(
        onTap: _onNavigationItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        iconSize: 28,
        currentIndex: widget.pageController.page?.toInt() ?? 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            activeIcon: Icon(
              Icons.search,
              size: 22,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Person',
          )
        ],
      ),
    );
  }
}

class _KeepAlivePage extends StatefulWidget {
  const _KeepAlivePage({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _KeepAlivePageState createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
