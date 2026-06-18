class IvRepo {
  final List<Map<String, dynamic>> data = [];

  addData(String name, String address) {
    data.add({'nameF': name, 'addressF': address});
  }

  List<Map<String, dynamic>> getData() {
    return data;
  }
}
