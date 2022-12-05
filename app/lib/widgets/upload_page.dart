import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plants_and_places/services.dart';
import 'package:plants_and_places/widgets/dialogs.dart';
import 'package:plants_and_places/widgets/progress_dialog.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:geolocator/geolocator.dart';
import '../models/plant_location_model.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({Key key}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File _image;
  final picker = ImagePicker();

  Future _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No heu seleccionat cap imatge.');
      }
    });
  }

  Future _uploadImage() async {
    if (_image == null) {
      await showErrorDialog(
        context,
        title: "Imatge no seleccionada",
        message:
            "No heu seleccionat cap imatge. Seleccioneu-ne una per a continuar.",
      );
      return;
    }

    Position currentLocation = await getCurrentLocation(context);

    String type;
    await showConfirmationDialog(
      context,
      title: "Què estàs identificant",
      message: "Si us plau, indica quina part de la planta estàs identificant.",
      confirmText: "Flor",
      cancelText: "Fulla",
      confirmFunction: () {
        type = "flower";
        Navigator.pop(context);
      },
      cancelFunction: () {
        type = "leaf";
        Navigator.pop(context);
      },
    );

    if (type == null) return;

    final ProgressDialog loadingDialog = buildProgressDialog(context);
    loadingDialog.style(message: "Identificant planta...");
    await loadingDialog.show();

    APIResponse idResponse = await RESTAPI.identifyPlant(_image, type);

    if (!idResponse.success) {
      loadingDialog.hide();
      await showErrorDialog(
        context,
        title: "S'ha produït un error",
        message: "S'ha produït un error i no s'ha pogut identificar la planta.",
      );
      return;
    }

    String plantName;
    try {
      plantName =
          (idResponse.object as Map)['results'][0]['species']['scientificName'];
    } catch (e) {
      loadingDialog.hide();
      await showErrorDialog(
        context,
        title: "S'ha produït un error",
        message: "S'ha produït un error i no s'ha pogut identificar la planta.",
      );
      return;
    }

    plantName = plantName.substring(0, plantName.length - 1);

    PlantLocationModel plantLocation = new PlantLocationModel(
      plant: plantName,
      imageFile: _image,
      latitude: currentLocation.latitude,
      longitude: currentLocation.longitude,
    );
    loadingDialog.style(message: "Compartint amb la comunitat...");

    APIResponse response = await RESTAPI.createPlantLocation(plantLocation);
    await loadingDialog.hide();

    if (response.success) {
      setState(() {
        _image = null;
      });

      await showSuccessDialog(
        context,
        title: "Planta identificada i pujada amb èxit!",
        message:
            "La planta s'ha identificat com a $plantName i s'ha compartit amb la comunitat. De seguida podràs veure-la al mapa!",
      );
    } else {
      await showErrorDialog(
        context,
        title: "S'ha produït un error",
        message: "S'ha produït un error i no s'ha pogut processar la petició.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 48),
            FlatButton(
              onPressed: _getImage,
              child: Column(
                children: [
                  _image == null
                      ? Icon(
                          Icons.crop_original_rounded,
                          size: 120.0,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            _image,
                            height: 240.0,
                          ),
                        ),
                  SizedBox(height: 24.0),
                  Text(
                    _image == null
                        ? "Selecciona una imatge"
                        : "Clica per canviar la imatge",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
              child: OutlineButton(
                onPressed: _uploadImage,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.file_upload),
                      Text("Puja la imatge"),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
