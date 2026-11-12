import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_colors.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/features/settings/application/number_input.dart';
import 'package:owghat_lib/src/features/settings/application/settings_ui.dart';

/// A titled card that groups related setting rows.
class SettingsGroup extends StatelessWidget {
  /// Creates a group.
  const SettingsGroup({
    required this.children,
    this.title,
    this.description,
    super.key,
  });

  /// Heading of the group.
  final String? title;

  /// One line under the heading.
  final String? description;

  /// The rows.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Gaps.l),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Gaps.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null)
                Semantics(
                  header: true,
                  child: Text(title!, style: theme.textTheme.titleLarge),
                ),
              if (description != null)
                Padding(
                  padding: const EdgeInsets.only(top: Gaps.s / 2),
                  child: Text(
                    description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              if (title != null || description != null)
                const SizedBox(height: Gaps.s),
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(height: Gaps.l),
                children[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One setting: a title, a one-line description and a control.
///
/// The control sits beside the text when there is room and below it when the
/// pane is narrow or the text is scaled up.
class SettingRow extends StatelessWidget {
  /// Creates a row.
  const SettingRow({
    required this.title,
    required this.control,
    this.description,
    this.controlWidth,
    this.stacked = false,
    super.key,
  });

  /// Name of the setting.
  final String title;

  /// What it does, in one line.
  final String? description;

  /// The control (switch, dropdown, field...).
  final Widget control;

  /// Width of the control; null means its natural width.
  final double? controlWidth;

  /// Always put the control below the text.
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: theme.textTheme.bodyLarge),
        if (description != null)
          Text(
            description!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final inline = !stacked && constraints.maxWidth >= 420 * scale;
        if (inline) {
          return Row(
            children: [
              Expanded(child: text),
              const SizedBox(width: Gaps.m),
              if (controlWidth == null)
                // A long label (some languages need more words) may take at
                // most half of the row and wraps inside the control.
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth / 2,
                  ),
                  child: control,
                )
              else
                SizedBox(width: controlWidth, child: control),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            text,
            const SizedBox(height: Gaps.s),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: controlWidth == null
                  ? control
                  : ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: controlWidth!),
                      child: control,
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// A [SettingRow] whose control is a switch.
class SwitchRow extends StatelessWidget {
  /// Creates a switch row.
  const SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.description,
    super.key,
  });

  /// Name of the setting.
  final String title;

  /// One line of explanation.
  final String? description;

  /// Current state.
  final bool value;

  /// Called with the new state; null disables the switch.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingRow(
      title: title,
      description: description,
      control: Semantics(
        label: title,
        container: true,
        child: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}

/// A set of mutually exclusive choices shown as chips that wrap.
class ChoiceChips<T> extends StatelessWidget {
  /// Creates the chips.
  const ChoiceChips({
    required this.value,
    required this.options,
    required this.onChanged,
    required this.keyPrefix,
    required this.semanticsLabel,
    super.key,
  });

  /// The selected value.
  final T value;

  /// Value and label of each chip.
  final List<(T, String)> options;

  /// Called when another chip is chosen.
  final ValueChanged<T> onChanged;

  /// Chip keys are `<keyPrefix>-<index>`.
  final String keyPrefix;

  /// Accessibility label of the group.
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      container: true,
      child: Wrap(
        spacing: Gaps.s,
        runSpacing: Gaps.s,
        children: [
          for (var i = 0; i < options.length; i++)
            ChoiceChip(
              key: Key('$keyPrefix-$i'),
              label: Text(options[i].$2),
              selected: options[i].$1 == value,
              onSelected: (_) => onChanged(options[i].$1),
            ),
        ],
      ),
    );
  }
}

/// A drop-down list with the app's look.
class AppDropdown<T> extends StatelessWidget {
  /// Creates the drop-down.
  const AppDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
    required this.semanticsLabel,
    this.disabledValues = const {},
    this.itemKeyPrefix,
    super.key,
  });

  /// The selected value.
  final T value;

  /// Value and label of each entry.
  final List<(T, String)> options;

  /// Called with the chosen value.
  final ValueChanged<T> onChanged;

  /// Accessibility label.
  final String semanticsLabel;

  /// Entries that are shown but cannot be chosen.
  final Set<T> disabledValues;

  /// Menu entries get the keys `<itemKeyPrefix>-<index>`.
  final String? itemKeyPrefix;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      container: true,
      child: InputDecorator(
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: Gaps.m,
            vertical: Gaps.s / 2,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isExpanded: true,
            value: value,
            borderRadius: BorderRadius.circular(Radii.control),
            items: [
              for (var i = 0; i < options.length; i++)
                DropdownMenuItem<T>(
                  key: itemKeyPrefix == null ? null : Key('$itemKeyPrefix-$i'),
                  value: options[i].$1,
                  enabled: !disabledValues.contains(options[i].$1),
                  child: Text(options[i].$2, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (picked) {
              if (picked != null) onChanged(picked);
            },
          ),
        ),
      ),
    );
  }
}

/// A text field that applies its value when the user presses Enter or leaves
/// the field, not on every keystroke.
///
/// [onCommit] returns an error text to show, or null when the value was
/// accepted. The field follows [value] when the setting changes elsewhere.
class CommitField extends StatefulWidget {
  /// Creates the field.
  const CommitField({
    required this.value,
    required this.onCommit,
    required this.semanticsLabel,
    this.keyboardType,
    this.textAlign = TextAlign.start,
    this.revertOnError = false,
    this.inputFormatters,
    this.labelText,
    super.key,
  });

