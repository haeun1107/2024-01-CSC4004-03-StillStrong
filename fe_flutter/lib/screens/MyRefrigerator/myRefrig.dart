import 'package:flutter/material.dart';
import 'package:fe_flutter/screens/ingredientRegister/ingredientRegister.dart';
import 'package:fe_flutter/service/refrigeServer.dart';
import 'package:fe_flutter/model/refrigeModel.dart';
import '../ingredientMoreInfo/ingredientMoreInfo.dart';
import '../ingredientRegister/ingredientRegister.dart';
import '../recipeSearch/recipeFromIngredient.dart';
import 'myRefrigeratorDropdown.dart';
import 'ingredientSearch.dart';
import 'ingredientSelect.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MyRefrigPage extends StatefulWidget {
  @override
  MyRefrigPageState createState() => MyRefrigPageState();
}

class MyRefrigPageState extends State<MyRefrigPage> {

  late Future<Map<String, dynamic>> itemsFuture;
  static int currentRefrigeId = 7;
  List<String> newItems = ["기본 냉장고"];
  static List<String> ingredients = [];
  static List<int> ingredientDeadlines = [];
  static List<Refrige> refrigeList = [];

  @override
  void initState() {
    super.initState();
    itemsFuture = getRefrigeList();
    itemsFuture.then((data) {
      RefrigeData refrigeData = RefrigeData.fromJson(data);
      setState(() {
        refrigeList = refrigeData.refrigeList;
        newItems = refrigeData.refrigeList.map((refrige) => refrige.refrigeName).toList();
        currentRefrigeId = refrigeData.refrigeList.first.refrigeId;
        var currentRefrige = refrigeData.refrigeList.firstWhere((refrige) => refrige.refrigeId == currentRefrigeId);
        ingredients = currentRefrige.ingredientNames;
        ingredientDeadlines = currentRefrige.ingredientDeadlines;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 30,
          ),
          title: Text(
            'MY 냉장고',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          backgroundColor: Color(0Xffffc94a),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              DropdownRefrige(
                itemsFuture: itemsFuture,
                onChanged: (String selectedName, int selectedId) {
                  setState(() {
                    currentRefrigeId = selectedId;
                    var currentRefrige = refrigeList.firstWhere((refrige) => refrige.refrigeId == currentRefrigeId);
                    ingredients = currentRefrige.ingredientNames;
                    ingredientDeadlines = currentRefrige.ingredientDeadlines;
                    print('Selected Refrigerator ID: $currentRefrigeId');
                    print('Selected Refrigerator Name: $selectedName');
                    print('Ingredients: $ingredients');
                  });
                },
              ),
              IngredientSearch(),
              IngredientWidget(showInfo: showInfo,showRecipeFromIngredient: showRecipeFromIngredient,),
            ],
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () async {
              final RenderBox button = context.findRenderObject() as RenderBox;
              final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
              final RelativeRect position = RelativeRect.fromRect(
                Rect.fromPoints(
                  button.localToGlobal(Offset.zero, ancestor: overlay),
                  button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                ),
                Offset.zero & overlay.size,
              );
              final selectedValue = await showMenu<int>(
                context: context,
                position: position,
                items: [
                  PopupMenuItem<int>(
                    value: 1,
                    child: Text('재료 등록'),
                  ),
                  PopupMenuItem<int>(
                    value: 2,
                    child: Text('영수증 인식하기'),
                  ),
                  PopupMenuItem<int>(
                    value: 3,
                    child: Text('직접 입력하기'),
                  ),
                ],
              );

              if (selectedValue != null) {
                switch (selectedValue) {
                  case 1:
                    break;
                  case 2:
                    break;
                  case 3:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IngredRegPage(currentRefrigeId: currentRefrigeId),
                      ),
                    );
                    break;
                }
              }
            },
            shape: CircleBorder(),
            child: Icon(Icons.add),
            backgroundColor: Color(0Xffffc94a),
          ),
        ),
      ),
    );
  }

  void showPopup(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('재료 등록'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text('영수증 인식'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('직접 입력하기'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/IngredReg'
                    );
                  },
                ),
              ],
            ),
          );
        });
  }

  void showInfo(int refrigeId, String ingredientName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IngredientMoreInformation(
          refrigeId: refrigeId,
          ingredientName: ingredientName,
        ),
      ),
    );
  }

  void showRecipeFromIngredient(List<String> selectedButtons) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeFromIngredient(ingredientList: selectedButtons),
      ),
    );
  }

}

class IngredientWidget extends StatefulWidget {
  final void Function(int, String) showInfo;
  final void Function(List<String>) showRecipeFromIngredient;
  const IngredientWidget({super.key, required this.showInfo, required this.showRecipeFromIngredient});

  @override
  State<IngredientWidget> createState() => _IngredientWidgetState();


}

class _IngredientWidgetState extends State<IngredientWidget> {
  bool isIngredientSelect = false;
  void toggleIngredientSelect() {
    setState(() {
      isIngredientSelect = !isIngredientSelect;
    });
  }

  List<String> fetchIngredient() {
    print("Debug: ingredients: ${MyRefrigPageState.ingredients}");
    return MyRefrigPageState.ingredients;
  }

  @override
  Widget build(BuildContext context) {
    List<String> ingredients = fetchIngredient();
    return Column(
      children: [
        IngredientSelect(onToggle: toggleIngredientSelect,),
        Container(
          alignment: Alignment.center,
          width: 340,
          child: Column(
            children: [
              Wrap(
                spacing: 4.0,
                runSpacing: 4.0,
                children: List.generate(ingredients.length, (index) {
                  int expDate = index < MyRefrigPageState.ingredientDeadlines.length ? MyRefrigPageState.ingredientDeadlines[index] : 0;
                  return IngredIconButton(
                    buttonText: ingredients[index],
                    expDate: expDate,
                    icon: Image.asset('assets/images/ingredient.png'),
                    onPressed: (isIngredientSelect, isPressed, buttonText) {
                      if (!isIngredientSelect) {
                        widget.showInfo(MyRefrigPageState.currentRefrigeId, buttonText);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        if(isIngredientSelect) RecommendRecipeButton(
          onPressed: (selectedButtons) {
            widget.showRecipeFromIngredient(selectedButtons);
          }
        ),
      ],
    );
  }
}
