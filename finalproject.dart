import 'dart:io';

class Transaction {
  int id;
  String description;
  int quantity;
  double price;
  double total;
  DateTime date;

  Transaction(this.id, this.description, this.quantity, this.price, this.total,
      this.date);

  @override
  String toString() {
    return 'Transaction{id: $id, description: $description, quantity: $quantity, price: $price, total: $total, date: $date}';
  }
}

class CashData {
  String name;
  List<double> cash;
  double idCardTanggungan;
  double pdhTanggungan;

  CashData(this.name, this.cash, this.idCardTanggungan, this.pdhTanggungan);

  double get balance => cash.fold(0, (prev, curr) => prev + curr);
}

// Implementasi Queue
class Queue<T> {
  List<T> _list = [];

  void add(T value) => _list.add(value);
  T removeFirst() => _list.removeAt(0);
  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;
  int get length => _list.length;
}

// Implementasi Node untuk BST
class Node {
  Transaction data;
  Node? left;
  Node? right;

  Node(this.data);
}

// Implementasi BST
class BST {
  Node? root;

  void insert(Transaction data) {
    root = _insertRec(root, data);
  }

  Node _insertRec(Node? node, Transaction data) {
    if (node == null) {
      return Node(data);
    }
    if (data.id < node.data.id) {
      node.left = _insertRec(node.left, data);
    } else if (data.id > node.data.id) {
      node.right = _insertRec(node.right, data);
    }
    return node;
  }

  Transaction? search(int id) {
    return _searchRec(root, id);
  }

  Transaction? _searchRec(Node? node, int id) {
    if (node == null || node.data.id == id) {
      return node?.data;
    }
    if (id < node.data.id) {
      return _searchRec(node.left, id);
    }
    return _searchRec(node.right, id);
  }

  List<Transaction> searchByDescription(String description) {
    List<Transaction> results = [];
    _searchByDescriptionRec(root, description, results);
    return results;
  }

  void _searchByDescriptionRec(
      Node? node, String description, List<Transaction> results) {
    if (node != null) {
      if (node.data.description.contains(description)) {
        results.add(node.data);
      }
      _searchByDescriptionRec(node.left, description, results);
      _searchByDescriptionRec(node.right, description, results);
    }
  }
}

Queue<Transaction> paymentQueue = Queue<Transaction>();
List<Transaction> transactionHistory = [];
List<CashData> cashDataList = [
  CashData('Jasmine', [], 20000, 135000),
  CashData('Zahra', [], 20000, 135000),
  CashData('Jusmin', [], 20000, 135000),
  CashData('Zahro', [], 20000, 135000),
];
BST transactionBST = BST();

const int ID_CARD_AMOUNT = 20000;
const int PDH_AMOUNT = 135000;

void showTotalCashBalance() {
  double totalCash =
      cashDataList.fold(0, (prev, cashData) => prev + cashData.balance);
  print('\nSaldo Kas Keseluruhan: $totalCash');
}

void showOutstandingPayments(String memberName) {
  var cashData = cashDataList.firstWhere((data) => data.name == memberName);
  print(
      '${cashData.name}: ID Card ${cashData.idCardTanggungan.toInt()}, PDH ${cashData.pdhTanggungan.toInt()}');
}

void showBalances() {
  print('\nSaldo:');
  for (var cashData in cashDataList) {
    var balance = cashData.balance;
    print('${cashData.name} Kas: $balance');
  }
}

void addTransaction(
    int id, String description, int quantity, double price, double total) {
  DateTime date = DateTime.now();
  Transaction transaction =
      Transaction(id, description, quantity, price, total, date);

  if (description.contains('Pembayaran Kas')) {
    // Proses pembayaran kas
    for (var cashData in cashDataList) {
      if (description.contains(cashData.name)) {
        if (cashData.cash.isEmpty) {
          cashData.cash.add(0); // Inisialisasi list kas jika kosong
        }
        cashData.cash.add(total); // Saldo bertambah saat pembayaran
        print('Saldo kas ${cashData.name} ditambahkan: $total');
        break; // Hentikan iterasi setelah penambahan pertama
      }
    }
  } else {
    // Proses transaksi lainnya
    paymentQueue.add(transaction);
    transactionHistory.add(transaction);
  }
  transactionBST.insert(transaction);
}

