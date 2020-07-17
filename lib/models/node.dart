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