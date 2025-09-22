import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final Color? badgeColor;
  final Color? textColor;
  final bool showPulse;

  const NotificationBadge({
    super.key,
    required this.child,
    required this.count,
    this.badgeColor,
    this.textColor,
    this.showPulse = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: _buildBadge(context),
          ),
      ],
    );
  }

  Widget _buildBadge(BuildContext context) {
    final isHighCount = count > 9;
    final badgeSize = isHighCount ? 20.0 : 18.0;
    final fontSize = isHighCount ? 9.0 : 10.0;
    
    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            badgeColor ?? const Color(0xFFFF3B30),
            badgeColor?.withValues(alpha: 0.8) ?? const Color(0xFFE53E3E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(badgeSize / 2),
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (badgeColor ?? const Color(0xFFFF3B30)).withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            height: 1,
            letterSpacing: -0.2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Modern notification badge with pulse animation
class AnimatedNotificationBadge extends StatefulWidget {
  final Widget child;
  final int count;
  final Color? badgeColor;
  final Color? textColor;
  final bool showPulse;

  const AnimatedNotificationBadge({
    super.key,
    required this.child,
    required this.count,
    this.badgeColor,
    this.textColor,
    this.showPulse = true,
  });

  @override
  State<AnimatedNotificationBadge> createState() => _AnimatedNotificationBadgeState();
}

class _AnimatedNotificationBadgeState extends State<AnimatedNotificationBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.showPulse && widget.count > 0) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedNotificationBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count) {
      if (widget.count > 0 && widget.showPulse) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (widget.count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: _buildBadge(context),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBadge(BuildContext context) {
    final isHighCount = widget.count > 9;
    final badgeSize = isHighCount ? 20.0 : 18.0;
    final fontSize = isHighCount ? 9.0 : 10.0;
    
    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.badgeColor ?? const Color(0xFFFF3B30),
            widget.badgeColor?.withValues(alpha: 0.8) ?? const Color(0xFFE53E3E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(badgeSize / 2),
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.badgeColor ?? const Color(0xFFFF3B30)).withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.count > 99 ? '99+' : widget.count.toString(),
          style: TextStyle(
            color: widget.textColor ?? Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            height: 1,
            letterSpacing: -0.2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
