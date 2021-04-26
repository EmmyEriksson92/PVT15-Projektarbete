import 'package:flutter/material.dart';
import 'package:pvt_15/app_localizations.dart';
import 'package:pvt_15/modules/helpers.dart' as helper;
import 'package:pvt_15/globals.dart' as globals;

import 'dart:developer';

class MyFilterPage extends StatefulWidget {
  @override
  _MyFilterPageState createState() => _MyFilterPageState();
}

class RaisedButtonAdder extends StatefulWidget {
  final String _buttonText;
  _RaisedButtonState myState;
  
  _RaisedButtonState getState()
  {
    return myState;
  }
  
  RaisedButtonAdder(this._buttonText);

  @override
  _RaisedButtonState createState() {
    myState=_RaisedButtonState();
    return myState;
  } 
}

BuildContext con;

class _MyFilterPageState extends State<MyFilterPage> {
  List<RaisedButtonAdder> filterButtons = new List<RaisedButtonAdder>();

  List<RaisedButtonAdder> createFilterButtons()
  {
    List<String> buttonsToAdd = [
      'park',
      'playground',
      'sledding_hill',
      'ball_game',
      'picnic',
      'outdoor_bathing',
      'barbeque',
      'walking',
      'nature_play',
      'animal_friendly'
    ];
    filterButtons.clear();
    for(int i = 0; i < buttonsToAdd.length; i++){
      filterButtons.add(
        new RaisedButtonAdder(
          AppLocalizations.of(context).translate('${buttonsToAdd[i]}')
        ),
      );
    }
    return filterButtons;
  }


  void clearFilterButtons()
  {
   for(RaisedButtonAdder rba in filterButtons)
   {
     rba.getState().setUnmarked();
   }
  helper.applyFilters();
  globals.currentMapState.refreshVisiblePolys();

}
  

  @override
  Widget build(context) {
    createFilterButtons();
    return Container(
        padding: EdgeInsets.only(top: 10, bottom: 30.0),
        height: 600,
        child: Drawer(
            child:
                ListView(
                  shrinkWrap: true, 
                  padding: EdgeInsets.zero,
                   children: [
          SizedBox(
              height: 100,
              child: DrawerHeader(
                  padding: EdgeInsets.only(top: 0.0, bottom: 20.0),
                  child: Row(children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          icon: Icon(Icons.chevron_left),
                          iconSize: 40,
                        )),
                    SizedBox(width: 50),
                    Text("Filter",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold)),
                  ]))),
          Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              alignment: Alignment.topCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                  child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Wrap(
                    spacing: 8,
                    children: filterButtons ,
                  ),
                  SizedBox(height: 10),
                  DividerAdder(),
                ],
              )
            )
          ),
          SizedBox(height: 15),
          BottomAppBar(
              child: Row(
            children: <Widget>[
              Expanded(
                  child: Material(
                color: Colors.grey[300],
                child: InkWell(
                    onTap: () {helper.clearFilters();
                    clearFilterButtons();
                      log("Container rensa filter clicked");
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 70,
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalizations.of(context).translate('clear'),
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              )),
              Expanded(
                child: Material(
                  color: Colors.lightGreen[300],
                  child: InkWell(
                      onTap: () {
                        helper.applyFilters();
                        log("Container hitta platser clicked");
                        Navigator.pop(context, true);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 70,
                        alignment: Alignment.center,
                        child: Text(
                          AppLocalizations.of(context).translate('apply'),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                ),
              )
            ],
          )),
        ])));
  }
}

class _RaisedButtonState extends State<RaisedButtonAdder> {
  Color backgroundColor = Colors.grey[300];
  Color backgroundColorPressed = Colors.lightGreen[300];
  bool pressed = false;

  void setUnmarked(){
    setState(() {
      backgroundColor = Colors.grey[300];
      pressed = false;
      helper.toggleFilterQual(widget._buttonText, pressed);
    });
  }

  Color getBackgroundColor(String button){
    Color color;
    bool b;
    List<String> keyWords = globals.qByName[button];

    for(int i = 0; i < keyWords.length; i++){
      if(globals.filtersApplied[keyWords[i]] != null && globals.filtersApplied[keyWords[i]])
        b = true;
    }
    
    if(b != null && b)
      color = backgroundColorPressed;
    else
      color = backgroundColor;

    log('B = $b');
    log('filtersApplied = ${globals.filtersApplied.toString()}');
    log('Button = $button');
    log('Keywords for button = $keyWords');

    return color;
  }

  @override
  Widget build(BuildContext context) {
    con = context;
    return ButtonTheme(
      minWidth: 40,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(15.0)),
        child: Text(
          '${widget._buttonText}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        color: getBackgroundColor(widget._buttonText),
        textColor: Colors.grey[600],
        onPressed: () {
          if (backgroundColor == Colors.lightGreen[300]) {
            setState(() {
              backgroundColor = Colors.grey[300];
              pressed = false;
              helper.toggleFilterQual(widget._buttonText, pressed);
            });
          } else {
            setState(() {
              backgroundColor = Colors.lightGreen[300];
              pressed = true;
              helper.toggleFilterQual(widget._buttonText, pressed);
            });
          }
        },
      )
    );
  }
}


class IconButtonAdder extends StatefulWidget {
  //VARIABLES
  final String _buttonText;
  final Image _icon;
  //CONSTRUCTOR
  IconButtonAdder(this._buttonText, this._icon);

  @override
  _IconButtonState createState() => _IconButtonState();
}

class _IconButtonState extends State<IconButtonAdder> {
  bool checked = false;

  @override
  Widget build(BuildContext context) {
    Row rw = Row(children: <Widget>[
      SizedBox(
        height: 30,
        width: 30,
        child: Tab(icon: widget._icon),
      ),
      Text(widget._buttonText,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600])),
      Spacer(),
      Visibility(
          visible: checked,
          child: Icon(
            Icons.check,
            color: Colors.lightGreen[300],
            size: 30,
          ))
    ]);

    return ButtonTheme(
        minWidth: 40,
        child: FlatButton(
          padding: EdgeInsets.only(left: 0, right: 20),
          child: rw,
          onPressed: () {
            if (checked == false) {
              checked = true;
              print(checked);
              setState(() {});
            } else if (checked == true) {
              checked = false;
              print(checked);
              setState(() {});
            }
          },
        ));
  }
}

class DividerAdder extends StatelessWidget {
  //CONSTRUCTOR
  DividerAdder();

  @override
  Widget build(BuildContext context) {
    return Divider(color: Colors.black, indent: 0, endIndent: 0, height: 0);
  }
}