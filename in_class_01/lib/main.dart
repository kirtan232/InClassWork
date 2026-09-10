import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());        //Main Bueprint of the app
}

class MyApp extends StatelessWidget {         // Localazation of the home screen
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,  // Line 44 too
        child: _TabsNonScrollableDemo(),
      ),
    );
  }
}

class _TabsNonScrollableDemo extends StatefulWidget {
  @override
  __TabsNonScrollableDemoState createState() => __TabsNonScrollableDemoState();
}

class __TabsNonScrollableDemoState extends State<_TabsNonScrollableDemo>
    with SingleTickerProviderStateMixin, RestorationMixin {
  // Controls which tab is selected and coordinates the tab animations.
  late TabController _tabController;

  final RestorableInt tabIndex = RestorableInt(0);

  @override
  String get restorationId => 'tab_non_scrollable_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(tabIndex, 'tab_index');
    _tabController.index = tabIndex.value;
  }

  @override
  void initState() {
    super.initState();
    // The controller length must match the number of tabs and tab pages.
    _tabController = TabController(
      initialIndex: 0,
      length: 4,
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() {
        tabIndex.value = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    // Release the controller when this screen is removed from the widget tree.
    _tabController.dispose();
    tabIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {          // This is the main build method for the app, which defines the structure of the UI.
    // The names here appear in the TabBar in the same order as the pages below.
    final tabs = ['Tab 1', 'Tab 2', 'Tab 3', 'Tab 4'];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Tabs Demo',
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          // Build one tab label for each name in the tabs list.
          tabs: [
            for (final tab in tabs) Tab(text: tab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [

          // Tab 1: styled text and an AlertDialog.
          Container(
            color: Colors.lightBlue[50],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to ${tabs[0]}!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Hello!'),
                        content: const Text(
                          'This is an AlertDialog.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ),
                    child: const Text('Show Alert'),
                  ),
                ],
              ),
            ),
          ),

          // Tab 2: network image and text input.
          Container(
            color: Colors.green[50],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://imgproxy.nanxiongnandi.com/QPnGD6bn_Vb0yA-_jCc-O95wPpNFhbrL9CqfjOql0IQ/w:1280/aHR0cHM6Ly9pbWcu/bmFueGlvbmduYW5k/aS5jb20vMjAyNjA4/L0NhYmlsYW9DbG93/bnMuanBn.jpg',
                    // Image fro the bing wallpaper page, I chose the fish one.
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Your name',
                        hintText: 'Type name here...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab 3: button that displays a SnackBar message.
          Container(
            color: Colors.amber[50],
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Button pressed in ${tabs[2]} tab!'),
                    ),
                  );
                },
                child: const Text('Click me'),
              ),
            ),
          ),

          // Tab 4: scrollable list of Card and ListTile widgets.
          Container(
            color: Colors.green[50],
            child: ListView(
              children: const [
                Card(
                  elevation: 4,
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: Icon(Icons.flutter_dash),
                    title: Text('Item 1'),
                    subtitle: Text('Details displayed inside a Card'),
                  ),
                ),
                Card(
                  elevation: 4,
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: Icon(Icons.widgets),
                    title: Text('Item 2'),
                    subtitle: Text('Widgets make up the Flutter interface'),
                  ),
                ),
                Card(
                  elevation: 4,
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: Icon(Icons.image),
                    title: Text('Item 3'),
                    subtitle: Text('Images can come from assets or networks'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // BottomAppBar provides a footer area below the tab content.
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'In-Class 01 - My First Tabs App',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}