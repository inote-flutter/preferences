import 'dart:async';
import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import 'package:validators/validators.dart';
// import 'package:dynamic_theme/dynamic_theme.dart'; // Just for theme example
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';

///
main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PrefService.init(prefix: 'pref_');

  PrefService.setDefaultValues({'user_description': 'This is my description!'});

  runApp(
    // MyApp()
    EasyDynamicThemeWidget(
      child: MyApp(),
    ),
  );
}

///
class MyApp extends StatelessWidget {
  final String title = 'Preferences Demo';

  ///
  @override
  Widget build(BuildContext context) {
    // return DynamicTheme(
    //     defaultBrightness: Brightness.light,
    //     data: (brightness) =>
    //         ThemeData(brightness: brightness, accentColor: Colors.green),
    //     themedWidgetBuilder: (context, theme) {
    //       return MaterialApp(
    //         title: 'Preferences Demo',
    //         theme: theme,
    //         home: MyHomePage(title: 'Preferences Demo'),
    //       );
    //     });

    return MaterialApp(
        title: title,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: EasyDynamicTheme.of(context).themeMode,
        home: new MyHomePage(
          title: title,
        ));
  }
}

///
class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  ///
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

///
class _MyHomePageState extends State<MyHomePage> {
  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PreferencePage([
        PreferenceTitle('General'),
        DropdownPreference(
          'Start Page',
          'start_page',
          defaultVal: 'Timeline',
          values: ['Posts', 'Timeline', 'Private Messages'],
        ),
        DropdownPreference<int>(
          'Number of items',
          'items_count',
          defaultVal: 2,
          displayValues: ['One', 'Two', 'Three', 'Four'],
          values: [1, 2, 3, 4],
        ),
        PreferenceTitle('Personalization'),
        RadioPreference(
          'Light Theme',
          'light',
          'ui_theme',
          isDefault: true,
          onSelect: () {
            // DynamicTheme.of(context).setBrightness(Brightness.light);
            if (mounted)
              EasyDynamicTheme.of(context)
                  .changeTheme(dynamic: false, dark: false);
          },
        ),
        RadioPreference(
          'Dark Theme',
          'dark',
          'ui_theme',
          onSelect: () {
            // DynamicTheme.of(context).setBrightness(Brightness.dark);
            if (mounted)
              EasyDynamicTheme.of(context)
                  .changeTheme(dynamic: false, dark: true);
          },
        ),
        PreferenceTitle('Messaging'),
        PreferencePageLink(
          'Notifications',
          leading: Icon(Icons.message),
          trailing: Icon(Icons.keyboard_arrow_right),
          page: PreferencePage([
            PreferenceTitle('New Posts'),
            SwitchPreference(
              'New Posts from Friends',
              'notification_newpost_friend',
              defaultVal: true,
            ),
            PreferenceTitle('Private Messages'),
            SwitchPreference(
              'Private Messages from Friends',
              'notification_pm_friend',
              defaultVal: true,
            ),
            SwitchPreference(
              'Private Messages from Strangers',
              'notification_pm_stranger',
              onEnable: () async {
                // Write something in Firestore or send a request
                await Future.delayed(Duration(seconds: 1));

                print('Enabled Notifications for PMs from Strangers!');
              },
              onDisable: () async {
                // Write something in Firestore or send a request
                await Future.delayed(Duration(seconds: 1));

                // No Connection? No Problem! Just throw an Exception with your custom message...
                throw Exception('No Connection');

                // Disabled Notifications for PMs from Strangers!
              },
            ),
          ]),
        ),
        PreferenceTitle('User'),
        TextFieldPreference(
          'Display Name',
          'user_display_name',
        ),
        TextFieldPreference('E-Mail', 'user_email',
            defaultVal: 'email@example.com', validator: (String? str) {
          if (str == null || !isEmail(str)) {
            return "Invalid email";
          }
          return null;
        }),
        PreferenceText(
          PrefService.getString('user_description', ignoreCache: true) ?? '',
          style: TextStyle(color: Colors.grey),
        ),
        PreferenceDialogLink(
          'Edit description',
          dialog: PreferenceDialog(
            [
              TextFieldPreference(
                'Description',
                'user_description',
                padding: const EdgeInsets.only(top: 8.0),
                autofocus: true,
                maxLines: 2,
              )
            ],
            title: 'Edit description',
            cancelText: 'Cancel',
            submitText: 'Save',
            onlySaveOnSubmit: true,
          ),
          onPop: () => setState(() {}),
        ),
        PreferenceTitle('Content'),
        PreferenceDialogLink(
          'Content Types',
          dialog: PreferenceDialog(
            [
              CheckboxPreference('Text', 'content_show_text'),
              CheckboxPreference('Images', 'content_show_image'),
              CheckboxPreference('Music', 'content_show_audio')
            ],
            title: 'Enabled Content Types',
            cancelText: 'Cancel',
            submitText: 'Save',
            onlySaveOnSubmit: true,
          ),
        ),
        PreferenceTitle('More Dialogs'),
        PreferenceDialogLink(
          'Android\'s "ListPreference"',
          dialog: PreferenceDialog(
            [
              RadioPreference(
                  'Select me!', 'select_1', 'android_listpref_selected'),
              RadioPreference(
                  'Hello World!', 'select_2', 'android_listpref_selected'),
              RadioPreference('Test', 'select_3', 'android_listpref_selected'),
            ],
            title: 'Select an option',
            cancelText: 'Cancel',
            submitText: 'Save',
            onlySaveOnSubmit: true,
          ),
        ),
        PreferenceDialogLink(
          'Android\'s "ListPreference" with autosave',
          dialog: PreferenceDialog(
            [
              RadioPreference(
                  'Select me!', 'select_1', 'android_listpref_auto_selected'),
              RadioPreference(
                  'Hello World!', 'select_2', 'android_listpref_auto_selected'),
              RadioPreference(
                  'Test', 'select_3', 'android_listpref_auto_selected'),
            ],
            title: 'Select an option',
            cancelText: 'Close',
          ),
        ),
        PreferenceDialogLink(
          'Android\'s "MultiSelectListPreference"',
          dialog: PreferenceDialog(
            [
              CheckboxPreference('A enabled', 'android_multilistpref_a'),
              CheckboxPreference('B enabled', 'android_multilistpref_b'),
              CheckboxPreference('C enabled', 'android_multilistpref_c'),
            ],
            title: 'Select multiple options',
            cancelText: 'Cancel',
            submitText: 'Save',
            onlySaveOnSubmit: true,
          ),
        ),
        PreferenceHider([
          PreferenceTitle('Experimental'),
          SwitchPreference(
            'Show Operating System',
            'exp_showos',
            desc: 'This option shows the users operating system in his profile',
          )
        ], '!advanced_enabled'), // Use ! to get reversed boolean values
        PreferenceTitle('Advanced'),
        CheckboxPreference(
          'Enable Advanced Features',
          'advanced_enabled',
          onChange: () {
            setState(() {});
          },
          onDisable: () {
            PrefService.setBool('exp_showos', false);
          },
        )
      ]),
    );
  }
}
