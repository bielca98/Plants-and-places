import 'package:flutter/material.dart';
import '../models/plant_location_model.dart';

class PlantDetailPage extends StatelessWidget {
  static const String id = "detail";
  final PlantLocationModel plantLocationModel;

  const PlantDetailPage(this.plantLocationModel, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.clear),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          plantLocationModel.plant,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                plantLocationModel.image,
                height: MediaQuery.of(context).size.height * 0.725,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.025),
            Center(
              child: Text(
                "Imatge presa per ${plantLocationModel.user}",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }
}