void updateTanggungan(String description, double amount) {
  for (var cashData in cashDataList) {
    if (description.contains(cashData.name)) {
      if (description.contains('ID Card')) {
        cashData.idCardTanggungan += amount;
        print(
            '${cashData.name}: ID Card ${cashData.idCardTanggungan.toInt()}, PDH ${cashData.pdhTanggungan.toInt()}');
      } else if (description.contains('PDH')) {
        cashData.pdhTanggungan += amount;
        print(
            '${cashData.name}: ID Card ${cashData.idCardTanggungan.toInt()}, PDH ${cashData.pdhTanggungan.toInt()}');
      }
      break; // Stop looping once the relevant cashData is found and updated
    }
  }
}

void processPayment() {
  if (paymentQueue.isNotEmpty) {
    Transaction transaction = paymentQueue.removeFirst();
    print('Processed payment: $transaction');
    showOutstandingPayments(transaction.description.split(' - ')[0]);
  } else {
    print('No payments to process');
  }
}

void saveTransactionsToCSV(List<Transaction> transactions, String filePath) {
  File file = File(filePath);
  String csvContent = 'ID,Description,Quantity,Price,Total,Date\n';

  for (var transaction in transactions) {
    csvContent +=
        '${transaction.id},${transaction.description},${transaction.quantity},${transaction.price},${transaction.total},${transaction.date.toIso8601String()}\n';
  }

  file.writeAsStringSync(csvContent);
}

void loadCashDataFromCSV(String Transaction) {
  File file = File(Transaction);
  if (file.existsSync()) {
    List<String> lines = file.readAsLinesSync();
    for (var line in lines.skip(1)) {
      List<String> values = line.split(',');
      String name = values[0];
      double cash = double.parse(values[1]);
      double idCardTanggungan = double.parse(values[2]);
      double pdhTanggungan = double.parse(values[3]);

      // Inisialisasi daftar cash dengan nilai awal yang sesuai
      var cashList = [cash]; // Ubah ini sesuai dengan kebutuhan Anda

      cashDataList
          .add(CashData(name, cashList, idCardTanggungan, pdhTanggungan));
    }
  }
}

void saveCashDataToCSV(String filePath) {
  String cashDataCSVContent = 'Name,Cash,ID Card Tanggungan,PDH Tanggungan\n';
  for (var cashData in cashDataList) {
    cashDataCSVContent +=
        '${cashData.name},${cashData.balance},${cashData.idCardTanggungan},${cashData.pdhTanggungan}\n';
  }
  File(filePath).writeAsStringSync(cashDataCSVContent);
}

void processPaymentByMethod(Transaction transaction, String method) {
  // Process payment based on the selected method
  if (method == 'ID Card') {
    // Lakukan proses pembayaran ID Card
    print('Processed payment: $transaction');
  } else if (method == 'PDH') {
    // Lakukan proses pembayaran PDH
    print('Processed payment: $transaction');
  }
}

void searchTransaction(int id) {
  var transaction = transactionBST.search(id);
  if (transaction != null) {
    print('Transaksi ditemukan: $transaction');
  } else {
    print('Transaksi tidak ditemukan.');
  }
}

void searchTransactionsByDescription(String description) {
  var transactions = transactionBST.searchByDescription(description);
  if (transactions.isNotEmpty) {
    print('Transaksi ditemukan:');
    for (var transaction in transactions) {
      print(transaction);
    }
  } else {
    print('Tidak ada transaksi yang ditemukan dengan deskripsi tersebut.');
  }
}

