import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:posflutterapp/bloc/firebase_products/firebase_products_bloc.dart';
import 'package:posflutterapp/models/products_models.dart';
import 'package:posflutterapp/page/page_products_details.dart';

class Products extends StatefulWidget {
  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  FirebaseProductsBloc _firebaseProductsBloc;
  Future<void> run() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      Firestore.instance
          .collection("Users")
          .document(user.uid)
          .collection('products')
          .snapshots()
          .listen((value) {
        _firebaseProductsBloc.add(RefreshFirebaseProductsEvent(value));
        value.documents.forEach((element) {
          print(element.data);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _firebaseProductsBloc = BlocProvider.of<FirebaseProductsBloc>(context);

    run();
    return BlocBuilder<FirebaseProductsBloc, FirebaseProductsState>(
      builder: (BuildContext context, _state) {
        print("HI");
        print(_state);
        if (_state is UpdatedFirebaseProductsState) {
          return _state.data.length == 0
              ? Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.add_box,
                          color: Colors.purple[100],
                          size: 100,
                        ), // icon
                        Text(
                          "กรุณาเพิ่มสินค้า",
                          style: TextStyle(
                              color: Colors.purple[100],
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                        ), // text
                      ],
                    ),
                  ),
                )
              : GridView.builder(
                  itemCount: _state.data.length ?? 0,
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Single_prod(_state.data[index]),
                    );
                  });
        } else {
          return Container(
            color: Colors.purple,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    height: 50,
                    width: 50,
                    child: SpinKitSquareCircle(
                      color: Colors.white,
                      size: 50.0,
                    ),
                  ),
                )
              ],
            ),
          );
        }
      },
    );
  }
}

class Single_prod extends StatelessWidget {
  final Product _product;
  String _image;

  Single_prod(this._product);

  @override
  Widget build(BuildContext context) {
    _image = _product.image != null
        ? (_product.image.length > 0 ? _product.image[0] : "")
        : "";

    return Container(
      color: Colors.green,
      width: MediaQuery.of(context).size.width / 2 - 8,
      height: 560,
      child: Hero(
        tag: new Text("hero1"),
        child: Material(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetail(_product, context),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 2 - 8,
              child: Stack(
                children: [
                  _image.length > 0
                      ? Container(
                          width: (MediaQuery.of(context).size.width / 2) - 8,
                          height: 120,
                          child: CachedNetworkImage(
                            imageUrl: _image,
                            fit: BoxFit.fitHeight,
                          ),
                          /*child: Image.network(
                            _image,
                            fit: BoxFit.fitHeight,
                          ),

                           */
                        )
                      : Container(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 80,
                      width: (MediaQuery.of(context).size.width / 2) - 8,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            height: (80 / 5) * 2,
                            width: (MediaQuery.of(context).size.width / 2) - 8,
                            //color: Color(0x40000000),
                            child: Container(
                              alignment: Alignment.bottomLeft,
                              margin: EdgeInsets.only(left: 20, right: 20),
                              child: Text(
                                "${(_product.name ?? "")} (ขนาด ${_product.size})",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.itim(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: Colors.black87),
                              ),
                            ),
                          ),
                          Container(
                            height: (80 / 5) * 3,
                            width: (MediaQuery.of(context).size.width / 2) - 8,
                            color: Colors.white,
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  margin: EdgeInsets.only(left: 20, right: 20),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "ราคา",
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
                                          "${_product.salePrice}" + " ฿" ?? "",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: GoogleFonts.itim(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black87),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  margin: EdgeInsets.only(left: 20, right: 20),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "คงเหลือ",
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
                                        child: Text(_product.quantity == null ? "" : (double.parse(_product.quantity) <= 0 ? "สินค้าหมด" : "${_product.quantity} ชิ้น"),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: GoogleFonts.itim(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: _product.quantity == null ? Colors.black87 : (double.parse(_product.quantity) <= 10 && double.parse(_product.quantity) >= 1 ? Colors.orange : double.parse(_product.quantity) <= 0 ? Colors.red : Colors.black87)),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
