import 'dart:io';

import 'data_model.dart';

class UiItem {
  final String id;
  final String moduleId;
  final DataModel model;
  final bool usePartFile;
  final bool useTickerProviderMixin;
  final bool generateMoreClasses;
  late final String path;

  String get filename => 'widget_module${moduleId}_ui$id.dart';
  String get uiElement => 'Module${moduleId}UiItem$id()';

  UiItem({
    required this.id,
    required this.moduleId,
    required this.model,
    required String rootPath,
    required this.usePartFile,
    required this.useTickerProviderMixin,
    required this.generateMoreClasses,
  }) {
    path = '$rootPath/ui';
  }

  Future<void> generate() async {
    File uiFile = File('$path/$filename');
    await uiFile.create(recursive: true);
    await uiFile.writeAsString('''
import 'package:flutter/widgets.dart';
${usePartFile ? 'part' : 'import'} '../data/data_module${moduleId}_model${model.id}.dart';

class Module${moduleId}UiItem$id extends StatefulWidget {
  const Module${moduleId}UiItem$id({super.key});

  @override
  State<Module${moduleId}UiItem$id> createState() => _Module${moduleId}UiItem${id}State();
}

class _Module${moduleId}UiItem${id}State extends State<Module${moduleId}UiItem$id>
  ${useTickerProviderMixin ? 'with TickerProviderStateMixin' : ''} {

  @override
  Widget build(BuildContext context) => Text(
    module${moduleId}String${model.id} ${generateMoreClasses ? '+ Module${moduleId}Model${model.id}DataSource().getData().toString()' : ''},
  );
}
''');
  }
}
