/// This class used to handle transaction data
class Transactions {
  int transactionId;
  String type;
  double amount;
  String name;
  String description;
  String transactionDate;
  String expiryDate;
  int recurring;

  Transactions(this.transactionId, this.type, this.amount, this.name,
      this.description, this.transactionDate, this.expiryDate, this.recurring);

  Transactions.fromMap(Map map) {
    transactionId = map[transactionId];
    type = map[type];
    amount = map[amount];
    name = map[name];
    description = map[description];
    transactionDate = map[transactionDate];
    expiryDate = map[expiryDate];
    recurring = map[recurring];
  }
}