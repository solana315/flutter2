import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../api/api_client.dart';
import '../api/declarations_api.dart';
import '../api/files_api.dart';
import '../api/models.dart';
import '../app/session_scope.dart';

class DeclarationsDocsPage extends StatefulWidget {
  const DeclarationsDocsPage({super.key});

  @override
  State<DeclarationsDocsPage> createState() => _DeclarationsDocsPageState();
}

class _DeclarationsDocsPageState extends State<DeclarationsDocsPage> {
  bool _initialized = false;
  bool _handledAuthError = false;

  bool _loadingDocs = false;
  Object? _docsError;
  List<ApiFileItem> _docs = const [];
  String _docsQuery = '';
  int? _downloadingDocId;

  bool _loadingDeclarations = false;
  Object? _declarationsError;
  List<ApiDeclarationItem> _declarations = const [];
  String _declarationsQuery = '';
  int? _downloadingDeclarationId;

  late FilesApi _filesApi;
  late DeclarationsApi _declarationsApi;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final session = SessionScope.of(context);
    _filesApi = FilesApi(session.apiClient);
    _declarationsApi = DeclarationsApi(session.apiClient);
    _refreshAll();
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadDocs(),
      _loadDeclarations(),
    ]);
  }

  Future<void> _loadDocs() async {
    final session = SessionScope.of(context);
    final patientId = session.patientId;
    if (patientId == null) {
      setState(() {
        _docsError = Exception('Sessão inválida.');
      });
      return;
    }

    setState(() {
      _loadingDocs = true;
      _docsError = null;
    });

    try {
      final items = await _filesApi.listFiles(patientId: patientId);
      if (!mounted) return;
      setState(() {
        _docs = items;
      });
    } catch (e) {
      if (!mounted) return;
      _handleAuthIfNeeded(e);
      setState(() {
        _docsError = e;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingDocs = false;
        });
      }
    }
  }

  Future<void> _loadDeclarations() async {
    setState(() {
      _loadingDeclarations = true;
      _declarationsError = null;
    });

    try {
      final session = SessionScope.of(context);
      final items = await _declarationsApi.listDeclarations(
        patientId: session.patientId,
      );
      if (!mounted) return;
      setState(() {
        _declarations = items;
      });
    } catch (e) {
      if (!mounted) return;
      _handleAuthIfNeeded(e);
      setState(() {
        _declarationsError = e;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingDeclarations = false;
        });
      }
    }
  }

  void _handleAuthIfNeeded(Object e) {
    final status = (e is ApiException) ? e.status : null;
    if ((status == 401 || status == 403) && !_handledAuthError) {
      _handledAuthError = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final session = SessionScope.of(context);
        final navigator = Navigator.of(context);
        session.logout().then((_) {
          if (!mounted) return;
          navigator.pushNamedAndRemoveUntil('/login', (r) => false);
        });
      });
    }
  }

  List<ApiFileItem> get _filteredDocs {
    final q = _docsQuery.trim().toLowerCase();
    if (q.isEmpty) return _docs;
    return _docs.where((d) {
      final hay = [d.name, d.mimeType, d.category].whereType<String>().join(' ');
      return hay.toLowerCase().contains(q);
    }).toList();
  }

  List<ApiDeclarationItem> get _filteredDeclarations {
    final q = _declarationsQuery.trim().toLowerCase();
    if (q.isEmpty) return _declarations;
    return _declarations.where((d) {
      final hay = [
        d.title,
        d.subtitle,
        d.doctor,
        d.specialty,
      ].whereType<String>().join(' ');
      return hay.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = scheme.surfaceContainerLow;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          title: const Text('Declarações/Docs'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Docs'),
              Tab(text: 'Declarações'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DocsTab(
              backgroundColor: bg,
              loading: _loadingDocs,
              error: _docsError,
              items: _filteredDocs,
              query: _docsQuery,
              onQueryChanged: (v) => setState(() => _docsQuery = v),
              onRefresh: _loadDocs,
              downloadingId: _downloadingDocId,
              onDownload: _downloadDoc,
            ),
            _DeclarationsTab(
              backgroundColor: bg,
              loading: _loadingDeclarations,
              error: _declarationsError,
              items: _filteredDeclarations,
              query: _declarationsQuery,
              onQueryChanged: (v) => setState(() => _declarationsQuery = v),
              onRefresh: _loadDeclarations,
              downloadingId: _downloadingDeclarationId,
              onDownload: _downloadDeclaration,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadDoc(ApiFileItem doc) async {
    setState(() => _downloadingDocId = doc.id);
    try {
      final res = await _filesApi.downloadFile(doc.id);
      await _saveAndOpen(
        bytes: res.bytes,
        filename: res.filename ?? doc.name,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documento descarregado.')),
      );
    } catch (e) {
      if (!mounted) return;
      _handleAuthIfNeeded(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyError(e, fallback: 'Erro ao descarregar documento.'))),
      );
    } finally {
      if (mounted) {
        setState(() => _downloadingDocId = null);
      }
    }
  }

  Future<void> _downloadDeclaration(ApiDeclarationItem declaration) async {
    setState(() => _downloadingDeclarationId = declaration.id);
    try {
      final res = await _declarationsApi.downloadDeclaration(declaration: declaration);
      await _saveAndOpen(
        bytes: res.bytes,
        filename: res.filename ?? 'declaracao_${declaration.id}.pdf',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Declaração descarregada.')),
      );
    } catch (e) {
      if (!mounted) return;
      _handleAuthIfNeeded(e);

      final status = (e is ApiException) ? e.status : null;
      if (status == 404 || status == 400 || status == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disponível apenas após a consulta.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_friendlyError(e, fallback: 'Erro ao descarregar declaração.'))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _downloadingDeclarationId = null);
      }
    }
  }

  static String _friendlyError(Object e, {required String fallback}) {
    if (e is ApiException) {
      final msg = e.message.trim();
      return msg.isEmpty ? fallback : msg;
    }
    return fallback;
  }

  static Future<void> _saveAndOpen({
    required List<int> bytes,
    required String filename,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final safeName = _sanitizeFilename(filename);
    final file = File('${dir.path}${Platform.pathSeparator}$safeName');
    await file.writeAsBytes(bytes, flush: true);
    await OpenFilex.open(file.path);
  }

  static String _sanitizeFilename(String input) {
    var name = input.trim();
    if (name.isEmpty) return 'download.pdf';

    // Windows-illegal characters + control chars
    name = name.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_');
    name = name.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (name.isEmpty) return 'download.pdf';
    if (name.length > 160) {
      name = name.substring(name.length - 160);
    }
    return name;
  }
}

class _DocsTab extends StatelessWidget {
  final Color backgroundColor;
  final bool loading;
  final Object? error;
  final List<ApiFileItem> items;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final Future<void> Function() onRefresh;
  final int? downloadingId;
  final void Function(ApiFileItem) onDownload;

  const _DocsTab({
    required this.backgroundColor,
    required this.loading,
    required this.error,
    required this.items,
    required this.query,
    required this.onQueryChanged,
    required this.onRefresh,
    required this.downloadingId,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (loading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && items.isEmpty) {
      return _ErrorState(
        message: 'Não foi possível carregar os documentos.',
        details: error.toString(),
        onRetry: onRefresh,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Pesquisar documentos…',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: onQueryChanged,
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'Sem documentos para mostrar.',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
            )
          else
            ...items.map((doc) {
              final downloading = downloadingId == doc.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.03),
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.description_outlined),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _docSubtitle(doc),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Descarregar',
                      onPressed: downloading ? null : () => onDownload(doc),
                      icon: downloading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download_rounded),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  static String _docSubtitle(ApiFileItem doc) {
    final parts = <String>[];
    if (doc.category != null && doc.category!.trim().isNotEmpty) {
      parts.add(doc.category!.trim());
    } else if (doc.mimeType != null && doc.mimeType!.trim().isNotEmpty) {
      parts.add(doc.mimeType!.trim());
    }
    final date = doc.createdAt;
    if (date != null) {
      parts.add('${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}');
    }
    return parts.isEmpty ? 'Documento' : parts.join(' • ');
  }
}

class _DeclarationsTab extends StatelessWidget {
  final Color backgroundColor;
  final bool loading;
  final Object? error;
  final List<ApiDeclarationItem> items;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final Future<void> Function() onRefresh;
  final int? downloadingId;
  final void Function(ApiDeclarationItem) onDownload;

  const _DeclarationsTab({
    required this.backgroundColor,
    required this.loading,
    required this.error,
    required this.items,
    required this.query,
    required this.onQueryChanged,
    required this.onRefresh,
    required this.downloadingId,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (loading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && items.isEmpty) {
      return _ErrorState(
        message: 'Não foi possível carregar as declarações.',
        details: error.toString(),
        onRetry: onRefresh,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Pesquisar declarações…',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: onQueryChanged,
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'Sem declarações para mostrar.',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
            )
          else
            ...items.map((d) {
              final downloading = downloadingId == d.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.03),
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.picture_as_pdf_outlined),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _declSubtitle(d),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: downloading ? null : () => onDownload(d),
                      icon: downloading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.download_rounded, size: 18),
                      label: const Text('PDF'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  static String _declSubtitle(ApiDeclarationItem d) {
    final parts = <String>[];
    if (d.subtitle != null && d.subtitle!.trim().isNotEmpty) {
      parts.add(d.subtitle!.trim());
    }
    if (d.doctor != null && d.doctor!.trim().isNotEmpty) {
      parts.add(d.doctor!.trim());
    }
    if (d.specialty != null && d.specialty!.trim().isNotEmpty) {
      parts.add(d.specialty!.trim());
    }
    final date = d.date;
    if (date != null) {
      parts.add('${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}');
    }
    return parts.isEmpty ? 'Declaração' : parts.join(' • ');
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final String details;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.details,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              details,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => onRetry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
