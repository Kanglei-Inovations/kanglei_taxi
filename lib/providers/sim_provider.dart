import 'package:mobile_number/mobile_number.dart';

class SimProvider {
  Future<List<String?>?> initMobileNumberState() async {
    List<String?> simNumbers = [];

    // Check if the device has phone permission
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
      return null; // Return null if permission is not granted
    }

    // Get all SIM numbers
    List<SimCard>? simCards = await MobileNumber.getSimCards;

    // Check if there are any SIM cards available
    if (simCards!.isNotEmpty) {
      // Iterate over each SIM card and add its number to the list
      for (SimCard simCard in simCards) {
        simNumbers.add(simCard.number);
      }
    }

    return simNumbers; // Return the list of SIM numbers
  }
}
