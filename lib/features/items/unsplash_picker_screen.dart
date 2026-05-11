import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:autism_avc_flutter/core/providers/providers.dart';
import 'package:autism_avc_flutter/core/services/unsplash_service.dart';
import 'package:autism_avc_flutter/l10n/app_localizations.dart';

/// Quick-search keyword tags matching the Rails _unsplash.html.erb partial.
const _kSearchTags = ['School', 'Park', 'Play', 'Clinic', 'Sleep'];

/// Full-screen picker that searches Unsplash and returns the local file path
/// of the downloaded+saved image, or null if cancelled.
class UnsplashPickerScreen extends ConsumerStatefulWidget {
  const UnsplashPickerScreen({super.key});

  @override
  ConsumerState<UnsplashPickerScreen> createState() =>
      _UnsplashPickerScreenState();
}

class _UnsplashPickerScreenState extends ConsumerState<UnsplashPickerScreen> {
  final _searchController = TextEditingController();
  List<UnsplashPhoto> _results = [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search([String? keyword]) async {
    final query = keyword ?? _searchController.text.trim();
    if (query.isEmpty) return;

    // Update the text field to reflect the active search
    if (keyword != null) {
      _searchController.text = keyword;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final unsplash = ref.read(unsplashServiceProvider);
      final results = await unsplash.search(query);

      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
        if (results.isEmpty) {
          _error = AppLocalizations.of(context)!.noResults;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _selectPhoto(UnsplashPhoto photo) async {
    setState(() => _loading = true);

    final unsplash = ref.read(unsplashServiceProvider);
    final imageStorage = ref.read(imageStorageServiceProvider);

    // Download the regular-size image
    final bytes = await unsplash.downloadImage(photo.regularUrl);
    if (bytes == null) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context)!.downloadFailed;
      });
      return;
    }

    // Track download for Unsplash attribution
    await unsplash.trackDownload(photo.id);

    // Save locally
    final localPath = await imageStorage.saveImageBytes(bytes);

    setState(() => _loading = false);

    if (mounted) {
      Navigator.pop(context, localPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.searchUnsplash)),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchPhotosHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _search,
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
            ),
          ),

          // Quick-search keyword tags (matches Rails _unsplash.html.erb)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _kSearchTags.map((tag) {
                return ActionChip(
                  label: Text(tag),
                  onPressed: () => _search(tag),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 1),

          // Loading / Error / Results
          if (_loading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else if (_results.isEmpty)
            const Expanded(
              child: Center(
                child: Icon(Icons.image_search, size: 64, color: Colors.grey),
              ),
            )
          else
            // Results grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final photo = _results[index];
                  return GestureDetector(
                    onTap: () => _selectPhoto(photo),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            photo.thumbUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, e, st) =>
                                const Center(child: Icon(Icons.broken_image)),
                          ),
                        ),
                        // Attribution overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(8)),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              photo.photographerName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // Unsplash credit footer (matches Rails #credit-footer)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Photos from ',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse('https://unsplash.com')),
                  child: Text(
                    'Unsplash',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
