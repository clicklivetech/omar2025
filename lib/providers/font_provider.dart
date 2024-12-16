import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class FontProvider extends ChangeNotifier {
  double _fontSize = 1.0;
  bool _isLoading = true;

  double get fontSize => _fontSize;
  bool get isLoading => _isLoading;

  Future<void> loadFontSettings() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        final response = await SupabaseService.client
            .from('user_settings')
            .select('font_scale')
            .eq('user_id', user.id)
            .single();
        
        _fontSize = response['font_scale'] ??= 1.0;
      }
    } catch (e) {
      _fontSize = 1.0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateFontSize(double scale) async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        await SupabaseService.client.from('user_settings').upsert({
          'user_id': user.id,
          'font_scale': scale,
          'updated_at': DateTime.now().toIso8601String(),
        });

        _fontSize = scale;
        notifyListeners();
      }
    } catch (e) {
      // Handle error
    }
  }
}
