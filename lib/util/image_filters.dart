import 'dart:ui';

class ImageFilters {

  static const neutral = ColorFilter.matrix(<double>[
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  static const greyscale = ColorFilter.matrix(<double>[
    /// matrix
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0
  ]);

  static const sepia = ColorFilter.matrix(<double>[
    /// matrix
    0.393, 0.769, 0.189, 0, 0,
    0.349, 0.686, 0.168, 0, 0,
    0.272, 0.534, 0.131, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  static const invert = ColorFilter.matrix(<double>[
    /// matrix
    -1, 0, 0, 0, 255,
    0, -1, 0, 0, 255,
    0, 0, -1, 0, 255,
    0, 0, 0, 1, 0,
  ]);

  static const vintage = ColorFilter.matrix(<double>[
    /// matrix
    0.9, 0.5, 0.1, 0.0, 0.0,
    0.3, 0.8, 0.1, 0.0, 0.0,
    0.2, 0.3, 0.5, 0.0, 0.0,
    0.0, 0.0, 0.0, 1.0, 0.0
  ]);

  static const warmer = ColorFilter.matrix(<double>[
    1.2, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 0.8, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  static const cooler = ColorFilter.matrix(<double>[
    0.8, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1.2, 0, 0,
    0, 0, 0, 1, 0,
  ]);

}