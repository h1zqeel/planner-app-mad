import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planerio/Misc/getdata.dart';
import 'package:planerio/widget/fieldSearch.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:weekday_selector/weekday_selector.dart';

class AddTask extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AddTaskState();
  }
}

class AddTaskState extends State<AddTask>{
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController titleTextController =
  TextEditingController();
  final TextEditingController subTitleTextController =
  TextEditingController();
  final TextEditingController numWeeksTextController =
  TextEditingController();
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime selectedDate = DateTime.now();
  bool isToggled = false;
  bool isChecked = false;
  List<String> userNames = [];
  final values = List.filled(7, false);

  final roundedButtonController = RoundedLoadingButtonController();
  void insertUserSpecificTask(title, subtitle, day, time, repeat, isDate) {
    print('Title:' + title + "\nSubtitle:" + subtitle);
    print(day.toString());
    print(time.toString());
    print(repeat.toString());
    print(isDate.toString());
  }
  void addTaggedFriends(String f){
    print('XD LOL');
    setState(() {
      userNames.add(f);
    });
  }
  Widget myFun() {
    if (!isToggled) {
      return StatefulBuilder(builder: (context, setState) {

        return WeekdaySelector(
            onChanged: (int i) {
              final index = i % 7;

              setState(() {
                values[index] = !values[index];
              });

              // setState(() {
              //   weekValues[onChanged % 7] = !weekValues[onChanged % 7];
              // });
            },
            values: values);
      });
    } else {
      selectedDate = DateTime.now();
      return StatefulBuilder(builder: (context, setState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2050));
                  setState(() {
                    selectedDate = date!;
                  });
                  print(selectedDate);
                },
                child: Text('Select Date')),
            Text(selectedDate.day.toString() +
                '-' +
                selectedDate.month.toString() +
                '-' +
                selectedDate.year.toString()),
          ],
        );
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: PreferredSize(

          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            brightness: Brightness.dark,
            elevation: 0.0,
            backgroundColor: Colors.indigo[900],
            title: Text('Add Plan', style: TextStyle(fontSize: 22)),
          )),
      body:
      SingleChildScrollView(child:
      Container(
        margin: EdgeInsets.only(left: 10,right: 10),
        child:
            Column(children: [
      Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleTextController,
                  validator: (value) {
                    return value!.isNotEmpty
                        ? null
                        : "This Can't be Empty :(";
                  },
                  decoration: InputDecoration(
                    labelText: 'Title',
                  ),
                ),
                TextFormField(
                  controller: subTitleTextController,
                  validator: (value) {
                    return value!.isNotEmpty
                        ? null
                        : "This Can't be Empty :(";
                  },
                  decoration: InputDecoration(
                    labelText: 'Details',
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                myFun(),
                SizedBox(
                  height: 1,
                ),
                // ListView.builder(
                //     itemCount: userNames.length,
                //     itemBuilder: (context,index){
                //   return ListTile(title: Text('xd'),);
                // }),
              isToggled?
                UsernameFieldSearch(func: addTaggedFriends,):Row(),


                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () async {
                          final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now());
                          setState(() {
                            selectedTime = time!;
                          });
                          print('new time' + selectedTime.toString());
                        },
                        child: Text('Select Time')),
                    Text(selectedTime.hour.toString() +
                        ':' +
                        selectedTime.minute.toString()),
                  ],
                ),
               !isToggled?
               Column(children: [
               Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Repeat Every Week ?"),

                    Checkbox(
                        value: isChecked,
                        onChanged: (value) {
                          setState(() {
                            isChecked = value!;
                          });
                        })
                  ],
                ),
                isChecked?
                 TextFormField(
                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                   keyboardType: TextInputType.number,
                   controller: numWeeksTextController,
                   validator: (value) {
                     return value!.isNotEmpty
                         ? null
                         : "This Can't be Empty";
                   },
                   decoration: InputDecoration(
                     labelText: 'How Many Weeks ?',
                   ),
                 ):Row()
                   ])
                   :Row(

               ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Choose a Date ?"),
                    Switch(
                        value: isToggled,
                        onChanged: (value) {
                          setState(() {
                            isToggled = value;

                          });
                          if(value == true){
                            setState(() {
                              isChecked = false;
                            });
                          }
                          print(isToggled);
                        })
                  ],
                )
              ],
            ),
          )
            ),
              RoundedLoadingButton(
                  color: Colors.blueAccent,
                  height: 30,
                  loaderSize: 14,
                  width: 100,
                  controller: roundedButtonController,
                  onPressed: () async {


                      // print(titleTextController.text);
                      if(!isToggled) {
                        if(_formKey.currentState!.validate()){
                          try {
                            if(isChecked) {
                              await insertPlan(
                                  titleTextController.text,
                                  subTitleTextController.text,
                                  values,
                                  selectedTime,
                                  isChecked,
                                  isToggled,
                                  int.parse(numWeeksTextController.text)
                              );
                            } else {
                              await insertPlan(
                                  titleTextController.text,
                                  subTitleTextController.text,
                                  values,
                                  selectedTime,
                                  isChecked,
                                  isToggled
                              );
                            }
                          }
                          catch(e){
                            roundedButtonController.reset();
                            showDialog(context: context, builder: (context){
                              return AlertDialog(title: Center(child: Text(e.toString(),style: TextStyle(color: Colors.redAccent),)),actions: [TextButton(onPressed: (){
                                Navigator.pop(context);
                              }, child: Text('Close'))],);
                            });
                          }
                          titleTextController.clear();
                          subTitleTextController.clear();
                          numWeeksTextController.clear();
                          roundedButtonController.success();
                        } else {
                          roundedButtonController.reset();
                        }


                      }
                      else{
                        roundedButtonController.reset();
                          if(_formKey.currentState!.validate()){
                            try{
                              await insertPlan(
                                  titleTextController.text,
                                  subTitleTextController.text,
                                  selectedDate,
                                  selectedTime,
                                  isChecked,
                                  isToggled,
                                  userNames
                              );
                              titleTextController.clear();
                              subTitleTextController.clear();
                              numWeeksTextController.clear();
                              roundedButtonController.success();
                            }
                            catch(e){
                              roundedButtonController.reset();
                              showDialog(context: context, builder: (context){
                                return AlertDialog(title: Center(child: Text(e.toString(),style: TextStyle(color: Colors.redAccent),)),actions: [TextButton(onPressed: (){
                                  Navigator.pop(context);
                                }, child: Text('Close'))],);
                              });
                            }


                          }
                      }

                  },
                  child: Text('Save'))
              ,
              Container(
                margin: EdgeInsets.only(top:20),
                child:

              Text('*Weekly Plans help you Plan your Daily Tasks, you can choose if you want them to repeat every weak'),
                  )
                  ]
            ),
      ),
          ),
    );
  }
}