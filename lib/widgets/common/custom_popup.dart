import 'package:flutter/material.dart';

enum PopupPosition { top, bottom, left, right }

class CustomPopup extends StatefulWidget {
  final Widget child;
  final Widget content;
  final PopupPosition position;
  final Color backgroundColor;
  final Color? arrowColor;
  final Color barrierColor;
  final bool showArrow;
  final double arrowSize;
  final EdgeInsets contentPadding;
  final BorderRadius? contentBorderRadius;
  final BoxDecoration? contentDecoration;
  final Duration animationDuration;
  final Curve animationCurve;
  final double? contentWidth;
  final double? contentHeight;
  final VoidCallback? onShow;
  final VoidCallback? onDismiss;
  final Alignment? alignment;
  final Offset? offset;
  final bool enabled;

  const CustomPopup({
    super.key,
    required this.child,
    required this.content,
    this.position = PopupPosition.bottom,
    this.backgroundColor = Colors.white,
    this.arrowColor,
    this.barrierColor = Colors.transparent,
    this.showArrow = true,
    this.arrowSize = 10,
    this.contentPadding = const EdgeInsets.all(12),
    this.contentBorderRadius,
    this.contentDecoration,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.contentWidth,
    this.contentHeight,
    this.onShow,
    this.onDismiss,
    this.alignment,
    this.offset,
    this.enabled = true,
  });

  @override
  State<CustomPopup> createState() => CustomPopupState();
}

class CustomPopupState extends State<CustomPopup> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  void show() {
    if (_overlayEntry != null || !widget.enabled) return;

    widget.onShow?.call();

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void dismiss() {
    if (_overlayEntry == null) return;

    widget.onDismiss?.call();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void toggle() {
    if (!widget.enabled) return;

    if (_overlayEntry != null) {
      dismiss();
    } else {
      show();
    }
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => _PopupContent(
        layerLink: _layerLink,
        position: widget.position,
        backgroundColor: widget.backgroundColor,
        arrowColor: widget.arrowColor ?? widget.backgroundColor,
        barrierColor: widget.barrierColor,
        showArrow: widget.showArrow,
        arrowSize: widget.arrowSize,
        contentPadding: widget.contentPadding,
        contentBorderRadius: widget.contentBorderRadius,
        contentDecoration: widget.contentDecoration,
        animationDuration: widget.animationDuration,
        animationCurve: widget.animationCurve,
        contentWidth: widget.contentWidth,
        contentHeight: widget.contentHeight,
        alignment: widget.alignment,
        offset: widget.offset,
        onDismiss: dismiss,
        child: widget.content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(onTap: toggle, child: widget.child),
    );
  }

  @override
  void dispose() {
    dismiss();
    super.dispose();
  }
}

class _PopupContent extends StatefulWidget {
  final LayerLink layerLink;
  final PopupPosition position;
  final Color backgroundColor;
  final Color arrowColor;
  final Color barrierColor;
  final bool showArrow;
  final double arrowSize;
  final EdgeInsets contentPadding;
  final BorderRadius? contentBorderRadius;
  final BoxDecoration? contentDecoration;
  final Duration animationDuration;
  final Curve animationCurve;
  final double? contentWidth;
  final double? contentHeight;
  final VoidCallback onDismiss;
  final Widget child;
  final Alignment? alignment;
  final Offset? offset;

  const _PopupContent({
    required this.layerLink,
    required this.position,
    required this.backgroundColor,
    required this.arrowColor,
    required this.barrierColor,
    required this.showArrow,
    required this.arrowSize,
    required this.contentPadding,
    required this.contentBorderRadius,
    required this.contentDecoration,
    required this.animationDuration,
    required this.animationCurve,
    required this.contentWidth,
    required this.contentHeight,
    required this.onDismiss,
    required this.child,
    this.alignment,
    this.offset,
  });

  @override
  State<_PopupContent> createState() => _PopupContentState();
}

class _PopupContentState extends State<_PopupContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.animationCurve),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.animationCurve),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  Alignment _getChildAnchor() {
    if (widget.alignment != null) {
      // For custom alignment, use it as the follower anchor
      return widget.alignment!;
    }
    switch (widget.position) {
      case PopupPosition.bottom:
        return Alignment.topCenter;
      case PopupPosition.top:
        return Alignment.bottomCenter;
      case PopupPosition.left:
        return Alignment.centerRight;
      case PopupPosition.right:
        return Alignment.centerLeft;
    }
  }

  Alignment _getTargetAnchor() {
    if (widget.alignment != null) {
      // For custom alignment, use specific mappings
      // For bottom position with topLeft follower, attach to topLeft target
      if (widget.position == PopupPosition.bottom &&
          widget.alignment == Alignment.topLeft) {
        return Alignment.topLeft;
      }
      // For top position alignments
      if (widget.alignment == Alignment.topLeft) {
        return Alignment.bottomLeft;
      } else if (widget.alignment == Alignment.topRight) {
        return Alignment.bottomRight;
      } else if (widget.alignment == Alignment.topCenter) {
        return Alignment.bottomCenter;
      } else if (widget.alignment == Alignment.bottomLeft) {
        return Alignment.topLeft;
      } else if (widget.alignment == Alignment.bottomRight) {
        return Alignment.topRight;
      } else if (widget.alignment == Alignment.bottomCenter) {
        return Alignment.topCenter;
      }
      return widget.alignment!;
    }
    switch (widget.position) {
      case PopupPosition.bottom:
        return Alignment.bottomCenter;
      case PopupPosition.top:
        return Alignment.topCenter;
      case PopupPosition.left:
        return Alignment.centerLeft;
      case PopupPosition.right:
        return Alignment.centerRight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismiss,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: widget.barrierColor,
        child: Stack(
          children: [
            CompositedTransformFollower(
              link: widget.layerLink,
              targetAnchor: _getTargetAnchor(),
              followerAnchor: _getChildAnchor(),
              offset: widget.offset ?? Offset.zero,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: () {}, // Prevent dismissing when tapping on content
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.showArrow &&
                            widget.position == PopupPosition.top)
                          _buildArrow(isTop: false),
                        Container(
                          width: widget.contentWidth,
                          height: widget.contentHeight,
                          padding: widget.contentPadding,
                          decoration:
                              widget.contentDecoration ??
                              BoxDecoration(
                                color: widget.backgroundColor,
                                borderRadius:
                                    widget.contentBorderRadius ??
                                    BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                          child: widget.child,
                        ),
                        if (widget.showArrow &&
                            widget.position == PopupPosition.bottom)
                          _buildArrow(isTop: true),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrow({required bool isTop}) {
    return CustomPaint(
      size: Size(widget.arrowSize * 2, widget.arrowSize),
      painter: _ArrowPainter(color: widget.arrowColor, isTop: isTop),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  final bool isTop;

  _ArrowPainter({required this.color, required this.isTop});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (isTop) {
      // Arrow pointing up
      path.moveTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    } else {
      // Arrow pointing down
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width / 2, size.height);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
