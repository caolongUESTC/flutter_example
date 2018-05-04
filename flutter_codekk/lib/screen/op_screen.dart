import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_codekk/entity/op_entity.dart';
import 'package:flutter_codekk/net/api.dart';
import 'package:flutter_codekk/net/fetch.dart';
import 'package:flutter_codekk/tool/tool.dart';
import 'package:flutter_codekk/widget/base_state.dart';
import 'package:flutter_codekk/widget/item_widget_fix.dart';
import 'package:flutter_codekk/widget/status_widget.dart';
import 'package:meta/meta.dart';

///  开源项目
class OpScreen extends StatefulWidget {
  final String title;

  OpScreen({@required this.title});

  @override
  State<StatefulWidget> createState() => new OpState(title: title);
}

class OpState extends ListState<OpScreen, ProjectArrayEntity> {
  final String title;

  OpState({@required this.title});

  @override
  void initState() {
    super.initState();
    onRefresh(); // currentState null at this time, so the app crashes.
  }

  @override
  Widget itemWidget(ProjectArrayEntity entity) {
    return new Card(
        child: new InkWell(
      onTap: () =>
          startDetailScreen(context, entity.projectName, ApiType.OP, entity.id),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          text(entity.projectName, Colors.green),
          text(entity.desc, Colors.blue),
          text(entity.projectUrl, Colors.pinkAccent),
        ],
      ),
    ));
  }

  @override
  Future<Null> onRefresh() async {
    globalKey.currentState?.show();
    await fetchOp(1, '').then((opEntity) {
      list = opEntity.data.projectArray;
      setState(() {
        if (list.isEmpty) {
          status = Status.EMPTY;
        } else {
          page = 2;
        }
      });
    }).catchError((error) => setState(() {
          status = Status.ERROR;
          list = [];
        }));
  }

  @override
  void onLoadMore() async {
    loadMoreTips();
    List<ProjectArrayEntity> items;
    await fetchOp(page, '')
        .then((opEntity) => items = opEntity.data.projectArray)
        .catchError((error) => loadMoreErrorTips());
    if (items.isEmpty) {
      noMoreTips();
    } else {
      list.addAll(items);
      page++;
      isLoadMore = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return new StatusWidget(
      child: new NotificationListener(
        onNotification: onNotification,
        child: new RefreshIndicator(
          key: globalKey,
          onRefresh: onRefresh,
          child: new ListView.builder(
            controller: scrollController,
            padding: kMaterialListPadding,
            itemCount: list.length,
            itemBuilder: (context, index) => itemWidget(list[index]),
          ),
        ),
      ),
      status: status,
      onErrorPressed: () {
        setState(() {
          status = Status.SUCCESS;
          onRefresh();
        });
      },
      onEmptyPressed: () {
        setState(() {
          status = Status.SUCCESS;
          onRefresh();
        });
      },
    );
  }
}
