import 'dart:ui';

import 'package:carrinhodesupermercado/scanner/src/enums/torch_state.dart';

/// This class defines the attributes for the mobile scanner view.
class MobileScannerViewAttributes {
  /// Construct a new [MobileScannerViewAttributes] instance.
  const MobileScannerViewAttributes({
    required this.currentTorchMode,
    this.numberOfCameras,
    required this.size,
  });

  /// The current torch state of the active camera.
  final TorchState currentTorchMode;

  /// The number of available cameras.
  final int? numberOfCameras;

  /// The size of the camera output.
  final Size size;
}
