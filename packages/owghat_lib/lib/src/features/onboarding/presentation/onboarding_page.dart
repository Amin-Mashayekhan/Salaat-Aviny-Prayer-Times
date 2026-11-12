import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/features/azan/application/azan_playback.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/onboarding/application/onboarding_providers.dart';
import 'package:owghat_lib/src/features/places/application/place_search_model.dart';
import 'package:owghat_lib/src/features/places/presentation/place_search_panel.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';

/// The first-run flow: one centred card with
/// three steps (language, city, azan sample and start with Windows), a
/// progress indicator, "next" and "skip". Skipping keeps every default.
class OnboardingPage extends ConsumerWidget {
  /// Creates the page.
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = ref.watch(formatterProvider);
    final state = ref.watch(onboardingProvider);
    final controller = ref.read(onboardingProvider.notifier);
    final last = state.step == onboardingStepCount - 1;

    final body = switch (state.step) {
      0 => const _LanguageStep(),
      1 => const _CityStep(),
      _ => const _AzanStep(),
    };

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640, maxHeight: 640),
            child: Padding(
              padding: const EdgeInsets.all(Gaps.l),
              child: Card(
                key: const Key('onboarding-card'),
                child: Padding(
                  padding: const EdgeInsets.all(Gaps.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        label: l10n.onboardingStepProgress(
                          fmt.formatNumber(state.step + 1),
                          fmt.formatNumber(onboardingStepCount),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ExcludeSemantics(
                              child: Text(
                                l10n.onboardingStepProgress(
                                  fmt.formatNumber(state.step + 1),
                                  fmt.formatNumber(onboardingStepCount),
                                ),
                                key: const Key('onboarding-progress-text'),
                                style: theme.textTheme.labelLarge,
                              ),
                            ),
                            const SizedBox(height: Gaps.s),
                            LinearProgressIndicator(
                              key: const Key('onboarding-progress'),
                              value: (state.step + 1) / onboardingStepCount,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Gaps.l),
                      Expanded(child: body),
                      const SizedBox(height: Gaps.l),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: Gaps.s,
                        runSpacing: Gaps.s,
                        children: [
                          TextButton(
                            key: const Key('onboarding-skip'),
                            onPressed: controller.finish,
                            child: Text(l10n.onboardingSkip),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (state.step > 0) ...[
                                OutlinedButton(
                                  key: const Key('onboarding-back'),
                                  onPressed: controller.back,
                                  child: Text(l10n.onboardingBack),
                                ),
                                const SizedBox(width: Gaps.s),
                              ],
                              FilledButton(
                                key: const Key('onboarding-next'),
                                onPressed: controller.next,
                                child: Text(
                                  last
                                      ? l10n.onboardingFinish
                                      : l10n.onboardingNext,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepHeading extends StatelessWidget {
  const _StepHeading({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: Gaps.s),
        Text(body, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _LanguageStep extends ConsumerWidget {
  const _LanguageStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final language = ref.watch(settingsProvider.select((s) => s.language));
    final controller = ref.read(onboardingProvider.notifier);

    Widget choice(AppLanguage value) => Card(
      child: ListTile(
        key: Key('onboarding-language-${value.name}'),
        selected: language == value,
        selectedTileColor: Theme.of(context).colorScheme.primaryContainer
            .withValues(alpha: 0.5),
        minVerticalPadding: Gaps.m,
        leading: Icon(
          language == value
              ? Icons.radio_button_checked
              : Icons.radio_button_unchecked,
        ),
        title: Text(
          value.nativeName,
          textDirection: value.rtl ? TextDirection.rtl : TextDirection.ltr,
        ),
        onTap: () => controller.chooseLanguage(value),
      ),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StepHeading(
            title: l10n.onboardingLanguageTitle,
            body: l10n.onboardingLanguageBody,
          ),
          const SizedBox(height: Gaps.l),
          for (final value in AppLanguage.values) ...[
            choice(value),
            const SizedBox(height: Gaps.s),
          ],
        ],
      ),
    );
  }
}

class _CityStep extends ConsumerStatefulWidget {
  const _CityStep();

  @override
  ConsumerState<_CityStep> createState() => _CityStepState();
}

class _CityStepState extends ConsumerState<_CityStep> {
  late final TextEditingController _search = TextEditingController(
    text: ref.read(onboardingProvider).query,
  );
  bool _online = false;
  bool _unusableZone = false;

  void _pickOnline(PickedPlace picked) {
    final ok = ref.read(onboardingProvider.notifier).selectPlace(picked);
    setState(() => _unusableZone = !ok);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final language = ref.watch(settingsProvider.select((s) => s.language));
    final repository = ref.watch(locationRepositoryProvider);
    final state = ref.watch(onboardingProvider);
    final controller = ref.read(onboardingProvider.notifier);
    final cities = ref.watch(onboardingCitiesProvider);
    final active = ref.watch(activeLocationProvider);
    final activeCityId = ref.watch(
      settingsProvider.select((s) {
        final saved = s.activeLocation;
        return saved.kind == LocationKind.builtin ? saved.cityId : null;
      }),
    );

    String cityName(int id) {
      final city = repository.cityById(id);
      if (city == null) return '';
      return language.pickName(arabicScript: city.nameFa, latin: city.nameEn);
    }

    String provinceName(int id) {
      final province = repository.provinceById(id);
      if (province == null) return '';
      return language.pickName(
        arabicScript: province.nameFa,
        latin: province.nameEn,
      );
    }

    // One scroll view for the whole step: the small controls scroll away with
    // the list when the window is short or the text is large.
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StepHeading(
                title: l10n.onboardingCityTitle,
                body: _online
                    ? l10n.onboardingOnlineBody
                    : l10n.onboardingCityBody,
              ),
              const SizedBox(height: Gaps.m),
              Wrap(
                spacing: Gaps.s,
                runSpacing: Gaps.s,
                children: [
                  ChoiceChip(
                    key: const Key('onboarding-mode-list'),
                    avatar: const Icon(Icons.list_alt, size: 18),
                    label: Text(l10n.onboardingModeList),
                    selected: !_online,
                    onSelected: (_) => setState(() => _online = false),
                  ),
                  ChoiceChip(
                    key: const Key('onboarding-mode-online'),
                    avatar: const Icon(Icons.public, size: 18),
                    label: Text(l10n.onboardingModeOnline),
                    selected: _online,
                    onSelected: (_) => setState(() => _online = true),
                  ),
                ],
              ),
              const SizedBox(height: Gaps.m),
              if (_online) ...[
                PlaceSearchPanel(
                  keyPrefix: 'onboarding-place',
                  settlementsOnly: true,
                  resolveDetails: true,
                  showTitle: false,
                  onPicked: _pickOnline,
                ),
                if (_unusableZone)
                  Padding(
                    padding: const EdgeInsets.only(top: Gaps.s),
                    child: Text(
                      l10n.placeSearchUnknownZone,
                      key: const Key('onboarding-place-unusable'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: Gaps.m),
                Text(
                  l10n.onboardingCitySelected(active.nameIn(language)),
                  key: const Key('onboarding-selected'),
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: Gaps.s),
              ] else ...[
                TextField(
                  key: const Key('onboarding-search'),
                  controller: _search,
                  onChanged: controller.setQuery,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: l10n.onboardingCitySearchHint,
                  ),
                ),
                const SizedBox(height: Gaps.s),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: Gaps.s),
                        child: ChoiceChip(
                          key: const Key('onboarding-province-all'),
                          label: Text(l10n.onboardingProvinceAll),
                          selected: state.provinceId == null,
                          onSelected: (_) => controller.setProvince(null),
                        ),
                      ),
                      for (final province in repository.provinces)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            end: Gaps.s,
                          ),
                          child: ChoiceChip(
                            key: Key('onboarding-province-${province.id}'),
                            label: Text(provinceName(province.id)),
                            selected: state.provinceId == province.id,
                            onSelected: (_) =>
                                controller.setProvince(province.id),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: Gaps.s),
                Text(
                  l10n.onboardingCitySelected(active.nameIn(language)),
                  key: const Key('onboarding-selected'),
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: Gaps.s),
              ],
            ],
          ),
        ),
        if (_online)
          const SliverToBoxAdapter(child: SizedBox.shrink())
        else if (cities.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(Gaps.l),
              child: Center(child: Text(l10n.onboardingCityNone)),
            ),
          )
        else
          SliverList.builder(
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              final selected = city.id == activeCityId;
              return ListTile(
                key: Key('onboarding-city-${city.id}'),
                selected: selected,
                title: Text(cityName(city.id)),
                subtitle: Text(provinceName(city.provinceId)),
                trailing: selected ? const Icon(Icons.check) : null,
                onTap: () => controller.selectCity(city),
              );
            },
          ),
      ],
    );
  }
}

