import 'package:cloudinary/cloudinary.dart';

Future<String?>  getClodinaryUrl(String image) async {

  final cloudinary = Cloudinary.signedConfig(
    cloudName: ' dqaitmb01',
    apiKey: '	754575599237621',
    apiSecret: 'o7DQ_5z8pEOxtloQBBznPDw3YJk',
  );

   final response = await cloudinary.upload(
        file: image,
        resourceType: CloudinaryResourceType.image,
      );
  return response.secureUrl;
  
} 