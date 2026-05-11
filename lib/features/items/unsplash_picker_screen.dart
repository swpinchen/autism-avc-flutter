import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:autism_avc_flutter/core/providers/providers.dart';
import 'package:autism_avc_flutter/core/services/unsplash_service.dart';

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

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final unsplash = ref.read(unsplashServiceProvider);
    final results = await unsplash.search(query);

    setState(() {
      _results = results;
      _loading = false;
      if (results.isEmpty) _error = 'No results found';
    });
  }

  Future<void> _selectPhoto(UnsplashPhoto photo) async {
    setState(() => _loading = true);

    final unsplash = ref.read(unsplashServiceProvider);
    final imageStorage = ref.read(imageStorageServiceProvider);

    // Download the regular-size image
    final bytes = await unsplash.downloadImage(photo.regularUrl);
    if (bytes == null) {
      setState(() {
        _loading = false;
        _error = 'Failed to download image';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Search Unsplash')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search photos...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
            ),
          ),

          // Loading / Error
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(_error!, style: Theme.of(context).textTheme.bodyLarge),
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
        ],
      ),
    );
  }
}
