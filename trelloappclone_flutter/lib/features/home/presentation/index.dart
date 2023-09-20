import 'dart:async';

import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:trelloappclone_flutter/main.dart';
import 'package:trelloappclone_powersync_client/trelloappclone_powersync_client.dart';
import 'package:trelloappclone_flutter/features/board/domain/board_arguments.dart';
import 'package:trelloappclone_flutter/features/board/presentation/index.dart';

import '../../../utils/color.dart';
import '../../../utils/service.dart';
import '../../../utils/widgets.dart';
import '../../drawer/presentation/index.dart';
import 'custom_floating_action.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with Service {
  late SyncStatus _connectionState;
  StreamSubscription<SyncStatus>? _syncStatusSubscription;

  @override
  void initState() {
    super.initState();

    _connectionState = dataClient.getCurrentSyncStatus();
    _syncStatusSubscription = dataClient.getStatusStream().listen((event) {
      setState(() {
        _connectionState = dataClient.getCurrentSyncStatus();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _syncStatusSubscription?.cancel();
  }


  @override
  Widget build(BuildContext context) {
    const connectedIcon = IconButton(
      icon: Icon(Icons.wifi),
      tooltip: 'Connected',
      onPressed: null,
    );
    const disconnectedIcon = IconButton(
      icon: Icon(Icons.wifi_off),
      tooltip: 'Not connected',
      onPressed: null,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Boards"),
        actions: [
          IconButton(
              onPressed: () {
                search(context);
              },
              icon: const Icon(Icons.search)),
          _connectionState.connected ? connectedIcon : disconnectedIcon
        ],
      ),
      drawer: const CustomDrawer(),
      body: StreamBuilder(
          stream: getWorkspacesStream(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Workspace>> snapshot) {
            if (snapshot.hasData) {
              List<Workspace> children = snapshot.data as List<Workspace>;

              if (children.isNotEmpty) {
                return SingleChildScrollView(
                    child:
                        Column(children: buildWorkspacesAndBoards(children)));
              }
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: EmptyWidget(
                  image: null,
                  packageImage: PackageImage.Image_1,
                  title: 'No Boards',
                  subTitle: 'Create your first Trello board',
                  titleTextStyle: const TextStyle(
                    fontSize: 22,
                    color: Color(0xff9da9c7),
                    fontWeight: FontWeight.w500,
                  ),
                  subtitleTextStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xffabb8d6),
                  ),
                ),
              ),
            );
          }),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
          type: ExpandableFabType.up,
          backgroundColor: Colors.green[400],
          expandedFabSize: ExpandableFabSize.regular,
          child: const Icon(Icons.add),
          children: const [
            CustomFloatingAction("Workspace", Icons.book, '/createworkspace'),
            CustomFloatingAction("Board", Icons.book, '/createboard'),
            CustomFloatingAction("Sample Workspace", Icons.dataset_outlined, '/generateworkspace'),
            //CustomFloatingAction("Card", Icons.card_membership, '/createcard')
          ]),
    );
  }

  List<Widget> buildWorkspacesAndBoards(List<Workspace> wkspcs) {
    List<Widget> workspacesandboards = [];
    Widget workspace;

    for (int i = 0; i < wkspcs.length; i++) {
      workspace = ListTile(
        tileColor: whiteShade,
        leading: Text(wkspcs[i].name),
        trailing: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/workspacemenu');
            },
            icon: const Icon(Icons.more_horiz)),
      );

      workspacesandboards.add(workspace);

      workspacesandboards.add(StreamBuilder(
        stream: getBoardsStream(wkspcs[i].id),
        builder: (BuildContext context, AsyncSnapshot<List<Board>> snapshot) {
          if (snapshot.hasData) {
            List<Board> children = snapshot.data as List<Board>;

            if (children.isNotEmpty) {
              return Column(children: buildBoards(children, wkspcs[i]));
            }
          }
          return const SizedBox.shrink();
        },
      ));
    }
    return workspacesandboards;
  }

  List<Widget> buildBoards(List<Board> brd, Workspace wkspc) {
    List<Widget> boards = [];
    for (int j = 0; j < brd.length; j++) {
      boards.add(ListTile(
        leading: ColorSquare(
          bckgrd: brd[j].background,
        ),
        title: Text(brd[j].name),
        onTap: () {
          Navigator.pushNamed(context, BoardScreen.routeName,
              arguments: BoardArguments(brd[j], wkspc));
        },
      ));
    }

    return boards;
  }
}
