part of 'adbloc.dart';

abstract class AdState {
}

class AdIdealState extends AdState {
  final Ad ad;

  AdIdealState(this.ad);
}

class AdFailedState extends AdState {
}

class AdLoadingState extends AdState {
}

class AdStreamingState extends AdState {
  
}