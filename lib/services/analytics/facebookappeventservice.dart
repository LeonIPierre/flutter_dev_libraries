import 'package:dev_libraries/services/analytics/analyticsservice.dart';

//https://developers.facebook.com/docs/app-events/best-practices/ecom-and-retail
class FacebookAppEventService extends AnalyticsService{
  //final facebookAppEvents = FacebookAppEvents();

  @override
  void send(String event, Map<String, dynamic> parameters) async {
    //pick out a valueToSum item
    //await facebookAppEvents.logEvent(name: event, parameters: parameters);
  }

  @override
  activate() async => {};
}
