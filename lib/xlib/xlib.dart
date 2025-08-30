extension IterableFlatten<E> on Iterable<Iterable<E>>{
  Iterable<E> flatten() => this.expand((Iterable<E> e) => e);
}

extension CyclicIterable<E> on Iterable<E> {
  Iterable<E> sublistCyclic(int offset, int count) => Iterable<Iterable<E>>.generate((offset + count) ~/ this.length + 1, (_) => this).flatten().skip(offset).take(count);
}