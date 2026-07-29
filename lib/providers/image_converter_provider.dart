import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ImageToBadgeConverter {
  /// Importa un'immagine dalla galleria, la scala a 11x44 e la binarizza.
  /// Restituisce una matrice List<List<bool>> compatibile con DrawBadgeProvider.
  static Future<List<List<bool>>?> pickAndConvertImage({
    int targetRows = 11,
    int targetCols = 44,
    int threshold = 128, // Soglia da 0 a 255 per la binarizzazione
  }) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return null; // L'utente ha annullato la selezione

    final File file = File(pickedFile.path);
    final List<int> imageBytes = await file.readAsBytes();

    // Decodifica l'immagine originale
    img.Image? originalImage = img.decodeImage(Uint8List.fromList(imageBytes));
    if (originalImage == null) return null;

    // 1. Ridimensiona l'immagine a 44x11 pixel (Larghezza x Altezza)
    img.Image resizedImage = img.copyResize(
      originalImage,
      width: targetCols,
      height: targetRows,
      interpolation: img.Interpolation.average,
    );

    // 2. Inizializza la griglia booleana 11x44 (rows x cols)
    List<List<bool>> grid = List.generate(
      targetRows,
          (_) => List.generate(targetCols, (_) => false),
    );

    // 3. Processa ciascun pixel: calcola la luminanza e binarizza
    for (int y = 0; y < targetRows; y++) {
      for (int x = 0; x < targetCols; x++) {
        img.Pixel pixel = resizedImage.getPixel(x, y);

        // Estraggo i canali RGB
        num r = pixel.r;
        num g = pixel.g;
        num b = pixel.b;

        // Calcolo della luminanza percepita (formula standard ITU-R BT.601)
        double luminance = (0.299 * r) + (0.587 * g) + (0.114 * b);

        // Se la luminanza è sotto la soglia -> Pixel Scuro / Nero -> LED Acceso (true / 1)
        // Se sopra la soglia -> Pixel Chiaro / Bianco -> LED Spento (false / 0)
        grid[y][x] = luminance < threshold;
      }
    }

    return grid;
  }
}