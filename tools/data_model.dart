import 'dart:io';

class DataModel {
  final String id;
  final String moduleId;
  final String path;
  final bool usePartFile;
  final bool generateMoreClasses;

  String get filename => 'data_module${moduleId}_model$id.dart';

  DataModel({
    required this.id,
    required this.moduleId,
    required String rootPath,
    required this.usePartFile,
    required this.generateMoreClasses,
  }) : path = '$rootPath/data';

  Future<void> generate() async {
    File dataFile = File('$path/$filename');
    await dataFile.create(recursive: true);
    await dataFile.writeAsString('''
${usePartFile ? "part of '../ui/widget_module${moduleId}_ui$id.dart';" : ''}

${generateMoreClasses ? '''
class Module${moduleId}Model${id}DataSource {
  Module${moduleId}Model$id getData() {
    return Module${moduleId}Model$id('$id');
  }
}

class Module${moduleId}Model$id {
  final String id;

  Module${moduleId}Model$id(this.id);

  @override
  String toString() => 'Module model $id';
}
''' : ''}
final String module${moduleId}String$id = "$moduleId$id";
''');
  }
}