  /// The current value, formatted.
  final String value;

  /// Validates and applies the typed text.
  final String? Function(String text) onCommit;

  /// Accessibility label.
  final String semanticsLabel;

  /// Keyboard for the field.
  final TextInputType? keyboardType;

  /// Text alignment.
  final TextAlign textAlign;

  /// On an invalid value show the current one again instead of an error.
  final bool revertOnError;

  /// Optional input filters.
  final List<TextInputFormatter>? inputFormatters;

  /// Floating label.
  final String? labelText;

  @override
  State<CommitField> createState() => _CommitFieldState();
}

class _CommitFieldState extends State<CommitField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );
  late final FocusNode _focus = FocusNode()..addListener(_onFocus);
  String? _error;
  bool _justCommitted = false;

  @override
  void didUpdateWidget(CommitField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_justCommitted ||
        (oldWidget.value != widget.value && !_focus.hasFocus)) {
      _justCommitted = false;
      if (_controller.text != widget.value) _controller.text = widget.value;
      if (oldWidget.value != widget.value) _error = null;
    }
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocus)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (!_focus.hasFocus) _commit();
  }

  void _commit() {
    final text = _controller.text;
    if (text == widget.value) {
      if (_error != null) setState(() => _error = null);
      return;
    }
    final error = widget.onCommit(text);
    if (error == null) {
      _justCommitted = true;
      if (_error != null) setState(() => _error = null);
      return;
    }
    if (widget.revertOnError) {
      _controller.text = widget.value;
      if (_error != null) setState(() => _error = null);
      return;
    }
    setState(() => _error = error);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticsLabel,
      textField: true,
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        keyboardType: widget.keyboardType,
        textAlign: widget.textAlign,
        inputFormatters: widget.inputFormatters,
        onSubmitted: (_) => _commit(),
        decoration: InputDecoration(
          isDense: true,
          labelText: widget.labelText,
          errorText: _error,
          errorMaxLines: 4,
        ),
      ),
    );
  }
}

/// A number with minus and plus buttons and a field to type it.
class IntStepper extends StatelessWidget {
  /// Creates the stepper.
  const IntStepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.format,
    required this.semanticsLabel,
    required this.keyPrefix,
    super.key,
  });

  /// Current value.
  final int value;

  /// Smallest value.
  final int min;

  /// Largest value.
  final int max;

  /// Applies a new value (called only for values within range).
  final void Function(int value) onChanged;

  /// Shows a value as text (digits, sign).
  final String Function(int value) format;

  /// Accessibility label of the field.
  final String semanticsLabel;

  /// Keys are `<keyPrefix>-dec`, `-inc` and `-field`.
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: Key('$keyPrefix-dec'),
          tooltip: l10n.settingsDecrease,
          icon: const Icon(Icons.remove),
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        SizedBox(
          width: 84,
          child: CommitField(
            key: Key('$keyPrefix-field'),
            value: format(value),
            semanticsLabel: semanticsLabel,
            textAlign: TextAlign.center,
            revertOnError: true,
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            onCommit: (text) {
              final parsed = parseIntInput(text);
              if (parsed == null || parsed < min || parsed > max) {
                return 'invalid';
              }
              if (parsed != value) onChanged(parsed);
              return null;
            },
          ),
        ),
        IconButton(
          key: Key('$keyPrefix-inc'),
          tooltip: l10n.settingsIncrease,
          icon: const Icon(Icons.add),
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

/// A slider from 0 to 100 percent with its value written beside it.
class PercentSlider extends StatelessWidget {
  /// Creates the slider.
  const PercentSlider({
    required this.value,
    required this.onChanged,
    required this.label,
    required this.semanticsLabel,
    super.key,
  });

  /// Current value from 0 to 1.
  final double value;

  /// Called while the slider moves.
  final ValueChanged<double> onChanged;

  /// The value as text, for example "60%".
  final String label;

  /// Accessibility label.
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            label: semanticsLabel,
            value: label,
            child: Slider(
              value: value.clamp(0, 1),
              divisions: 20,
              onChanged: onChanged,
            ),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48),
          child: Text(label, textAlign: TextAlign.end),
        ),
      ],
    );
  }
}

/// A short note with an info icon.
class InfoNote extends StatelessWidget {
  /// Creates the note.
  const InfoNote(this.text, {this.icon = Icons.info_outline, super.key});

  /// The note.
  final String text;

  /// Leading icon.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: Gaps.s),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// A coloured status line: icon and text, never colour alone.
class StatusLine extends StatelessWidget {
  /// Creates the line.
  const StatusLine({
    required this.text,
    required this.icon,
    this.color,
    super.key,
  });

  /// The message.
  final String text;

  /// Leading icon.
  final IconData icon;

  /// Colour of icon and text; defaults to the body colour.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: color);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: Gaps.s),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}

/// The small "saved" tick. It appears after the first change made while the
/// screen is open and flashes (200 ms fade) on every later one.
class SavedTick extends ConsumerWidget {
  /// Creates the tick.
  const SavedTick({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(settingsSavedCountProvider);
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    return Semantics(
      liveRegion: true,
      label: count == 0 ? null : l10n.settingsSaved,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: count == 0
            ? const SizedBox(key: ValueKey('saved-none'), height: 24)
            : Row(
                key: ValueKey('saved-$count'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 18, color: colors.success),
                  const SizedBox(width: Gaps.s / 2),
                  Text(
                    l10n.settingsSaved,
                    key: const Key('settings-saved-tick'),
                    style: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(color: colors.success),
                  ),
                ],
              ),
      ),
    );
  }
}
