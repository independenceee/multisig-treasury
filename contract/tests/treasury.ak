use cardano/assets.{PolicyId}
use cardano/transaction.{OutputReference, Transaction}
use contract/types.{Datum, Deposit, End, Execute, Init, Mint, Signature, Spend}

validator treasury(threshold: Int) {
  mint(redeemer: Mint, policy_id: PolicyId, transaction: Transaction) {
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
  ) {
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
