import 'dart:io';

import 'package:another_dashed_container/another_dashed_container.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:track_image/models/display_model.dart';
import 'package:track_image/services/tracker_service.dart';
import 'package:track_image/widgets/image_widget.dart';
import 'package:track_image/widgets/result_widget.dart';

class TrackMeterPage extends StatefulWidget {
  final String featureTitle;
  final String featurePrompt;
  final IconData featureIcon;

  const TrackMeterPage({
    super.key,
    required this.featureTitle,
    required this.featurePrompt,
    required this.featureIcon,
  });

  @override
  State<TrackMeterPage> createState() => _TrackMeterPageState();
}

class _TrackMeterPageState extends State<TrackMeterPage> {
  ImagePicker picker = ImagePicker();
  TrackerService trackerService = TrackerService();
  File? imageFile;
  String? orientationImage;
  int? durationProcess;

  bool isLoading = false;

  DisplayModel? result;

  void pickImageFromGallery() async {
    imageFile = null;
    result = null;
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final orientation = await trackerService.getImageOrientation(
        File(picked.path),
      );
      print("Orientation: $orientation");
      setState(() {
        imageFile = File(picked.path);
        orientationImage = orientation;
      });
    }
  }

  void pickImageFromCamera() async {
    imageFile = null;
    result = null;
    final XFile? picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      final orientation = await trackerService.getImageOrientation(
        File(picked.path),
      );
      print("Orientation: $orientation");
      setState(() {
        imageFile = File(picked.path);
        orientationImage = orientation;
      });
    }
  }

  void handleAPICall() async {
    setState(() {
      isLoading = true;
    });
    final startTime = DateTime.now();
    int duration = 0;
    try {
      // Kirim prompt sesuai fitur yang dipilih
      result = await trackerService.askOpenAI(
        imageFile!,
        customPrompt: widget.featurePrompt,
      );
      final endTime = DateTime.now();

      duration = endTime.difference(startTime).inSeconds;
      print("==============");
      print("Hasil API: $result");
    } catch (e) {
      print("terjadi error: $e");
    } finally {
      setState(() {
        durationProcess = duration;
        isLoading = false;
      });
    }
  }

  Future<ImageSource?> showImagePicker(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Text("Pilih sumber gambar", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Kamera"),
                onTap: () {
                  pickImageFromCamera();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Galeri"),
                onTap: () {
                  pickImageFromGallery();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 60),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f9fb),
      appBar: AppBar(
        backgroundColor: Color(0xff10bddc),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.featureTitle,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff10bddc), Color(0xff2fd5f2)],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    SizedBox(height: 30),
                    // Icon feature yang dipilih
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xff10bddc), Color(0xff2fd5f2)],
                        ),
                      ),
                      child: Icon(
                        widget.featureIcon,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      widget.featureTitle,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Upload your image for instant tracking',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                if (imageFile == null)
                  Container(
                    height: 500,
                    child: GestureDetector(
                      onTap: () {
                        showImagePicker(context);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 50,
                          right: 50,
                          bottom: 50,
                          top: 50,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xff2fd5f2).withAlpha(30),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: DashedContainer(
                          borderRadius: 10,
                          dashColor: Colors.grey,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xffe6f7fa),
                                  ),
                                  child: Icon(
                                    Icons.image_outlined,
                                    color: Color(0xff10bddc),
                                    size: 32,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  "Select an image",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Tap to choose image',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (imageFile != null)
                  Column(
                    children: [
                      ImageWidget(
                        imageFile: imageFile,
                        orientation: orientationImage ?? "square",
                      ),
                      SizedBox(height: 20),
                      if (isLoading) CircularProgressIndicator(),
                      if (!isLoading)
                        if (result != null)
                          ResultWidget(
                            meterNumber: result?.resultText.toString() ?? "-",
                            inputToken: result?.inputTokens.toString() ?? "-",
                            outputToken: result?.outputTokens.toString() ?? "-",
                            priceIDR:
                                result?.costIdr.toStringAsFixed(2).toString() ??
                                    "-",
                            priceDollar:
                                result?.costUsd.toStringAsFixed(6).toString() ??
                                    "-",
                            onReset: () {
                              setState(() {
                                showImagePicker(context);
                              });
                            },
                            duration: durationProcess ?? 0,
                            totalToken: result?.totalTokens.toString() ?? "-",
                          )
                        else
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 50,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          handleAPICall();
                                        },
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xff10bddc),
                                                Color(0xff2fd5f2),
                                              ],
                                            ),
                                          ),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.play_arrow_rounded,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  'Process',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 50,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            imageFile = null;
                                          });
                                        },
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                offset: Offset(0, 0),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                    ],
                  ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}