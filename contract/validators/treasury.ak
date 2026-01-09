use cardano/transaction.{OutputReference, Transaction}
use contract/types.{Datum, Deposit, Execute, Spend, Signature, Mint, Init, End}
use cardano/assets.{PolicyId}

validator treasury(threshold: Int) {
  mint(redeemer: Mint, policy_id: PolicyId, transaction: Transaction) -> Bool {
    when redeemer is {
      Init -> True
      End -> True
    }
  }
  spend(
    datum_option: Option<Datum>,
    redeemer: Spend,
    output_reference: OutputReference,
    transaction: Transaction,
  ) -> Bool {
    expect Some(datum) = datum_option
    when redeemer is {
      Deposit -> True
      Execute -> True
      Signature -> True
    }
  }

  else(_) {
    fail
  }
}
