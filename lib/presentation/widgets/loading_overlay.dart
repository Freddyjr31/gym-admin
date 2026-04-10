
import 'package:fluent_ui/fluent_ui.dart';

class LoadingGradientOverlay extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const LoadingGradientOverlay({super.key, required this.child, required this.isLoading});

  @override
  LoadingGradientOverlayState createState() => LoadingGradientOverlayState();
}

class LoadingGradientOverlayState extends State<LoadingGradientOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isLoading) _controller.repeat();
  }

  @override
  void didUpdateWidget(LoadingGradientOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0), // Ajuste para Fluent UI
            gradient: widget.isLoading
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [
                      _controller.value - 0.3,
                      _controller.value,
                      _controller.value + 0.3,
                    ],
                    colors: [
                      Colors.green.withOpacity(0.1),
                      Colors.green.withOpacity(0.4),
                      Colors.green.withOpacity(0.1),
                    ],
                  )
                : null,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}