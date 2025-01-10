abstract class ValueObject<T> {
  final T value;
  const ValueObject(this.value);

  @override
  String toString() => value.toString();

  bool isValid();
}
