abstract class AnalyticsService {
  activate();
  send(String event, Map<String, dynamic> parameters);
}