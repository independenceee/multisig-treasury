use aiken/collection/list
use cardano/assets.{PolicyId, lovelace_of}
use cardano/transaction.{InlineDatum, OutputReference, Transaction, find_input}
use cardano/tx.{verify_signature}
use cocktail/vodka_address.{address_pub_key}
use contract/types.{Datum, Deposit, End, Execute, Init, Mint, Signature, Spend}

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
    expect Some(datum_input) = datum_option
    let Transaction { inputs, outputs, extra_signatories, .. } = transaction
    expect Some(input) = find_input(inputs, output_reference)
    let script_address = input.output.address
    expect [output] =
      list.filter(outputs, fn(output) { output.address == script_address })

    when redeemer is {
      Deposit -> {
        expect InlineDatum(datum_output_raw) = output.datum
        expect datum_output: Datum = datum_output_raw

        and {
          datum_input.owners == datum_output.owners,
          datum_input.signers == datum_output.signers,
          datum_input.receiver == datum_output.receiver,
          lovelace_of(output.value) >= lovelace_of(input.output.value),
        }
      }
      Execute -> True
      Signature -> {
        let signers =
          list.filter(
            extra_signatories,
            fn(extra_signatory) {
              let extra_signatory_option = Some(extra_signatory)
              let is_owner =
                list.any(
                  datum_input.owners,
                  fn(owner) { address_pub_key(owner) == extra_signatory_option },
                )
              let already_signed =
                list.any(
                  datum_input.signers,
                  fn(signer) {
                    address_pub_key(signer) == extra_signatory_option
                  },
                )
              and {
                is_owner,
                !already_signed,
              }
            },
          )

        expect InlineDatum(datum_output_raw) = output.datum
        expect datum_output: Datum = datum_output_raw

        and {
          list.length(signers) > 0,
          datum_input.owners == datum_output.owners,
          datum_input.receiver == datum_output.receiver,
          list.all(
            datum_input.signers,
            fn(signer) { list.has(datum_output.signers, signer) },
          ),
          lovelace_of(output.value) >= lovelace_of(input.output.value),
        }
      }
    }
  }

  else(_) {
    fail
  }
}
