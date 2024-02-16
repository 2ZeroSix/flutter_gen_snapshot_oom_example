import 'dart:io';

import 'data_model.dart';
import 'ui_item.dart';

class Module {
  final String id;
  final String path;
  final int itemsInModule;
  final bool usePartFile;
  final bool useTickerProviderMixin;
  final bool generateMoreClasses;

  late final List<UiItem> uiItems;
  late final List<DataModel> dataModels;

  String get moduleEntry => 'Module${id}PageEntry()';

  String get libPath => '$path/lib';

  Module({
    required this.id,
    required this.itemsInModule,
    required String rootPath,
    required this.usePartFile,
    required this.useTickerProviderMixin,
    required this.generateMoreClasses,
  }) : path = '$rootPath/module$id' {
    dataModels = [
      for (int i = 0; i < itemsInModule; ++i)
        DataModel(
          id: '$i',
          moduleId: id,
          rootPath: libPath,
          usePartFile: usePartFile,
          generateMoreClasses: generateMoreClasses,
        ),
    ];
    uiItems = [
      for (int i = 0; i < itemsInModule; ++i)
        UiItem(
          id: '$i',
          moduleId: id,
          model: dataModels[i],
          rootPath: libPath,
          usePartFile: usePartFile,
          useTickerProviderMixin: useTickerProviderMixin,
          generateMoreClasses: generateMoreClasses,
        ),
    ];
  }

  Future<void> generate() async => Future.wait([
        generateYaml(),
        generateData(),
        generateDataExport(),
        generateUi(),
        generateUiExport(),
        generateExport(),
        generateModuleEntry(),
      ]);

  Future<void> generateDataExport() async {
    if (usePartFile) return;
    File export = File('$libPath/data/export.dart');
    await export.create(recursive: true);
    String exportContent = '';
    for (final dataModel in dataModels) {
      exportContent += 'export \'${dataModel.filename}\';\n';
    }
    await export.writeAsString(exportContent);
  }

  Future<void> generateUiExport() async {
    File export = File('$libPath/ui/export.dart');
    await export.create(recursive: true);
    String exportContent = '';
    for (final uiItem in uiItems) {
      exportContent += 'export \'${uiItem.filename}\';\n';
    }
    await export.writeAsString(exportContent);
  }

  Future<void> generateExport() async {
    File export = File('$libPath/export.dart');
    await export.create(recursive: true);
    await export.writeAsString('''
export 'module${id}.dart';
export 'ui/export.dart';
export 'data/export.dart';
''');
  }

  Future<void> generateData() async {
    for (final dataModel in dataModels) {
      await dataModel.generate();
    }
  }

  Future<void> generateUi() async {
    for (final uiItem in uiItems) {
      await uiItem.generate();
    }
  }

  Future<void> generateYaml() async {
    File yaml = File('$path/pubspec.yaml');
    await yaml.create(recursive: true);
    await yaml.writeAsString('''
name: module$id
description: A new Flutter project.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=2.19.2 <3.0.0'
dependencies:
  flutter:
    sdk: flutter
''');
  }

  Future<void> generateModuleEntry() async {
    final moduleEntry = File('$libPath/module${id}.dart');
    await moduleEntry.create(recursive: true);
    await moduleEntry.writeAsString(_modulePageEntryTemplate());
  }

  String _modulePageEntryTemplate() {
    String moduleUiElements = '';
    for (final uiItem in uiItems) {
      moduleUiElements += '${uiItem.uiElement},\n';
    }
//${uiItems.map((item) => 'import \'ui/${item.filename}\';').join('\n')}
    return '''
import 'package:flutter/widgets.dart';
import 'export.dart';


class Module${id}PageEntry extends StatefulWidget {
  const Module${id}PageEntry({super.key});

  @override
  State<Module${id}PageEntry> createState() => _Module${id}PageEntryState();
}

class _Module${id}PageEntryState extends State<Module${id}PageEntry> {
  final List<Widget> moduleWidgets = [
    $moduleUiElements
  ];

  @override
  Widget build(BuildContext context) => ListView.builder(
    itemBuilder: (ctx, index) => moduleWidgets[index],
    itemCount: moduleWidgets.length,
  );
}
''';
  }
}


