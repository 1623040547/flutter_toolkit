import 'dart:io';
import 'package:analyzer_x/application/gitAnalyzer.dart';
import 'package:analyzer_x/base/analyzer.dart';
import 'package:dart_style/dart_style.dart';
import 'package:analyzer_x/base/base.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart';
import '../../getter/imageClassGetter.dart';
import '../../path/package.dart';

class ImageHandler {
  final String resourcePath;

  ///会将新增文件加入次文件夹，没有则创建此文件夹
  String imageBasePathName = 'imageBasePath';
  String imageBasePath = 'lib/resources/images';

  ///会将生成索引放进ImageNames类，判断项目中该类是否存在，没有则会创建 'lib/images.dart'文件
  String imageClassName = 'ImageNames';

  ImageHandler(this.resourcePath);

  bool isValid = true;

  start() async {
    DartFile? target;
    ImageClassGetter? targetGetter;

    ///判断类[ImageNames]是否存在,不存在则创建
    for (var file in getDartFiles()) {
      ImageClassGetter getter = ImageClassGetter(
          className: imageClassName,
          variableName: imageBasePathName,
          variableValue: imageBasePath);
      MainAnalyzer(
        getters: [getter],
        filePath: file.filePath,
      );
      if (getter.matchClassName) {
        target = file;
        targetGetter = getter;
        break;
      }
    }

    final String baseNameDefine =
        "static const String  $imageBasePathName = '$imageBasePath';";
    if (target == null || targetGetter == null) {
      String tarFile =
          '${PackageConfig.projPath}${Platform.pathSeparator}lib/images.dart';
      File tmp = File(tarFile);
      tmp.createSync(recursive: true);
      tmp.writeAsStringSync("""
        class $imageClassName  {
          $baseNameDefine
        }
        """);
      start();
      return;
    }

    if (!targetGetter.matchVariableName) {
      String proto = File(target.filePath).readAsStringSync();
      proto = proto.substring(0, targetGetter.offsetEnd) +
          baseNameDefine +
          proto.substring(targetGetter.offsetEnd);
      File(target.filePath).writeAsStringSync(proto);
      start();
      return;
    }

    if (!targetGetter.matchVariableValue) {
      imageBasePathName += '_';
      start();
      return;
    }

    ///获取指定文件夹下的所有图片数据，根据图片名称是否带有[@2x]或[@3x]后缀，
    ///将图片划分至3中尺寸的组别中
    List<ImageSource> sources = await _getImageSource(resourcePath);

    ///判断资源文件夹是否存在，不存在则创建
    String assetPath =
        PackageConfig.projPath + Platform.pathSeparator + imageBasePath;
    Directory resource = Directory(assetPath);
    if (!resource.existsSync()) {
      resource.createSync(recursive: true);
      Directory('$assetPath${Platform.pathSeparator}2.0x').createSync();
      Directory('$assetPath${Platform.pathSeparator}3.0x').createSync();
    }
    List<ImageSource> assetSource = await _getImageSource(assetPath);

    sources.removeWhere((e) => assetSource.where(
          (e2) {
            if (e.imageName == e2.imageName) {
              analyzerLog('Duplicate Image ${e2.imageName}');
              isValid = false;
            }
            return e.imageName == e2.imageName;
          },
        ).isNotEmpty);

    ///构造1-3倍图
    for (var e in sources) {
      ///是否进行压缩待考虑
      // e.compress();
      e.shrinkImage();
      isValid &= e.checkValid();
    }
    analyzerLog("CHECK VALID: $isValid");
    assert(isValid);

    ///开始增加索引
    String sourceIndex = '';

    DartFormatter formatter = DartFormatter(indent: 0);
    String proto = File(target.filePath).readAsStringSync();
    proto = formatter.format(proto);
    for (var e in sources) {
      String slice =
          """static const String ${e.imageName} = '\$$imageBasePathName/${e.imageName}.${e.tailFix}';""";
      if (!proto.contains(slice)) {
        sourceIndex += slice;
      }
    }
    proto = proto.substring(0, targetGetter.offsetEnd) +
        sourceIndex +
        proto.substring(targetGetter.offsetEnd);

    proto = formatter.format(proto);
    File(target.filePath).writeAsStringSync(proto);

    ///开始加入照片
    String assetPathX1 = assetPath + Platform.pathSeparator;
    String assetPathX2 =
        '$assetPathX1${Platform.pathSeparator}2.0x${Platform.pathSeparator}';
    String assetPathX3 =
        '$assetPathX1${Platform.pathSeparator}3.0x${Platform.pathSeparator}';
    for (var e in sources) {
      if (e.imageX1 != null) {
        File(e.imageX1!.path)
            .copySync(assetPathX1 + e.fullImageName)
            .createSync();
        GitAnalyzer.instance.addNewFiles([assetPathX1 + e.fullImageName]);
      }
      if (e.imageX2 != null) {
        File(e.imageX2!.path)
            .copySync(assetPathX2 + e.fullImageName)
            .createSync();
        GitAnalyzer.instance.addNewFiles([assetPathX2 + e.fullImageName]);
      }

      if (e.imageX3 != null) {
        File(e.imageX3!.path)
            .copySync(assetPathX3 + e.fullImageName)
            .createSync();
        GitAnalyzer.instance.addNewFiles([assetPathX3 + e.fullImageName]);
      }
    }
  }