void main() {
  bool done = false;

  // Load previous transactions from CSV file
  loadCashDataFromCSV('Payment.csv');

  while (!done) {
    print('\nPilih opsi:');
    print('1. Lihat Saldo');
    print('2. Proses Pembayaran');
    print('3. Cari Transaksi berdasarkan ID');
    print('4. Cari Transaksi berdasarkan Deskripsi');
    print('5. Selesai');
    print('Pilihan: ');
    var choice = int.parse(stdin.readLineSync()!);

    switch (choice) {
      case 1:
        showTotalCashBalance();
        break;
      case 2:
        print('\nPilih Departemen:');
        print('1. Departemen A');
        print('2. Departemen B');
        print('Departemen :');
        var departmentChoice = int.parse(stdin.readLineSync()!);

        var memberChoice;
        int selectedCashDataIndex = -1; // Tambahkan inisialisasi indeks

        switch (departmentChoice) {
          case 1:
            print('\nPilih Anggota Departemen A:');
            print('1. Jasmine');
            print('2. Zahra');
            memberChoice = int.parse(stdin.readLineSync()!);
            selectedCashDataIndex =
                memberChoice - 1; // Set indeks berdasarkan pilihan anggota
            break;
          case 2:
            print('\nPilih Anggota Departemen B:');
            print('1. Jusmin');
            print('2. Zahro');
            memberChoice = int.parse(stdin.readLineSync()!);
            selectedCashDataIndex =
                memberChoice + 1; // Set indeks berdasarkan pilihan anggota
            break;
          default:
            print('Pilihan departemen tidak valid.');
            continue;
        }

        if (selectedCashDataIndex < 0 ||
            selectedCashDataIndex >= cashDataList.length) {
          print('Pilihan anggota tidak valid.');
          continue;
        }

        print('\nPilih Pembayaran:');
        print('1. Kas');
        print('2. ID Card');
        print('3. PDH');
        print('Pilihan :');
        var paymentMethodChoice = int.parse(stdin.readLineSync()!);

        switch (paymentMethodChoice) {
          case 1:
            print('Masukkan jumlah pembayaran kas: ');
            var amount = double.parse(stdin.readLineSync()!);
            addTransaction(
                transactionHistory.length + 1,
                '${cashDataList[selectedCashDataIndex].name} - Pembayaran Kas',
                1,
                amount,
                amount);
            break;
          case 2:
            print('Masukkan jumlah pembayaran ID Card: ');
            var idCardAmount = double.parse(stdin.readLineSync()!);
            double idCardTotal =
                cashDataList[selectedCashDataIndex].idCardTanggungan -
                    idCardAmount;
            cashDataList[selectedCashDataIndex].idCardTanggungan = idCardTotal;
            addTransaction(
                transactionHistory.length + 1,
                '${cashDataList[selectedCashDataIndex].name} - Pembayaran ID Card',
                1,
                ID_CARD_AMOUNT.toDouble(),
                -idCardAmount);
            print(
                'Processed payment: Transaction{id: ${transactionHistory.length + 1}, description: ${cashDataList[selectedCashDataIndex].name} - Pembayaran ID Card, quantity: 1, price: ${ID_CARD_AMOUNT.toDouble()}, total: ${-idCardAmount}, date: ${DateTime.now()}}');
            break;
          case 3:
            print('Masukkan jumlah pembayaran PDH: ');
            var pdhAmount = double.parse(stdin.readLineSync()!);
            var pdhTotal =
                cashDataList[selectedCashDataIndex].pdhTanggungan - pdhAmount;
            cashDataList[selectedCashDataIndex].pdhTanggungan = pdhTotal;
            addTransaction(
                transactionHistory.length + 1,
                '${cashDataList[selectedCashDataIndex].name} - Pembayaran PDH',
                1,
                PDH_AMOUNT.toDouble(),
                -pdhAmount);
            print(
                'Processed payment: Transaction{id: ${transactionHistory.length + 1}, description: ${cashDataList[selectedCashDataIndex].name} - Pembayaran PDH, quantity: 1, price: ${PDH_AMOUNT.toDouble()}, total: ${-pdhAmount}, date: ${DateTime.now()}}');
            break;
          default:
            print('Pilihan tidak valid');
            break;
        }
        showOutstandingPayments(cashDataList[selectedCashDataIndex].name);
        break;
      case 3:
        print('Masukkan ID transaksi yang ingin dicari: ');
        var searchId = int.parse(stdin.readLineSync()!);
        searchTransaction(searchId);
        break;
      case 4:
        print('Masukkan deskripsi transaksi yang ingin dicari: ');
        var searchDescription = stdin.readLineSync()!;
        searchTransactionsByDescription(searchDescription);
        break;
      case 5:
        done = true;
        print('Program Selesai.');
        saveTransactionsToCSV(transactionHistory, 'Pembayaran.csv');
        saveCashDataToCSV('Pembayaran.csv');
        break;
      default:
        print('Pilihan tidak valid');
        break;
    }
  }
}
