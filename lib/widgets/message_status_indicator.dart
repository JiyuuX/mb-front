import 'package:flutter/material.dart';

class MessageStatusIndicator extends StatelessWidget {
  final String status;
  final bool isMe;
  final VoidCallback? onRetry;

  const MessageStatusIndicator({
    Key? key,
    required this.status,
    required this.isMe,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Show status for all messages, but with different colors for own vs others
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.grey[400] : Colors.grey[600];

    Widget statusWidget;
    
    switch (status) {
      case 'sending':
        statusWidget = SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(iconColor!),
          ),
        );
        break;
      
      case 'sent':
        statusWidget = Icon(
          Icons.check,
          size: 16,
          color: iconColor,
        );
        break;
      
      case 'delivered':
        statusWidget = Icon(
          Icons.check,
          size: 16,
          color: iconColor,
        );
        break;
      
      case 'read':
        statusWidget = Icon(
          Icons.check,
          size: 16,
          color: Colors.blue,
        );
        break;
      
      case 'failed':
        statusWidget = GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.all(2),
            child: Icon(
              Icons.refresh,
              size: 16,
              color: Colors.red,
            ),
          ),
        );
        break;
      
      default:
        statusWidget = Icon(
          Icons.check,
          size: 16,
          color: iconColor,
        );
        break;
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          statusWidget,
        ],
      ),
    );
  }
} 