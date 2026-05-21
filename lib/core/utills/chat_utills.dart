String getChatId(String uid1, String uid2) {
  final list = [uid1, uid2]..sort();
  return list.join('_');
}
