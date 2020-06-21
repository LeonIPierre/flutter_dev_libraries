import 'adservice.dart';

class Node<T> {
  final T value;
  Node<T> left, right;
  Node(this.value, {this.left, this.right});

  Node<T> move(int steps, [Node<T> node]) {
    node = node ?? this;

    if(steps == 0) {
      return node;
    }
    
    if(steps > 0)
    {
      if(node.right != null)
        return move(steps -1, node.right);
      else
        return node;
    }
    else
    {
      if(node.left != null)
        return move(steps +1, node.left);
      else
        return node;
    }
  }
}

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