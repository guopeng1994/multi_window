import 'package:flutter/material.dart';
import 'package:multi_window/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var _key = await WindowController.lastWindowKey();
  runApp(MyApp(key: ValueKey(_key)));
}

class MyApp extends StatelessWidget {
  const MyApp({ValueKey key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: HomeScreen(windowKey: this.key),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final ValueKey windowKey;

  const HomeScreen({Key key, @required this.windowKey}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _value = 0;
  List<String> _keys = [];

  @override
  void initState() {
    print("Key: ${widget.windowKey.value}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _current = widget.windowKey.value;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.web),
          onPressed: () {
            WindowController.openWebView(
                'apple_website', "https://www.apple.com",
                size: Size(1024, 1024));
          },
        ),
        title: Text('Home Screen ($_current)'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.timer),
            onPressed: () {
              WindowController.windowCount().then(
                (count) => print('Windows: $count'),
              );
              WindowController.keyIndex(_current).then(
                (index) => print('Index: $index'),
              );
              WindowController.getWindowStats(_current).then(
                (stats) => print('Stats: $stats'),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.desktop_windows),
            onPressed: () async {
              final _offset = await WindowController.getWindowOffset(_current);
              final _size = await WindowController.getWindowSize(_current);
              print("Offset: $_offset, Size: $_size");
              await WindowController.createWindow(
                WindowController.generateKey(),
                offset: (_offset.translate(_offset.dx + 2, _offset.dy - 2)),
                size: _size,
              );
              final _key = await WindowController.lastWindowKey();
              if (mounted)
                setState(() {
                  _keys.add(_key);
                });
            },
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => WindowController.closeWindow(_current),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, dimens) => GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: (dimens.maxWidth / 200).round(),
            childAspectRatio: 9 / 16,
          ),
          itemCount: _keys.length,
          itemBuilder: (context, index) {
            final _item = _keys[index];
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 10,
                child: Column(
                  children: <Widget>[
                    ListTile(title: Text(_item)),
                    Row(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () async {
                                final _size =
                                    await WindowController.getWindowSize(_item);
                                WindowController.resizeWindow(_item,
                                    Size(_size.width + 20, _size.height + 20));
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () async {
                                final _size =
                                    await WindowController.getWindowSize(_item);
                                WindowController.resizeWindow(_item,
                                    Size(_size.width - 20, _size.height - 20));
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline),
                              onPressed: () async {
                                WindowController.closeWindow(_item);
                              },
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.arrow_upward),
                              onPressed: () async {
                                final _offset =
                                    await WindowController.getWindowOffset(
                                        _item);
                                WindowController.moveWindow(
                                    _item, Offset(_offset.dx, _offset.dy + 20));
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_downward),
                              onPressed: () async {
                                final _offset =
                                    await WindowController.getWindowOffset(
                                        _item);
                                WindowController.moveWindow(
                                    _item, Offset(_offset.dx, _offset.dy - 20));
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () async {
                                final _offset =
                                    await WindowController.getWindowOffset(
                                        _item);
                                WindowController.moveWindow(
                                    _item, Offset(_offset.dx - 20, _offset.dy));
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_forward),
                              onPressed: () async {
                                final _offset =
                                    await WindowController.getWindowOffset(
                                        _item);
                                WindowController.moveWindow(
                                    _item, Offset(_offset.dx + 20, _offset.dy));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Center(child: Text(_value.toString())),
        onPressed: () async {
          if (mounted)
            setState(() {
              _value++;
            });
        },
      ),
    );
  }
}
