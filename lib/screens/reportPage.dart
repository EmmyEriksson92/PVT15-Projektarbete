import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pvt_15/screens/mapPage.dart';

class ReportPage extends StatefulWidget {
  @override
  State<ReportPage> createState() => ReportPageState();
}

class ReportPageState extends State<ReportPage> {
  
  @override
  void initState() {
    super.initState();
    _dropdownMenuItems = buildDropdownMenuItems(_categories);
    _selectedCategory = _dropdownMenuItems[0].value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade200,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.black54,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('Rapportera problem',
              style: TextStyle(color: Colors.black54)),
        ),
        body: Container(
            padding: EdgeInsets.only(left: 28.0, right: 28.0),
            color: Colors.lightGreen[200],
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Center(
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  Text(
                    'Felanmäl och tyck till om trafik- och utemiljö.\nGör en viktig insats för vår stad och felanmäl!',
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.left,
                  ),
                  placeInput,
                  Container(
                    width: 200,
                    padding: EdgeInsets.fromLTRB(20.0, 0.0, 10.0, 0),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            width: 1.0,
                            style: BorderStyle.solid,
                            color: Colors.grey.shade800),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        icon: Icon(Icons.keyboard_arrow_down),
                        elevation: 10,
                        value: _selectedCategory,
                        items: _dropdownMenuItems,
                        style: TextStyle(
                            color: Colors.grey.shade800, fontFamily: "Verdana"),
                        onChanged: onChangeDropdownItem,
                      ),
                    ),
                  ),
                  Container(
                      width: 380,
                      child: descriptionInput,
                      ),
                  SizedBox(
                      width: 160,
                      height: 50,
                      child: RaisedButton(
                          onPressed: () {
                            showDialog(
                            context: context,
                            builder: (BuildContext context){
                              Future.delayed(Duration(seconds: 2), (){
/*                              Navigator.of(context).pop(true);*/
                                Navigator.push(context, MaterialPageRoute(builder: (context) => MapPage()));
                             });
                              return alertDialog;
                            },
                            );
                          },
                          color: Colors.green,
                          child: Text("Rapportera",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontFamily: "Verdana")),
                          elevation: 10.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          )))),
                ]))));
  }

  final placeInput = TextFormField(
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Plats',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        hintStyle: TextStyle(color: Colors.grey[800]),
      ));

  final descriptionInput = TextFormField(
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Beskrivning (ej obligatorisk)',
        fillColor: Colors.white,
        filled: true,
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 60.0),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        )),
        hintStyle: TextStyle(color: Colors.grey[800]),
      )
    );

    final alertDialog = AlertDialog(
      title: Text('Tack för hjälpen!'),
      titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      content: Text('Med ditt bidrag förbättrar vi tillsammans Stockholms stad!'),
      contentTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      elevation: 24.0,
      backgroundColor: Colors.green,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
    );
  onChangeDropdownItem(Category selectedCategory) {
    setState(() {
      _selectedCategory = selectedCategory;
    });
  }
}

class Category {
  int id;
  String name;

  Category(this.id, this.name);

  static List<Category> getCategory() {
    return <Category>[
      Category(1, 'Kategori 1'),
      Category(2, 'Kategori 2'),
      Category(3, 'Kategori 3'),
      Category(4, 'Kategori 4'),
      Category(5, 'Kategori 5'),
    ];
  }
}

List<Category> _categories = Category.getCategory();
List<DropdownMenuItem<Category>> _dropdownMenuItems;
Category _selectedCategory;

List<DropdownMenuItem<Category>> buildDropdownMenuItems(List categories) {
  List<DropdownMenuItem<Category>> items = List();
  for (Category category in categories) {
    items.add(
      DropdownMenuItem(
        value: category,
        child: Text(category.name),
      ),
    );
  }
  return items;
}
