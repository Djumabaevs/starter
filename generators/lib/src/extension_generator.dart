// 1
import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import 'package:annotations/annotations.dart';

import 'model_visitor.dart';

// 2
class ExtensionGenerator extends GeneratorForAnnotation<ExtensionAnnotation> {
  // 3
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    // 4
    final visitor = ModelVisitor();
    element.visitChildren(visitor);

    final classBuffer = StringBuffer();

    // 5
    classBuffer.writeln('extension GeneratedModel on ${visitor.className} {');
    // EX: extension GeneratedModel on Model {

    // 6
    classBuffer.writeln('Map<String, dynamic> get variables => {');

    // 7
    for (final field in visitor.fields.keys) {
      final variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;

      classBuffer.writeln("'$variable': $field,"); // EX: 'name': _name,
    }

    // 8
    classBuffer.writeln('};');

    // 9
    generateGettersAndSetters(visitor, classBuffer);

    // 10
    classBuffer.writeln('}');

    // 11
    return classBuffer.toString();
  }

  void generateGettersAndSetters(
      ModelVisitor visitor, StringBuffer classBuffer) {
// 1
    for (final field in visitor.fields.keys) {
      // 2
      final variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;

      // 3 getter
      classBuffer.writeln(
          "${visitor.fields[field]} get $variable => variables['$variable'];");
      // EX: String get name => variables['name'];

      // 4 setter
      classBuffer.writeln('set $variable(${visitor.fields[field]} $variable)');
      classBuffer.writeln('=> $field = $variable;');
      // EX: set name(String name) => _name = name;
    }
  }
}
