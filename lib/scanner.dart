import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

import 'scanner_utils.dart';
import 'encoder.dart';

enum EncryptMode { encode, decode }

class CameraPreviewScanner extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CameraPreviewScannerState();
}

class _CameraPreviewScannerState extends State<CameraPreviewScanner> {
  EncryptMode _mode = EncryptMode.encode;
  dynamic _scanResults;
  CameraController _camera;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.back;

  final TextRecognizer _recognizer = FirebaseVision.instance.textRecognizer();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _camera.dispose().then((_) {
      _recognizer.close();
    });

    super.dispose();
  }

  void _initializeCamera() async {
    final CameraDescription description =
        await ScannerUtils.getCamera(_direction);

    _camera =
        CameraController(description, ResolutionPreset.max, enableAudio: false);
    await _camera.initialize();

    _camera.startImageStream((CameraImage image) {
      if (_isDetecting) {
        return;
      }

      _isDetecting = true;
      ScannerUtils.detect(
        image: image,
        detectInImage: _recognizer.processImage,
        imageRotation: description.sensorOrientation,
      ).then(
        (dynamic results) {
          setState(() {
            _scanResults = results;
          });
        },
      ).whenComplete(() => _isDetecting = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    List _textBlocks = [Container()];
    if (_camera != null) {
      final Size _pageSize = Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height,
      );

      final Size _cameraSize = Size(
        _camera.value.previewSize.height,
        _camera.value.previewSize.width,
      );

      final double _scaleX = _pageSize.width / _cameraSize.width;
      final double _scaleY = _pageSize.height / _cameraSize.height;

      if (_scanResults != null) {
        for (TextBlock block in _scanResults.blocks) {
          _textBlocks.add(Positioned(
              top: block.boundingBox.top * _scaleY,
              left: block.boundingBox.left * _scaleX,
              child: (_mode == EncryptMode.encode)
                  ? GestureDetector(
                      onTap: () => scaffoldKey.currentState.showBottomSheet(
                          (context) => BottomSheetWidget(
                              decodedText: block.text,
                              encodedText: Encoder.encrypt(block.text))),
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(4)),
                        child: Column(
                          children: [
                            PositionedContainer(
                                child: Text(block.text,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                color: Colors.white),
                            PositionedContainer(
                                child: Text(Encoder.encrypt(block.text),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                color: Colors.black),
                          ],
                        ),
                      ))
                  : GestureDetector(
                      onTap: () => scaffoldKey.currentState.showBottomSheet(
                          (context) => BottomSheetWidget(
                              decodedText: block.text,
                              encodedText: Encoder.encrypt(block.text))),
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(4)),
                        child: Column(
                          children: [
                            PositionedContainer(
                                child: Text(block.text,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                color: Colors.black),
                            PositionedContainer(
                                child: Text(Encoder.decrypt(block.text),
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                color: Colors.white),
                          ],
                        ),
                      ))));
        }
      }
    }

    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: (_camera == null)
          ? FloatingActionButton(onPressed: null, backgroundColor: Colors.black)
          : FloatingActionButton(
              onPressed: () => setState(() {
                _mode = (_mode == EncryptMode.encode)
                    ? EncryptMode.decode
                    : EncryptMode.encode;
              }),
              child: _mode == EncryptMode.encode
                  ? Icon(Icons.lock,
                      color: (_mode == EncryptMode.encode)
                          ? Colors.black
                          : Colors.white)
                  : Icon(Icons.lock_open,
                      color: (_mode == EncryptMode.encode)
                          ? Colors.black
                          : Colors.white),
              backgroundColor:
                  (_mode == EncryptMode.encode) ? Colors.white : Colors.black,
            ),
      body: Container(
        color: Colors.black,
        constraints: const BoxConstraints.expand(),
        child: _camera == null
            ? Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              )
            : Stack(
                children: <Widget>[CameraPreview(_camera), ..._textBlocks],
              ),
      ),
    );
  }
}

class PositionedContainer extends StatelessWidget {
  const PositionedContainer({
    Key key,
    @required this.child,
    @required this.color,
  }) : super(key: key);

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        color: color,
        child: child);
  }
}

class BottomSheetWidget extends StatefulWidget {
  final String decodedText;
  final String encodedText;

  const BottomSheetWidget(
      {Key key, @required this.decodedText, @required this.encodedText})
      : super(key: key);

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      color: Colors.black,
      child: Column(
        children: [
          Container(
              height: 80,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(4)),
              child: Text(widget.decodedText,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20))),
          Container(
              height: 80,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(4)),
              child: Text(widget.encodedText,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20))),
        ],
      ),
    );
  }
}
