import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:posflutterapp/bloc/external/external_bloc.dart';
import 'package:posflutterapp/models/TransitionItem.dart';
import 'package:posflutterapp/models/TransitionModel.dart';
import 'package:posflutterapp/page/report_history_page.dart';

import '../models/TransitionModel.dart';

class ReportTodayPage extends StatefulWidget {
  final TransitionItem item;

  ReportTodayPage({Key key, this.item}) : super(key: key);

  @override
  _ReportTodayPageState createState() => _ReportTodayPageState();
}

class _ReportTodayPageState extends State<ReportTodayPage> {
  ExternalBloc _externalBloc;

  @override
  Widget build(BuildContext context) {
    _externalBloc = BlocProvider.of<ExternalBloc>(context);

    _externalBloc.add(widget.item != null
        ? NowadaysReadTransitionExternalEvent(date: widget.item.createAt)
        : NowadaysReadTransitionExternalEvent());

    List<TransitionModel> list = [];

    return BlocBuilder<ExternalBloc, ExternalState>(
        builder: (BuildContext context, _state) {
      if (_state is NowadaysReadTransitionExternalState) {
        List<TransitionModel> listA = _state.data;
        listA.sort((a,b) => _convertToDateTime(a.createAt).compareTo(_convertToDateTime(b.createAt)));
        list = listA.reversed.toList();
      }

      return Scaffold(
        appBar: new AppBar(
          iconTheme: new IconThemeData(color: Colors.purple),
          elevation: 0.1,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Stack(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                      color: Colors.transparent,
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: LayoutBuilder(builder: (context, constraint) {
                          return FlatButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () {
                                _externalBloc.add(widget.item != null
                                    ? MonthReadTransitionExternalEvent(
                                        month: widget.item.month,
                                        year: widget.item.year)
                                    : InitialExternalEvent());
                                Navigator.of(context).pop();
                              },
                              color: Colors.transparent,
                              child: Icon(
                                Icons.close,
                                //color: Colors.black.withAlpha(150),
                                color: Colors.purple,
                              ));
                        }),
                      )),
                ],
              ),
              SizedBox(
                height: 56,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Text(
                        "${widget.item != null ? "รายงานวันที่ ${widget.item.label}" : "รายงานวันนี้"}",
                        style: GoogleFonts.itim(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.purple),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: widget.item == null
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => new ReportHistoryPage(),
                      ));
                },
                label: Text(
                  "ดูรายการย้อนหลัง",
                  style: GoogleFonts.itim(),
                ),
                icon: Icon(Icons.history),
              )
            : null,
        body: _state is NowadaysReadTransitionExternalState
            ? Container(
                color: Colors.black.withAlpha(10),
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: _state.data.length == 0
                      ? Container(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "ไม่พบข้อมูล",
                                  style: TextStyle(
                                      color: Colors.purple[100],
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold),
                                ), // text
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: list.length + 1,
                          padding: EdgeInsets.only(
                              top: 20, bottom: 40, left: 10, right: 10),
                          itemBuilder: (BuildContext context, int position) {
                            if (position == _state.data.length) {
                              return _transitionWidget(
                                  null, _state, _calTotalPrice(_state.data));
                            } else {
                              return _transitionWidget(
                                  list[position], _state, null);
                            }
                          },
                        ),
                ),
              )
            : Container(
                color: Colors.white,
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        height: 50,
                        width: 50,
                        child: SpinKitSquareCircle(
                          color: Colors.purple,
                          size: 50.0,
                        ),
                      ),
                    )
                  ],
                ),
              ),
      );
    });
  }

  Widget _transitionWidget(TransitionModel item,
      ReadTransitionExternalState _state, double totalPrice) {
    return GestureDetector(
      onTap: () {
        if (item != null) {
          _externalBloc.add(ShowTransitionDialogExternalEvent(
              this.context, TransitionItem(item, null), null));
        }
      },
      child: Container(
        decoration: BoxDecoration(
            color: item == null ? Colors.transparent : Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        alignment: Alignment.bottomLeft,
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 15),
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
        child: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width - 170 - 80,
              child: Text(
                item == null
                    ? ""
                    : "${truncateWithEllipsis(6, item.id.replaceAll(new RegExp('-'), '')).toUpperCase()}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.itim(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87),
              ),
            ),
            Container(
              width: 60,
              alignment: Alignment.centerRight,
              child: Text(
                item == null
                    ? "ยอดรวม"
                    : "${_loadDateForTimeLabel(item.createAt)} น.",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.itim(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              width: 110,
              child: Text(
                item == null
                    ? "${totalPrice.toStringAsFixed(2)} บาท"
                    : "${item.price} บาท",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.itim(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calTotalPrice(List<TransitionModel> list) {
    double total = 0;
    for (TransitionModel item in list) {
      total += double.parse(item.price);
    }
    return total;
  }

  String _loadDateForTimeLabel(String date) {
    var formatter = new DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    DateTime dateTime = formatter.parse(date);
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  DateTime _convertToDateTime(String date){
    var formatter = new DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    DateTime dateTime = formatter.parse(date);
    return dateTime;
  }

  String truncateWithEllipsis(int cutoff, String myString) {
    return (myString.length <= cutoff)
        ? myString
        : '${myString.substring(0, cutoff)}...';
  }
}
