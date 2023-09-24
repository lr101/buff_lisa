import 'dart:math';
import 'dart:typed_data';

import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../2_ScreenMaps/ClickOnPin/image_widget_logic.dart';
import '../../Files/DTOClasses/group.dart';
import '../../Files/DTOClasses/pin.dart';
import '../../Files/Routes/routing.dart';
import '../../Files/ServerCalls/fetch_pins.dart';
import '../../Files/Widgets/CustomSliverList/custom_sliver_list.dart';

class ImagesSubPage extends StatefulWidget {
  const ImagesSubPage({super.key, required this.group});

  final Group group;

  @override
  ImagesSubPageState createState() => ImagesSubPageState();
}

class ImagesSubPageState extends State<ImagesSubPage> with AutomaticKeepAliveClientMixin<ImagesSubPage> {

  List<Pin> pins = [];

  /// number of rows added by the pagingController added, when paging is activated
  static const _pageSize = 5;

  /// number of images shown in a row
  static const _gridWidth = 3;

  final PagingController<int, Widget> pagingController = PagingController(
      firstPageKey: 0, invisibleItemsThreshold: 3);


  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomSliverList(
      initPagedList: () async => init(await Provider.of<ClusterNotifier>(context).getGroupByGroupId(widget.group.groupId).pins.asyncValue()),
      pagingController: pagingController,
    );
  }

  Future<bool> init(Set<Pin> pinList) async {
    pins = List.from(pinList);
    pins.sort((a,b) => a.creationDate.compareTo(b.creationDate) * -1);
    return true;
  }

  /// Callback function for paging controller, when fetching a new page.
  /// Creates rows based of the current user pin list.
  void _fetchPage(int pageKey, ) async {
    int width = MediaQuery.of(context).size.width ~/ _gridWidth;
    int currentIndex = (_pageSize * _gridWidth) * pageKey;
    int end = (_pageSize * _gridWidth) * (pageKey + 1) < pins.length ? (_pageSize * _gridWidth) * (pageKey + 1) : pins.length - 1;
    end = end < 0 ? 0 : end;
    try {
      await FetchPins.fetchPreviewsOfPins(pins.sublist(currentIndex, end), width);
      if ((_pageSize * _gridWidth) * (pageKey + 1) < pins.length) {
        pagingController.appendPage(
            List.generate(
                _pageSize,
                    (index) =>
                    getImageRow(currentIndex + index * _gridWidth, pins)),
            pageKey + 1);
      } else {
        pagingController.appendLastPage(List.generate(
            _pageSize - (pins.length - currentIndex) ~/ (_pageSize * _gridWidth),
                (index) => getImageRow(currentIndex + index * _gridWidth, pins)));
      }
    } catch(_) {
      pagingController.appendLastPage([]);
    }
  }

  /// Returns a image row using the current index.
  Widget getImageRow(int pageKey, List<Pin> pins) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 1,
          child: pageKey < pins.length ? buildImage(pins[pageKey]) : const SizedBox.shrink(),
        ),
        Expanded(
          flex: 1,
          child: pageKey + 1 < pins.length ? buildImage(pins[pageKey + 1]) : const SizedBox.shrink(),
        ),
        Expanded(
          flex: 1,
          child: pageKey + 2 < pins.length ? buildImage(pins[pageKey + 2]) : const SizedBox.shrink(),
        )
      ],
    );
  }

  /// Builds the actual square image.
  /// Image is touchable and opens a more detailed view.
  Widget buildImage(Pin pin) {
    return LayoutBuilder(
        builder: (context, constraints){
          final size = min(constraints.maxWidth, constraints.maxHeight);
          return GestureDetector(
            onTap: () => handleTabOnImage(pin),
            child: SizedBox(
                height: size,
                width: size,
                child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: FutureBuilder<Uint8List>(
                      future: pin.preview.asyncValue(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Image.memory(snapshot.requireData, fit: BoxFit.cover,);
                        } else {
                          return Container(color: Colors.grey,);
                        }
                      },
                    )
                )
            ),
          );
        }
    );
  }

  /// Opens a pin image in a new page.
  void handleTabOnImage(Pin pin) {
    Routing.to(context,ShowImageWidget(pin: pin));
  }

  @override
  bool get wantKeepAlive => true;

}