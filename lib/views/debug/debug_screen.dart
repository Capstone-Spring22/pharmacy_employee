import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final TextEditingController _startCtrl = TextEditingController();
  final TextEditingController _endCtrl = TextEditingController();

  // FetchPlaceResponse? startPosition;
  // FetchPlaceResponse? endPosition;
  Place? startPosition;
  Place? endPosition;

  late FocusNode startFocusNode;
  late FocusNode endFocusNode;

  late FlutterGooglePlacesSdk googlePlacesSdk;
  List<AutocompletePrediction> predictions = [];
  Timer? _debounce;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String api = "AIzaSyA-o0R0YqUsAQzDTYXrwteBXa7SUADNxlg";
    googlePlacesSdk = FlutterGooglePlacesSdk(api);

    startFocusNode = FocusNode();
    endFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    startFocusNode.dispose();
    endFocusNode.dispose();
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlacesSdk.findAutocompletePredictions(value);
    if (mounted) {
      print(result.predictions.first.fullText);
      setState(() {
        predictions = result.predictions;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Debug/Demo"),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            TextField(
              focusNode: startFocusNode,
              controller: _startCtrl,
              autofocus: false,
              decoration: InputDecoration(
                  hintText: 'Start',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: InputBorder.none,
                  suffixIcon: _startCtrl.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            predictions = [];
                            _startCtrl.clear();
                          },
                          icon: const Icon(Icons.clear_outlined))
                      : null),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 1000), () {
                  if (value.isNotEmpty) {
                    autoCompleteSearch(value);
                  } else {
                    setState(() {
                      predictions = [];
                      startPosition = null;
                    });
                  }
                });
              },
            ),
            const SizedBox(
              height: 30,
            ),
            TextField(
              focusNode: endFocusNode,
              controller: _endCtrl,
              autofocus: false,
              enabled: _startCtrl.text.isNotEmpty && startPosition != null,
              decoration: InputDecoration(
                  hintText: 'End',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: InputBorder.none,
                  suffixIcon: _endCtrl.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            predictions = [];
                            _endCtrl.clear();
                          },
                          icon: const Icon(Icons.clear_outlined))
                      : null),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 1000), () {
                  if (value.isNotEmpty) {
                    autoCompleteSearch(value);
                  } else {
                    setState(() {
                      predictions = [];
                      endPosition = null;
                    });
                  }
                });
              },
            ),
            ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () async {
                    final placeId = predictions[index].placeId;
                    final details =
                        await googlePlacesSdk.fetchPlace(placeId, fields: [
                      PlaceField.Address,
                      PlaceField.AddressComponents,
                      PlaceField.Id,
                      PlaceField.Location,
                      PlaceField.Name,
                      PlaceField.Types,
                      PlaceField.UTCOffset,
                      PlaceField.Viewport,
                    ]);
                    if (details.place != null && mounted) {
                      if (startFocusNode.hasFocus) {
                        setState(() {
                          startPosition = details.place;
                          _startCtrl.text = details.place!.address!;
                          predictions = [];
                        });
                      } else {
                        setState(() {
                          endPosition = details.place;
                          _endCtrl.text = details.place!.address!;
                          predictions = [];
                        });
                      }
                      if (startPosition != null && endPosition != null) {
                        //to next
                      }
                    }
                  },
                  leading: const CircleAvatar(
                    child: Icon(Icons.pin_drop),
                  ),
                  title: Text(predictions[index].fullText),
                );
              },
              itemCount: predictions.length,
              shrinkWrap: true,
            ),
          ],
        ),
      )),
    );
  }
}