  Future<List<ImageSource>> _getImageSource(String filePath) async {
    List<FileSystemEntity> f = Directory(filePath).listSync(recursive: true);
    f.removeWhere((e) => !File(e.path).existsSync());
    List<File> files = f.map((e) => File(e.path)).toList();

    analyzerLog('getImageSource: ${files.length} from $filePath');

    Map<String, ImageSource> sourceMap = {};
    for (var file in files) {
      if (ImageSource.isImage(file.path)) {
        String imageName = file.uri.imageName;

        ///忽略隐藏文件
        if (file.uri.pathSegments.last.startsWith('.')) {
          continue;
        }
        String tailFix = file.uri.imageType;
        if (sourceMap.containsKey(imageName) &&
            sourceMap[imageName]!.tailFix == tailFix) {
          sourceMap[imageName]!.imageX1 =
              file.uri.isX1 ? file : sourceMap[imageName]!.imageX1;
          sourceMap[imageName]!.imageX2 =
              file.uri.isX2 ? file : sourceMap[imageName]!.imageX2;
          sourceMap[imageName]!.imageX3 =
              file.uri.isX3 ? file : sourceMap[imageName]!.imageX3;
        } else {
          sourceMap[imageName] = ImageSource(
            imageName: imageName,
            tailFix: tailFix,
            imageX1: file.uri.isX1 ? file : null,
            imageX2: file.uri.isX2 ? file : null,
            imageX3: file.uri.isX3 ? file : null,
          );
        }
      }
    }
    analyzerLog('getImageSource ${files.length}');
    return sourceMap.values.toList();
  }
}

class ImageSource {
  String imageName = '';
  String tailFix = '';
  File? imageX1;
  File? imageX2;
  File? imageX3;

  ImageSource({
    required this.imageName,
    required this.tailFix,
    this.imageX1,
    this.imageX2,
    this.imageX3,
  });

  bool get allImage => imageX1 != null && imageX2 != null && imageX3 != null;

  ///图片缩放
  void shrinkImage() {
    File? img = imageX3 ?? imageX2 ?? imageX1;
    if (allImage || img == null) {
      return;
    }
    String dir = img.parent.path + Platform.pathSeparator;

    ///重命名3倍图
    imageX3 = img.renameSync('$dir$imageName@3x.$tailFix');
    Image? image3x = decodeImage(imageX3!.readAsBytesSync());
    analyzerLog('Set x3 image from ${img.parent.path}');

    ///获取2倍图
    Image image2x = copyResize(image3x!,
        width: image3x.width ~/ 1.5, height: image3x.height ~/ 1.5);
    imageX2 = File('$dir$imageName@2x.$tailFix');
    imageX2!
        .writeAsBytesSync(encodeNamedImage(imageX2!.path, image2x)!.toList());
    analyzerLog('Get x2 image from $imageName');

    ///获取1倍图
    Image image1x = copyResize(image3x,
        width: image3x.width ~/ 3, height: image3x.height ~/ 3);
    imageX1 = File('$dir$imageName.$tailFix');
    imageX1!
        .writeAsBytesSync(encodeNamedImage(imageX1!.path, image1x)!.toList());
    analyzerLog('Get x1 image from $imageName');
  }

  ///检查命名合法性
  bool checkValid() {
    try {
      DartFormatter formatter = DartFormatter(indent: 0);
      formatter.format("""const String $imageName = '$imageName.$tailFix'; """);
      return true;
    } catch (e) {
      if (imageName.startsWith('i_')) {
        imageName = 'i_${DateTime.now().millisecondsSinceEpoch}';
        return false;
      }
      analyzerLog('Invalid name $imageName');
      imageName = 'i_$imageName';
      return false;
    }
  }

  ///图片压缩
  void compress() {
    if (imageX1 != null) {
      _compress(imageX1!);
    }
    if (imageX2 != null) {
      _compress(imageX2!);
    }
    if (imageX3 != null) {
      _compress(imageX3!);
    }
  }

  Future<void> _compress(File file) async {
    int sizeKB = file.lengthSync() ~/ 1024;
    if (sizeKB < 200 * 1024) {
      return;
    }
    int quality = 100;
    switch (sizeKB) {
      case > 4 * 1024:
        quality = 50;
        break;
      case > 2 * 1024:
        quality = 60;
        break;
      case > 1 * 1024:
        quality = 70;
      case > 512:
        quality = 80;
      case > 256:
        quality = 90;
    }

    CompressFormat? format;
    switch (tailFix) {
      case 'heic':
        format = CompressFormat.heic;
        break;
      case 'jpeg':
        format = CompressFormat.jpeg;
        break;
      case 'webp':
        format = CompressFormat.webp;
        break;
      case 'png':
        format = CompressFormat.png;
        break;
    }
    if (format != null) {
      File? result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        file.path,
        quality: quality,
        format: format,
      );
      analyzerLog(
          'Compress $imageName $sizeKB -> ${(result?.lengthSync() ?? 0) ~/ 1024}');
    } else {
      analyzerLog('No such compress type: $tailFix');
    }
  }

  String get fullImageName => '$imageName.$tailFix';

  static bool isImage(String filePath) =>
      ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(
        Uri.parse(filePath).pathSegments.last.split('.').last,
      );
}

extension _ImageNameString on Uri {
  String get imageName => pathSegments.last.split('.').first.split('@').first;

  String get imageType => pathSegments.last.split('.').last;

  bool get isX1 => !isX2 && !isX3;

  bool get isX2 =>
      pathSegments.contains('2.0x') ||
      pathSegments.last.toLowerCase().contains('@2x');

  bool get isX3 =>
      pathSegments.contains('3.0x') ||
      pathSegments.last.toLowerCase().contains('@3x');
}
