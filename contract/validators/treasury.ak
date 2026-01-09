use aiken/collection/list
use cardano/assets.{PolicyId}
use cardano/transaction.{OutputReference, Transaction}
use cocktail/vodka_address.{address_pub_key}
use contract/types.{Datum, Deposit, End, Execute, Init, Mint, Signature, Spend}
use cardano/tx.{verify_signature}

validator treasury(threshold: Int, allowance: Int) {
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

    let Transaction { inputs, outputs, extra_signatories, .. } = transaction
    when redeemer is {
      Deposit -> True
      Execute -> True
      Signature -> {
        let signers =
          list.filter(
            extra_signatories,
            fn(extra_signatory) {
             let extra_signatory_option = Some(extra_signatory)
              let is_owner =
                list.any(
                  datum.owners,
                  fn(owner) { address_pub_key(owner) == extra_signatory_option },
                )
              let already_signed =
                list.any(
                  datum.signers,
                  fn(signer) { address_pub_key(signer) == extra_signatory_option },
                )
              and {
                is_owner,
                !already_signed,
              }
            },
          )
         list.length(signers) > 0
      }
    }
  }

  else(_) {
    fail
  }
}
