import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import 'navigation_key.dart';

class VersionChecker {
  static bool _checkedThisSession = false;
  static bool _isCheckingVersion = false;

  /// Verifica la versión en Firebase y muestra el pop-up si es necesario.
  static Future<void> checkVersion() async {
    if (_checkedThisSession || _isCheckingVersion) return;
    _isCheckingVersion = true;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('version')
          .get();

      if (!doc.exists) return;

      final data = doc.data()!;
      final firebaseVersion = data['current_version'] as String?;
      final forceUpdate = data['force_update'] as bool? ?? false;
      final updateUrl = data['update_url'] as String?;
      final customMessage = data['message'] as String?;

      if (firebaseVersion == null || updateUrl == null) return;

      final packageInfo = await PackageInfo.fromPlatform();
      final installedVersion = packageInfo.version;

      if (_isVersionGreater(firebaseVersion, installedVersion)) {
        _checkedThisSession = true;

        _waitForContextAndShow(
          forceUpdate: forceUpdate,
          updateUrl: updateUrl,
          newVersion: firebaseVersion,
          currentVersion: installedVersion,
          message: customMessage,
        );
      } else {
        _checkedThisSession = true;
      }
    } catch (e) {
      // Error silencioso
    } finally {
      _isCheckingVersion = false;
    }
  }

  static void _waitForContextAndShow({
    required bool forceUpdate,
    required String updateUrl,
    required String newVersion,
    required String currentVersion,
    String? message,
    int maxRetries = 5,
  }) {
    int attempts = 0;

    void attemptShow() {
      final context = navigatorKey.currentContext;

      if (context != null && context.mounted) {
        _showUpdateDialog(
          context: context,
          forceUpdate: forceUpdate,
          updateUrl: updateUrl,
          newVersion: newVersion,
          currentVersion: currentVersion,
          message: message,
        );
      } else if (attempts < maxRetries) {
        attempts++;
        Future.delayed(const Duration(milliseconds: 500), attemptShow);
      }
    }

    attemptShow();
  }

  static bool _isVersionGreater(String remote, String local) {
    try {
      List<int> remoteParts = remote.split('.').map(int.parse).toList();
      List<int> localParts = local.split('.').map(int.parse).toList();

      int maxLength = remoteParts.length > localParts.length
          ? remoteParts.length
          : localParts.length;

      for (int i = 0; i < maxLength; i++) {
        int remoteNum = i < remoteParts.length ? remoteParts[i] : 0;
        int localNum = i < localParts.length ? localParts[i] : 0;

        if (remoteNum > localNum) return true;
        if (remoteNum < localNum) return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static void _showUpdateDialog({
    required BuildContext context,
    required bool forceUpdate,
    required String updateUrl,
    required String newVersion,
    required String currentVersion,
    String? message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      barrierColor: forceUpdate ? Colors.black87 : Colors.black54,
      builder: (dialogContext) => PopScope(
        canPop: !forceUpdate,
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                forceUpdate ? Icons.warning_amber_rounded : Icons.info_outline,
                color: forceUpdate ? Colors.orangeAccent : AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  forceUpdate ? 'Actualización Requerida' : 'Nueva Versión',
                  style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message ??
                        (forceUpdate
                            ? 'Para continuar usando la aplicación, debes actualizar a la última versión.'
                            : 'Hay una nueva versión disponible con mejoras y nuevas funciones.'),
                    style: AppTheme.darkTheme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.textSecondary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildVersionRow('Versión actual:', currentVersion),
                        const SizedBox(height: 8),
                        _buildVersionRow(
                          'Nueva versión:',
                          newVersion,
                          isNew: true,
                        ),
                      ],
                    ),
                  ),
                  if (forceUpdate) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.block,
                            color: Colors.orangeAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Esta actualización es obligatoria',
                              style: AppTheme.darkTheme.textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.orangeAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            if (!forceUpdate)
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'Más tarde',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
              ),
            if (!forceUpdate) const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _launchUpdateUrl(updateUrl),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center, // ✅ AGREGAR
                children: [
                  const Icon(Icons.download, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Actualizar',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildVersionRow(
    String label,
    String version, {
    bool isNew = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isNew
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isNew
                  ? AppColors.primary
                  : AppColors.textSecondary.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            version,
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: isNew ? FontWeight.bold : FontWeight.normal,
              color: isNew ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  static Future<void> _launchUpdateUrl(String updateUrl) async {
    try {
      final uri = Uri.parse(updateUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Error silencioso
    }
  }

  static void resetSessionCheck() {
    _checkedThisSession = false;
  }
}
