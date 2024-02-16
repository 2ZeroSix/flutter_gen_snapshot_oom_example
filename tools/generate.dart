import 'dart:io';

import 'module.dart';


void main(List<String> args) async {
  final dir = Directory.current;
  final rootPath = '${dir.path}/modules';

  const usePartFile = false;
  const useTickerProviderMixin = true;
  const generateMoreClasses = true;
  const numberOfModules = 20;
  const itemsInModule = 1000;

  final List<Module> modules = [
    for (int i = 0; i < numberOfModules; ++i)
      Module(
        id: '$i',
        itemsInModule: itemsInModule,
        rootPath: rootPath,
        usePartFile: usePartFile,
        useTickerProviderMixin: useTickerProviderMixin,
        generateMoreClasses: generateMoreClasses,
      ),
  ];

  for (var moduleIndex = 0; moduleIndex < modules.length; moduleIndex++) {
    final module = modules[moduleIndex];
    await module.generate();
    print('Generated $moduleIndex / ${modules.length}');
  }

  linkModules(modules, rootPath, dir.path);
}

void linkModules(
    List<Module> modules, String modulesRootPath, String rootPath) {
  final homePage = File('$rootPath/lib/home_page.dart');
  final pubspecOverrides = File('$rootPath/pubspec_overrides.yaml');

  homePage.createSync(recursive: true);
  pubspecOverrides.createSync(recursive: true);

  homePage.writeAsStringSync('''import 'package:flutter/material.dart';

${modules.map((module) => "import 'package:module${module.id}/module${module.id}.dart';").join('\n')}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final List<Widget> modules = [
    ${modules.map((module) => '${module.moduleEntry},').join('\n')}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemBuilder: (ctx, index) => modules[index],
        itemCount: modules.length,
      ),
    );
  }
}
''');

  pubspecOverrides.writeAsStringSync('''dependency_overrides:
${modules.map((module) => '''
  module${module.id}:
    path: modules/module${module.id}''').join('\n')}
''');
}
