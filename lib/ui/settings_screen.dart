import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/onboarding_service.dart';
import 'theme.dart';
import 'widgets/section_header.dart';
import 'widgets/media_player_control.dart';
import 'widgets/feedback_modal.dart';
import 'widgets/toast.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onClose;

  const SettingsScreen({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFBFBFB,
      ), // Slightly off-white for premium feel
      body: Stack(
        children: [
          Consumer<OnboardingService>(
            builder: (context, onboarding, _) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(28, 60, 28, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          fontFamily: '.SF Pro Rounded',
                          color: AppTheme.accent,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    const SectionHeader(title: 'NOTIFICATIONS'),
                    const SizedBox(height: 12),
                    _buildSettingsContainer([
                      _buildToggleTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                        value: onboarding.notificationsEnabled,
                        onChanged: (val) {
                          onboarding.toggleNotifications(val);
                          AppToast.show(context, 'Settings saved');
                        },
                      ),
                    ]),


                    const SizedBox(height: 32),
                    const SectionHeader(title: 'FEEDBACK'),
                    const SizedBox(height: 12),
                    _buildSettingsContainer([
                      _buildActionTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Provide Feedback',
                        subtitle: 'Share your feedback and requests',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => const FeedbackModal(),
                          );
                        },
                      ),
                    ]),



                    const SizedBox(height: 32),
                    const SectionHeader(title: 'ABOUT'),
                    const SizedBox(height: 12),
                    _buildSettingsContainer([
                      _buildInfoTile(
                        icon: Icons.info_outline_rounded,
                        title: 'Version',
                        trailingText: '1.0.0+1',
                      ),
                      if (kDebugMode) ...[
                        const Divider(
                          height: 1,
                          indent: 50,
                          color: Color(0xFFF2F2F7),
                        ),
                        _buildActionTile(
                          icon: Icons.refresh_rounded,
                          title: 'Reset Session',
                          subtitle: 'Reset onboarding and start fresh',
                          onTap: () async {
                            await onboarding.resetOnboarding();
                            if (context.mounted) {
                              AppToast.show(
                                context,
                                'Session reset! Restarting...',
                              );
                            }
                          },
                        ),
                      ],
                    ]),

                    const SizedBox(height: 60),

                    Center(
                      child: Text(
                        'Made with ❤️ for focus',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: MediaPlayerStyles.mutedColor.withValues(
                            alpha: 0.5,
                          ),
                          fontFamily: '.SF Pro Text',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          Positioned(
            top: 20,
            right: 20,
            child: _CloseButton(onPressed: onClose),
          ),
        ],
      ),
    );
  }




  Widget _buildSettingsContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildIconCircle(icon),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D1D1F),
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _buildIconCircle(icon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D1D1F),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: MediaPlayerStyles.mutedColor.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 15,
                  color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.5),
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String trailingText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _buildIconCircle(icon),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D1D1F),
              ),
            ),
          ),
          Text(
            trailingText,
            style: TextStyle(
              fontSize: 15,
              color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 28), // Matchchevron width
        ],
      ),
    );
  }

  Widget _buildIconCircle(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppTheme.accent, size: 20),
    );
  }
}

class _HotkeyRecorder extends StatefulWidget {
  final String currentLabel;
  final Function(String label, int keyId, List<String> modifiers) onHotkeyRecorded;

  const _HotkeyRecorder({
    required this.currentLabel,
    required this.onHotkeyRecorded,
  });

  @override
  State<_HotkeyRecorder> createState() => _HotkeyRecorderState();
}

class _HotkeyRecorderState extends State<_HotkeyRecorder> {
  bool _isRecording = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (!_isRecording) return;
    if (event is! RawKeyDownEvent) return;

    final key = event.logicalKey;
    
    // Ignore pure modifier presses
    if (key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight ||
        key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight ||
        key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight ||
        key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight) {
      return;
    }

    List<String> modifiers = [];
    if (event.isControlPressed) modifiers.add('Control');
    if (event.isAltPressed) modifiers.add('Alt');
    if (event.isShiftPressed) modifiers.add('Shift');
    if (event.isMetaPressed) modifiers.add('Command');

    String label = '';
    if (modifiers.isNotEmpty) {
      label = '${modifiers.join('+')}+';
    }
    label += key.keyLabel;

    widget.onHotkeyRecorded(
      label,
      key.keyId,
      modifiers,
    );

    setState(() {
      _isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isRecording ? Icons.fiber_manual_record_rounded : Icons.keyboard_rounded, 
              color: _isRecording ? Colors.red : AppTheme.accent, 
              size: 20
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shortcut Key',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
                Text(
                  _isRecording ? 'Press your desired keys...' : 'Press to change shortcut',
                  style: TextStyle(
                    fontSize: 13,
                    color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          RawKeyboardListener(
            focusNode: _focusNode,
            onKey: _handleKeyEvent,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isRecording = true;
                });
                _focusNode.requestFocus();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isRecording ? AppTheme.accent : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isRecording ? AppTheme.accent : const Color(0xFFE5E5EA),
                  ),
                ),
                child: Text(
                  _isRecording ? 'Record...' : widget.currentLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _isRecording ? Colors.white : const Color(0xFF1D1D1F),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _CloseButton({required this.onPressed});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                _isHovered
                    ? MediaPlayerStyles.subtleBackground
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isHovered ? 1.0 : 0.6,
            child: const Icon(
              Icons.close_rounded,
              color: Color(0xFF8E8E93),
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
