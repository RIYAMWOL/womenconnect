import 'dart:io';
import 'package:cloudinary/cloudinary.dart';

Future<String?> uploadImageToCloudinary(String filePath) async {
  final cloudinary = Cloudinary.signedConfig(
    apiKey: "754575599237621",
    apiSecret: "o7DQ_5z8pEOxtloQBBznPDw3YJk",
    cloudName: "dqaitmb01",
  );

  final response = await cloudinary.upload(
    file: filePath,
    resourceType: CloudinaryResourceType.image,
    folder: "flutter_uploads", // Optional: Cloudinary folder name
  );

  return response.secureUrl; // Returns the uploaded image URL
}