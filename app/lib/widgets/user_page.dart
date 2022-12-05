import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plants_and_places/models/plant_location_model.dart';
import 'package:plants_and_places/screens/signup_screen.dart';
import 'package:plants_and_places/services.dart';
import 'package:plants_and_places/widgets/loading.dart';

import 'dialogs.dart';
import 'plant_detail_page.dart';

class UserPage extends StatefulWidget {
  UserPage({Key key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Future<List<PlantLocationModel>> _plantsFuture;
  String username;

  Future<List<PlantLocationModel>> _getPlantLocations() async {
    APIResponse response = await RESTAPI.listUserPlantLocations();

    while (!response.success) {
      response = await RESTAPI.listUserPlantLocations();
    }

    return response.object;
  }

  void _logout() async {
    await showConfirmationDialog(
      context,
      title: "Confirmeu l'acció",
      message: "Esteu a punt de tancar la sessió, voleu continuar?",
      confirmFunction: () async {
        APIResponse response = await RESTAPI.logOut();

        if (response.success) {
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(builder: (_) => SignupScreen()),
            (Route<dynamic> route) => false,
          );
        } else {
          showErrorDialog(
            context,
            title: "Error inesperat",
            message: "No s'ha pogut tancar la sessió.",
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    RESTAPI.secureStorage.read(key: "username").then((var un) {
      setState(() => username = un);
    });
    _plantsFuture = _getPlantLocations();
  }

  Widget _buildTile(PlantLocationModel plantLocationModel) {
    return ListTile(
      isThreeLine: true,
      title: Text(plantLocationModel.plant),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: Container(
          height: 48.0,
          width: 48.0,
          child: Image.network(
            plantLocationModel.image,
            fit: BoxFit.cover,
          ),
        ),
      ),
      subtitle: Text(
          "Coordenades ${plantLocationModel.latitude}, ${plantLocationModel.longitude}"),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) {
        return PlantDetailPage(plantLocationModel);
      })),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        elevation: 0,
        title: Text(
          "Herbolari de $username",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          FlatButton(
            child: Text("Tanca la sessió"),
            textColor: Colors.white,
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder(
          future: _plantsFuture,
          builder: (BuildContext context,
              AsyncSnapshot<List<PlantLocationModel>> snapshot) {
            Widget result;

            if (snapshot.hasData) {
              result = Container(
                padding: EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return _buildTile(snapshot.data[index]);
                  },
                ),
              );
            } else {
              result = DefaultLoading();
            }

            return result;
          }),
    );
  }
}
