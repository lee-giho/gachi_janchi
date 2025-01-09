class ScreenSize {
  static final ScreenSize _instance = ScreenSize._internal();

  factory ScreenSize() {
    return _instance;
  }

  ScreenSize._internal();

  late double width;
  late double height;

  void init({required double width, required double height}) {
    this.width = width;
    this.height = height;
  }
}