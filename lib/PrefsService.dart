import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static final PrefsService instance = PrefsService();
  static SharedPreferences _pref;

  Future<void> initialize() async {
    _pref = await SharedPreferences.getInstance();
  }

  Future<void> setUserSetting(
      {double sellingPriceLessThan,
      double profitGreatThan,
      bool isHiddenExpireStock}) async {
    if (sellingPriceLessThan != null) {
      await _pref.setDouble('sellingPriceLessThan', sellingPriceLessThan);
    }

    if (profitGreatThan != null) {
      await _pref.setDouble('profitGreatThan', profitGreatThan);
    }

    if (isHiddenExpireStock != null) {
      await _pref.setBool('isHiddenExpireStock', isHiddenExpireStock);
    }
  }

  resetUserSetting() async {
    await _pref.setDouble('sellingPriceLessThan', null);
    await _pref.setDouble('profitGreatThan', null);
    await _pref.setBool('isHiddenExpireStock', null);
  }

  T _getValue<T>(String key) {
    try {
      return _pref.get(key) as T;
    } catch (error) {
      return null;
    }
  }

  Future<UserSetting> getUserSetting() async {
    final sellingPriceLessThan = _getValue<double>("sellingPriceLessThan");
    final profitGreatThan = _getValue<double>("profitGreatThan");
    final isHiddenExpireStock = _getValue<bool>("isHiddenExpireStock");

    return UserSetting(
        sellingPriceLessThan: sellingPriceLessThan,
        profitGreatThan: profitGreatThan,
        isHiddenExpireStock: isHiddenExpireStock);
  }

  bool isUserRegistered() {
    return _pref.get("id") != null;
  }
}

class UserSetting {
  final double sellingPriceLessThan;
  final double profitGreatThan;
  final bool isHiddenExpireStock;

  const UserSetting(
      {this.sellingPriceLessThan,
      this.profitGreatThan,
      this.isHiddenExpireStock});

  UserSetting.builder(this.sellingPriceLessThan, this.profitGreatThan,
      this.isHiddenExpireStock);
}
