# Flutter App: *Stick-It*

## Description

Introducing our new photo-sharing app, **Stick-It**! **Stick-It** is a social media platform that is similar to Instagram, but with a unique twist - all images uploaded on **Stick-It** are tagged with the location where they were taken and assigned to a group.

**Stick-It** makes it easy for you to organize and share your photos by assigning them to groups. Your fellow group members profit from your discoveries and can find them there themselves. **Stick-It** is perfect for sharing unique places. A very popular content are images and locations of stickers. The app is perfect for keeping track of all the locations and taking images is easy and very fast.

One of the standout features of **Stick-It** is its interactive map view. When you open the app, you'll see a map with pins that represent the different groups you've created. Tapping on a pin will reveal the photo taken at that exact location and was assigned to the group, allowing you to explore different places and memories.

**Stick-It** also allows you to create and delete groups, making it easy to manage your content. Additionally, you can view all your photos and groups in a feed like overview. The shown groups can always be activated or deactivated by a single button press at the top of the screen.

Whether you're a casual photographer or a seasoned traveler, **Stick-It** is the perfect app to capture and share your experiences. So what are you waiting for? Download **Stick-It** today on [Android](https://play.google.com/store/apps/details?id=com.TheGermanApps.buff_lisa) and iOS and start sharing your world!

## How does it work?

### Flutter

The app is programmed in the language dart using the framework flutter. Flutter is an open-source UI software development kit created by Google. It is used to develop cross-platform applications for Android, iOS, Linux, macOS, Windows, Google Fuchsia, and the web from a single codebase. [source](https://en.wikipedia.org/wiki/Flutter_(software))

Therefore, the App can be easily compiled to Android, iOS and Web. In addition to the compilable code base of the widget, android and iOS require to add multiple actions like permission, app image and native ads to be added in their respected native build structure. Everything related to android can be found in the [android folder](/android) and to iOS in the [iOS folder](/ios)

### Structure

How the different pages interact with each can be found [here]().

### Server

Information is mostly fetched from the server when needed. The server uses the REST structure to make information available to clients. All used routes can be accessed via static methods from the files in the [ServerCalls file](/lib/Files/ServerCalls).

### Data

#### Where is the data stored? 

Global data can be accessed via Providers or the [global file](/lib/Files/Other/global.dart). The global file contains static data and a LocalData class instance. This is class is initialized on startup and contains data saved offline to rebuild the app the same way it was before closing it. The data from the global class can be directly access from everywhere.

Additionally, there are three main globally accessible providers:

1. **ClusterNotifier**: Holds the information of the groups and provides methods to make operations possible
2. **ThemeNotifier**: Holds the dark and light theme information and which one is currently active
3. **UserNotifier**: Holds information of different users
4. **DateNotifier**: Holds information on last date the feed was refreshed

These classes extend the ChangeNotifier class and are created and attached in the main method. The ChangeNotifier class makes it possible to access the class via providers and listen to changes in the data. Changes trigger a rebuild of a part of a widget (different from setState, which rebuilds the whole class). 

#### [Groups](/lib/Files/DTOClasses/group.dart)

A group instance has multiple attributes and can be identified through the unique groupId. To initialize a group there must be at least a groupId, name, visibility and a invite url if the visibility is not zero. The groups also contains all pins that can be loaded from the server. Groups are saved offline when created or edited, so an offline use is possible, when the server is not available.

#### [Pins](/lib/Files/DTOClasses/pin.dart)

A pin instance has multiple attributes and can be identified through the unique id. To initialize a pin the id, latitude, longitude, creation date, username and group must be given. The Image can be loaded from the server. Pins can also be saved offline. This is only used during offline use to save it, until an upload is possible.

## Install

### Installation for Android and iOS

1. Follow the flutter installation [here](https://docs.flutter.dev/get-started/install)
2. Clone this project: ```git clone git@github.com:lr101/buff_lisa.git```
3. Go into file: ```cd buff_lisa```
4. Add an .env file here: 
```
HOST=stick-it.hopto.org
MAPS_API_KEY=[api key from stadia maps]
```
5. Run ```flutter pub get```
6. Now running on a simulator should be possible

### Setup for Google Play Store:

Look [here](https://docs.flutter.dev/deployment/android) for more information

### Setup for iOS Store:

Look [here](https://docs.flutter.dev/deployment/ios) for more information

## Other

### Packages used

1. flutter_map_marker_cluster
2. flutter_map_location_marker:
3. flutter_map:
4. latlong2:
5. geolocator:
6. http:
7. crypt:
8. crypto:
9. flutter_secure_storage:
10. camera:
11. image_picker:
12. image_cropper:
13. path_provider:
14. path:
15. shimmer:
16. flutter_login:
17. shared_preferences:
18. webview_flutter:
19. image:
20. flutter_dotenv:
21. provider:
22. url_launcher:
23. infinite_scroll_pagination:
24. internet_connection_checker:
25. mutex:
26. hive:
27. flutter_launcher_icons:
28. hive_flutter:
29. google_mobile_ads:
30. fluttertoast:
31. configurable_expansion_tile_null_safety:
32. geocoding:
33. permission_handler:
34. settings_ui:
35. flutter_native_splash:

### Set new icon
1. change asset path in pubspec.yaml
2. run: ```flutter packages pub run flutter_launcher_icons:main```

### Build android apk
- run: ```flutter build apk```

### Build app bundle release (android)

- run: ```flutter build appbundle```

