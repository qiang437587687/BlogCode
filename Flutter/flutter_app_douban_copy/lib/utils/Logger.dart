
import 'package:flutter/foundation.dart';


class Logger {

  static log(String message, Object content) {
    print("\n");
    print("=======" + message + "  start ============>");
    print(content);
    print("<=======" + message + "  end ============");
    print("\n");
  }

}

