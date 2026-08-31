/// 轻量 `Result<T, E>`，用于 repo 层返回成功/失败。
sealed class Result<T, E> {
  const Result();

  bool get isOk => this is Ok<T, E>;
  bool get isErr => this is Err<T, E>;

  R when<R>({required R Function(T value) ok, required R Function(E error) err}) {
    final self = this;
    if (self is Ok<T, E>) return ok(self.value);
    if (self is Err<T, E>) return err(self.error);
    throw StateError('unreachable');
  }
}

final class Ok<T, E> extends Result<T, E> {
  const Ok(this.value);
  final T value;
}

final class Err<T, E> extends Result<T, E> {
  const Err(this.error);
  final E error;
}