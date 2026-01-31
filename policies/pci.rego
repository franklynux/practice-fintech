package pci

deny[msg] {
  input.database.ssl == false
  msg := "PCI violation: database SSL disabled"
}

deny[msg] {
  input.database.password != ""
  msg := "PCI violation: plaintext password detected"
}