class _AzanStep extends ConsumerWidget {
  const _AzanStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final playing = ref.watch(azanPlaybackProvider.select((s) => s.playing));
    final launch = ref.watch(
      settingsProvider.select((s) => s.window.launchAtStartup),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StepHeading(
            title: l10n.onboardingAzanTitle,
            body: l10n.onboardingAzanBody,
          ),
          const SizedBox(height: Gaps.l),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: playing
                ? FilledButton.tonalIcon(
                    key: const Key('onboarding-stop'),
                    onPressed: () =>
                        ref.read(azanPlaybackProvider.notifier).stop(),
                    icon: const Icon(Icons.stop_rounded),
                    label: Text(l10n.onboardingStopPreview),
                  )
                : FilledButton.tonalIcon(
                    key: const Key('onboarding-preview'),
                    onPressed: () => ref.read(onboardingPreviewProvider)(),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(l10n.onboardingPreview),
                  ),
          ),
          const SizedBox(height: Gaps.m),
          SwitchListTile(
            key: const Key('onboarding-startup'),
            contentPadding: EdgeInsets.zero,
            value: launch,
            title: Text(l10n.onboardingStartWithWindows),
            subtitle: Text(l10n.onboardingStartWithWindowsHint),
            onChanged: (value) => ref
                .read(settingsProvider.notifier)
                .setLaunchAtStartup(enabled: value),
          ),
        ],
      ),
    );
  }
}
