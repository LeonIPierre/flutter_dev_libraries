
import 'package:dev_libraries/models/node.dart';
import 'ad.dart';

class AdTypeNode {

  static Node<AdType> bannerNode = Node<AdType>(AdType.Banner);
  static Node<AdType> intersitialNode = Node<AdType>(AdType.Interstitial, left: bannerNode);
  static Node<AdType> intersitialVideoNode = Node<AdType>(AdType.InterstitialVideo, left: intersitialNode);
  static Node<AdType> internalNode = Node<AdType>(AdType.Internal, left: intersitialVideoNode);

  static Node<AdType> init() {
    var banner = Node<AdType>(AdType.Banner);
    var intersitial = Node<AdType>(AdType.Interstitial, left: banner);
    var intersitialVideo = Node<AdType>(AdType.InterstitialVideo, left: intersitial);
    var internal = Node<AdType>(AdType.Internal, left: intersitialVideo);

    banner.right = intersitial;
    intersitial.right = intersitialVideo;
    intersitialVideo.right = internal;

    return banner;
  }
}