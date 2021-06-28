import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:planerio/Misc/getdata.dart';
import 'package:planerio/addFriend.dart';
typedef List<String> getusernames();
late Function myFun;
class UsernameFieldSearch extends StatefulWidget {
  // late Function fun;

  UsernameFieldSearch({required void Function(String f) func}){
    myFun = func;
  }



  UsernameFieldSearchState createState() => UsernameFieldSearchState();

}


class UsernameFieldSearchState extends State<UsernameFieldSearch> {

  // const UsernameFieldSearch({Key? key}) : super(key: key);
late List<String> emails = [''];
late String emailText = '';
  static const List<String> _kOptions = <String>[
    'aardvark',
    'bobcat',
    'chameleon',
  ];
@override
  void initState() {

    // TODO: implement initState
    super.initState();
    // getFriends().then((value) => {
    //   value.forEach((element) {
    //     setState(() {
    //       print(element.email);
    //       emails.add(element.email);
    //     });
    //   })
    // });
  }
  @override
  Widget build(BuildContext context) {

  return
    Column(children: [
      Container(
        margin: EdgeInsets.only(top: 10),
        child:  Text(emailText,textScaleFactor: 0.8,),

      ),
    TypeAheadField(
    textFieldConfiguration: TextFieldConfiguration(

        style: DefaultTextStyle.of(context).style.copyWith(
            fontStyle: FontStyle.italic
        ),
        decoration: InputDecoration(

            labelText: 'Tag Friends:'
        )
    ),
    suggestionsCallback: (pattern) async {
      return await getFriendString(pattern);
    },
    itemBuilder: (context,  suggestion) {

        return ListTile(

          title: Text(suggestion.toString()),

        );


    },
    onSuggestionSelected: (suggestion) {

    if(!emails.contains(suggestion.toString())) {
      myFun(suggestion);
      setState(() {
        emailText =
            emailText + suggestion.toString().replaceAll('@gmail.com', '') +
                ', ';
        emails.add(suggestion.toString());
      });
    }
    },
  )
    ],);
    // return Autocomplete<String>(
    //
    //   optionsBuilder: (TextEditingValue textEditingValue) {
    //     if (textEditingValue.text == '') {
    //       return const Iterable<String>.empty();
    //     }
    //     return emails.where((String option) {
    //       return option.contains(textEditingValue.text.toLowerCase());
    //     });
    //   },
    //   onSelected: (String selection) {
    //     print('You just selected $selection');
    //   },
    // );
  }
}