import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:posflutterapp/bloc/external/external_bloc.dart';
import 'package:posflutterapp/models/TransitionItem.dart';
import 'package:posflutterapp/models/TransitionModel.dart';
import 'package:posflutterapp/page/report_today_page.dart';

class ReportMonthDetailPage extends StatefulWidget {

  final TransitionItem item;

  ReportMonthDetailPage(this.item,{Key key}) : super(key: key);

  @override
  _ReportMonthDetailPageState createState() => _ReportMonthDetailPageState();
}

class _ReportMonthDetailPageState extends State<ReportMonthDetailPage> {
  ExternalBloc _externalBloc;

  @override
  Widget build(BuildContext context) {
    _externalBloc = BlocProvider.of<ExternalBloc>(context);
    _externalBloc.add(MonthReadTransitionExternalEvent(month: widget.item.month,year: widget.item.year));


    return BlocBuilder<ExternalBloc, ExternalState>(
        builder: (BuildContext context, _state) {
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
                          height: 56,
                          child: LayoutBuilder(builder: (context, constraint) {
                            return FlatButton(
                                padding: EdgeInsets.all(0),
                                onPressed: () {
                                  _externalBloc.add(YearReadTransitionExternalEvent());
                                  Navigator.of(context).pop();
                                },
                                color: Colors.transparent,
                                child: Icon(
                                  Icons.arrow_back,
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
                          "รายงานเดือน${widget.item.label}",
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
          body: _state is MonthReadTransitionExternalState
              ? Container(
            color: Colors.black.withAlpha(10),
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: ListView.builder(
                itemCount: _state.list.length,
                padding: EdgeInsets.only(
                    top: 20, bottom: 40, left: 10, right: 10),
                itemBuilder: (BuildContext context, int position) {
                  return _transitionWidget(
                      _state.list[position], _state, position);
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
          ));
    });
  }

  Widget _transitionWidget(
      TransitionItem item, ReadTransitionExternalState _state, int position) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => new ReportTodayPage(item: item,),
            ));
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        alignment: Alignment.bottomLeft,
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 15),
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${item.label}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.itim(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.itim(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${item.price} บาท",
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
}
