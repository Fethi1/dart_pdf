/*
 * Copyright (C) 2017, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

part of widget;

class Anchor extends SingleChildWidget {
  Anchor({Widget child, @required this.name, this.description})
      : assert(name != null),
        super(child: child);

  final String name;

  final String description;

  @override
  void paint(Context context) {
    super.paint(context);
    paintChild(context);

    final Matrix4 mat = context.canvas.getTransform();
    final Vector3 lt = mat.transform3(Vector3(box.left, box.bottom, 0));
    context.document.pdfNames.addDest(name, context.page, posY: lt.y);

    if (description != null) {
      final Vector3 rb = mat.transform3(Vector3(box.right, box.top, 0));
      final PdfRect ibox = PdfRect.fromLTRB(lt.x, lt.y, rb.x, rb.y);
      PdfAnnot.text(context.page, content: description, rect: ibox);
    }
  }
}

abstract class AnnotationBuilder {
  PdfRect localToGlobal(Context context, PdfRect box) {
    final Matrix4 mat = context.canvas.getTransform();
    final Vector3 lt = mat.transform3(Vector3(box.left, box.bottom, 0));
    final Vector3 rb = mat.transform3(Vector3(box.right, box.top, 0));
    return PdfRect.fromLTRB(lt.x, lt.y, rb.x, rb.y);
  }

  void build(Context context, PdfRect box);
}

class AnnotationLink extends AnnotationBuilder {
  AnnotationLink(this.destination) : assert(destination != null);

  final String destination;

  @override
  void build(Context context, PdfRect box) {
    PdfAnnot.namedLink(
      context.page,
      rect: localToGlobal(context, box),
      dest: destination,
    );
  }
}

class AnnotationUrl extends AnnotationBuilder {
  AnnotationUrl(this.destination) : assert(destination != null);

  final String destination;

  @override
  void build(Context context, PdfRect box) {
    PdfAnnot.urlLink(
      context.page,
      rect: localToGlobal(context, box),
      dest: destination,
    );
  }
}

class Annotation extends SingleChildWidget {
  Annotation({Widget child, this.builder}) : super(child: child);

  final AnnotationBuilder builder;

  @override
  void debugPaint(Context context) {
    context.canvas
      ..setFillColor(PdfColors.pink)
      ..drawRect(box.x, box.y, box.width, box.height)
      ..fillPath();
  }

  @override
  void paint(Context context) {
    super.paint(context);
    paintChild(context);
    builder?.build(context, box);
  }
}

class Link extends Annotation {
  Link({@required Widget child, String destination})
      : assert(child != null),
        super(child: child, builder: AnnotationLink(destination));
}

class UrlLink extends Annotation {
  UrlLink({@required Widget child, String destination})
      : assert(child != null),
        super(child: child, builder: AnnotationUrl(destination));
}
