import 'package:flutter/material.dart';
import '../theme/duel_colors.dart';
import '../theme/duel_typography.dart';
import '../theme/duel_ui_tokens.dart';

class DFSearchBox extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;

  const DFSearchBox({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.onClear,
    this.controller,
  });

  @override
  State<DFSearchBox> createState() => _DFSearchBoxState();
}

class _DFSearchBoxState extends State<DFSearchBox> {
  late TextEditingController _controller;
  bool _hasText = false;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: DuelColors.surfaceHighlight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(DuelUiTokens.radiusFull),
        border: Border.all(
          color: _isFocused ? DuelColors.primary : Colors.white10,
          width: 1.5,
        ),
        boxShadow: _isFocused ? DuelUiTokens.glowCyan : [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: DuelUiTokens.spacing16),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: _isFocused ? DuelColors.primary : DuelColors.textSecondary,
          ),
          const SizedBox(width: DuelUiTokens.spacing12),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              style: DuelTypography.bodyLarge,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: DuelTypography.bodyMedium,
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              cursorColor: DuelColors.primary,
            ),
          ),
          if (_hasText)
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onChanged('');
                widget.onClear?.call();
              },
              child: const Icon(
                Icons.close,
                color: DuelColors.textSecondary,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
