import 'dart:io';

void main() {
  var dir = Directory('.');
  var files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  var pattern = RegExp(
    r"PageRouteBuilder\(\s*pageBuilder:\s*\([^)]*\)\s*=>\s*(.*?),\s*transitionsBuilder:\s*\([\s\S]*?SlideTransition\(\s*position:\s*offsetAnimation,\s*child:\s*child,\s*\);\s*},\s*\)",
    multiLine: true,
  );

  for (var file in files) {
    if (file.path.contains('refactor.dart')) continue;
    
    var content = file.readAsStringSync();
    
    if (content.contains('PageRouteBuilder')) {
      var newContent = content.replaceAllMapped(pattern, (match) {
        var pageCode = match.group(1);
        return "SmoothSlidePageRoute(\n  page: $pageCode,\n)";
      });
      
      // Also inject import if we replaced something
      if (newContent != content) {
        if (!newContent.contains('smooth_slide_page_route.dart')) {
          newContent = "import 'package:repair_cms/core/routes/smooth_slide_page_route.dart';\n" + newContent;
        }
        file.writeAsStringSync(newContent);
        print('Updated \${file.path}');
      }
    }
  }
}
