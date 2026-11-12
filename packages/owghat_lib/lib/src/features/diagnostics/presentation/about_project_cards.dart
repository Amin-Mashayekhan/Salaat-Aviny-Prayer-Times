import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_colors.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/features/diagnostics/domain/project_info.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';

/// "About the developer": name, GitHub, e-mail and mobile number.
class AuthorCard extends ConsumerWidget {
  /// Creates the card.
  const AuthorCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final language = ref.watch(settingsProvider.select((s) => s.language));
    return _SectionCard(
      cardKey: const Key('author-card'),
      title: l10n.aboutAuthorTitle,
      children: [
        Text(
          l10n.aboutAuthorIntro,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: Gaps.m),
        _ValueRow(
          keyPrefix: 'author-name',
          label: l10n.aboutContactName,
          value: language.rtl
              ? ProjectInfo.authorNameFa
              : ProjectInfo.authorNameLatin,
          copyValue: null,
          forceLtr: !language.rtl,
        ),
        _ValueRow(
          keyPrefix: 'author-github',
          label: l10n.aboutContactGithub,
          value: ProjectInfo.authorGithub,
          link: Uri.parse(ProjectInfo.authorGithub),
        ),
        _ValueRow(
          keyPrefix: 'author-telegram',
          label: l10n.aboutContactTelegram,
          value: ProjectInfo.authorTelegram,
          link: ProjectInfo.telegramLink,
        ),
        _ValueRow(
          keyPrefix: 'author-email',
          label: l10n.aboutContactEmail,
          value: ProjectInfo.authorEmail,
          link: ProjectInfo.emailLink,
        ),
        if (ProjectInfo.authorPhone.isNotEmpty) ...[
          _ValueRow(
            keyPrefix: 'author-phone',
            label: l10n.aboutContactPhone,
            value: ProjectInfo.authorPhone,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: Gaps.s),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: Gaps.s),
                Expanded(
                  child: Text(
                    l10n.aboutPhoneNote,
                    key: const Key('author-phone-note'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: Gaps.s),
        Text(
          l10n.aboutLicenceNote,
          key: const Key('author-licence-note'),
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// "Support the project": the two ways to give, each with the countries it
/// can be used from.
class SupportCard extends StatelessWidget {
  /// Creates the card.
  const SupportCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return _SectionCard(
      cardKey: const Key('support-card'),
      title: l10n.supportTitle,
      children: [
        Text(l10n.supportIntro, style: theme.textTheme.bodyMedium),
        const SizedBox(height: Gaps.m),
        _Method(
          methodKey: 'support-card-method',
          icon: Icons.credit_card,
          title: l10n.supportCardTitle,
          countries: l10n.supportCardCountries,
          children: [
            _ValueRow(
              keyPrefix: 'support-card-number',
              label: l10n.supportCardNumberLabel,
              value: ProjectInfo.bankCardGrouped,
              copyValue: ProjectInfo.bankCard,
            ),
          ],
        ),
        const SizedBox(height: Gaps.m),
        _Method(
          methodKey: 'support-crypto-method',
          icon: Icons.currency_bitcoin,
          title: l10n.supportCryptoTitle,
          countries: l10n.supportCryptoCountries,
          children: [
            _ValueRow(
              keyPrefix: 'support-crypto-network',
              label: l10n.supportCryptoNetworkLabel,
              value: l10n.supportCryptoNetworkValue,
              copyValue: null,
              forceLtr: false,
            ),
            _ValueRow(
              keyPrefix: 'support-crypto-address',
              label: l10n.supportCryptoAddressLabel,
              value: ProjectInfo.usdtAddress,
            ),
            const SizedBox(height: Gaps.s),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 20,
                  color: context.appColors.warning,
                ),
                const SizedBox(width: Gaps.s),
                Expanded(
                  child: Text(
                    l10n.supportCryptoWarning,
                    key: const Key('support-crypto-warning'),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: Gaps.m),
        Text(
          l10n.supportCheckNote,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// "Contribute": the ways to help and buttons to the repository.
class ContributeCard extends ConsumerWidget {
  /// Creates the card.
  const ContributeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ways = [
      (Icons.bug_report_outlined, l10n.contributeWayIssues),
      (Icons.code, l10n.contributeWayCode),
      (Icons.translate, l10n.contributeWayTranslate),
      (Icons.devices_outlined, l10n.contributeWayTest),
      (Icons.place_outlined, l10n.contributeWayData),
    ];
    return _SectionCard(
      cardKey: const Key('contribute-card'),
      title: l10n.contributeTitle,
      children: [
        Text(l10n.contributeIntro, style: theme.textTheme.bodyMedium),
        const SizedBox(height: Gaps.s),
        for (var i = 0; i < ways.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: Gaps.s),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(ways[i].$1, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: Gaps.s),
                Expanded(
                  child: Text(
                    ways[i].$2,
                    key: Key('contribute-way-$i'),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: Gaps.s),
        _LinkButtons(
          buttons: [
            (
              'contribute-open-repo',
              Icons.folder_open_outlined,
              l10n.contributeOpenRepo,
              Uri.parse(ProjectInfo.repository),
            ),
            (
              'contribute-open-issues',
              Icons.bug_report_outlined,
              l10n.contributeOpenIssues,
              Uri.parse(ProjectInfo.issues),
            ),
            (
              'contribute-open-guide',
              Icons.menu_book_outlined,
              l10n.contributeOpenGuide,
              Uri.parse(ProjectInfo.contributingGuide),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.cardKey,
    required this.title,
    required this.children,
  });

  final Key cardKey;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    key: cardKey,
    child: Padding(
      padding: const EdgeInsets.all(Gaps.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: Gaps.s),
          ...children,
        ],
      ),
    ),
  );
}

/// One way of giving: a title, the countries it works from, its details.
class _Method extends StatelessWidget {
  const _Method({
    required this.methodKey,
    required this.icon,
    required this.title,
    required this.countries,
    required this.children,
  });

  final String methodKey;
  final IconData icon;
  final String title;
  final String countries;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return DecoratedBox(
      key: Key(methodKey),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Gaps.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: Gaps.s),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: Gaps.s),
            Text(
              l10n.supportAvailableIn,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              countries,
              key: Key('$methodKey-countries'),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: Gaps.s),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// A labelled value (an address, a number) with buttons to open it as a link
/// and to copy it.
class _ValueRow extends ConsumerStatefulWidget {
  const _ValueRow({
    required this.keyPrefix,
    required this.label,
    required this.value,
    this.link,
    this.copyValue = '',
    this.forceLtr = true,
  });

  final String keyPrefix;
  final String label;
  final String value;

  /// When set, an Open button hands this address to the system.
  final Uri? link;

  /// What the Copy button puts on the clipboard; empty means [value], null
  /// means there is no Copy button.
  final String? copyValue;

  /// Whether the value is written left to right (addresses and numbers).
  final bool forceLtr;

  @override
  ConsumerState<_ValueRow> createState() => _ValueRowState();
}

class _ValueRowState extends ConsumerState<_ValueRow> {
  String? _message;
  bool _failed = false;

  Future<void> _copy() async {
    final text = widget.copyValue == null || widget.copyValue!.isEmpty
        ? widget.value
        : widget.copyValue!;
    final l10n = AppLocalizations.of(context);
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        setState(() {
          _message = l10n.aboutCopiedValue;
          _failed = false;
        });
      }
    } on Object {
      if (mounted) {
        setState(() {
          _message = l10n.diagCopyFailed;
          _failed = true;
        });
      }
    }
  }

  Future<void> _open() async {
    final l10n = AppLocalizations.of(context);
    var opened = false;
    try {
      opened = await ref.read(linkOpenerProvider).open(widget.link!);
    } on Object {
      opened = false;
    }
    if (!mounted) return;
    setState(() {
      _message = opened ? null : l10n.aboutOpenFailed;
      _failed = !opened;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final canCopy = widget.copyValue != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gaps.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: Gaps.s,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 40),
                child: Align(
                  widthFactor: 1,
                  alignment: AlignmentDirectional.centerStart,
                  child: Directionality(
                    textDirection: widget.forceLtr
                        ? TextDirection.ltr
                        : Directionality.of(context),
                    child: SelectableText(
                      widget.value,
                      key: Key('${widget.keyPrefix}-value'),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
              if (widget.link != null)
                TextButton.icon(
                  key: Key('${widget.keyPrefix}-open'),
                  onPressed: () => unawaited(_open()),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(l10n.aboutOpen),
                ),
              if (canCopy)
                TextButton.icon(
                  key: Key('${widget.keyPrefix}-copy'),
                  onPressed: () => unawaited(_copy()),
                  icon: const Icon(Icons.copy, size: 18),
                  label: Text(l10n.aboutCopy),
                ),
            ],
          ),
          if (_message != null)
            Text(
              _message!,
              key: Key('${widget.keyPrefix}-message'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _failed
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}

/// Buttons that open a link each, with one shared failure note.
class _LinkButtons extends ConsumerStatefulWidget {
  const _LinkButtons({required this.buttons});

  /// Key, icon, label and address of each button.
  final List<(String, IconData, String, Uri)> buttons;

  @override
  ConsumerState<_LinkButtons> createState() => _LinkButtonsState();
}

class _LinkButtonsState extends ConsumerState<_LinkButtons> {
  bool _failed = false;

  Future<void> _open(Uri uri) async {
    var opened = false;
    try {
      opened = await ref.read(linkOpenerProvider).open(uri);
    } on Object {
      opened = false;
    }
    if (mounted) setState(() => _failed = !opened);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: Gaps.s,
          runSpacing: Gaps.s,
          children: [
            for (final button in widget.buttons)
              OutlinedButton.icon(
                key: Key(button.$1),
                onPressed: () => unawaited(_open(button.$4)),
                icon: Icon(button.$2),
                label: Text(button.$3),
              ),
          ],
        ),
        if (_failed)
          Padding(
            padding: const EdgeInsets.only(top: Gaps.s),
            child: Text(
              l10n.aboutOpenFailed,
              key: const Key('contribute-open-failed'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
