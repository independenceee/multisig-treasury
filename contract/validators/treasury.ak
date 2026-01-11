use aiken/collection/list
use cardano/assets.{PolicyId, lovelace_of, without_lovelace}
use cardano/transaction.{InlineDatum, OutputReference, Transaction, find_input}
use cocktail/vodka_address.{address_pub_key, compare_address}
use contract/types.{TreasuryDatum, Deposit, End, Execute, Init, Mint, Signature, Spend}
use validation/find.{output_by_addr_value}

validator treasury(threshold: Int, allowance: Int) {
  mint(redeemer: Mint, policy_id: PolicyId, transaction: Transaction) {
    when redeemer is {
      Init -> True
      End -> True
    }
  }

  spend(
    datum_option: Option<TreasuryDatum>,
    redeemer: Spend,
    output_reference: OutputReference,
    transaction: Transaction,
  ) {
    expect Some(datum_input) = datum_option
    let Transaction { inputs, outputs, extra_signatories, .. } = transaction
    expect Some(input) = find_input(inputs, output_reference)
    let script_address = input.output.address
    let token =
      input.output.value
        |> without_lovelace()

    expect output = output_by_addr_value(outputs, script_address, token)

    when redeemer is {
      Deposit -> {
        expect InlineDatum(datum_output_raw) = output.datum
        expect datum_output: TreasuryDatum = datum_output_raw

        and {
          True,
          // datum_input.owners == datum_output.owners,
          // datum_input.signers == datum_output.signers,
          datum_input.receiver == 1,
        }
      }
      // lovelace_of(output.value) == lovelace_of(input.output.value),
      Execute -> True
      Signature -> {
        // let signers =
        //   list.filter(
        //     extra_signatories,
        //     fn(extra_signatory) {
        //       let extra_signatory_option = Some(extra_signatory)
        //       let is_owner =
        //         list.any(
        //           datum_input.owners,
        //           fn(owner) { address_pub_key(owner) == extra_signatory_option },
        //         )
        //       let already_signed =
        //         list.any(
        //           datum_input.signers,
        //           fn(signer) {
        //             address_pub_key(signer) == extra_signatory_option
        //           },
        //         )
        //       and {
        //         is_owner,
        //         !already_signed,
        //       }
        //     },
        //   )

        expect InlineDatum(inline_datum_output) = output.datum
        expect datum_output: TreasuryDatum = inline_datum_output
  
        and {
          True,
          // list.length(signers) > 0,
          // datum_input.owners == datum_output.owners,
          // datum_input.receiver == datum_output.receiver,
         list.length(datum_output.signers) == 1
        }
      }
    }
    // list.all(
    //   datum_input.signers,
    //   fn(signer) { list.has(datum_output.signers, signer) },
    // ),
    // lovelace_of(output.value) >= lovelace_of(input.output.value),
  }

  else(_) {
    fail
  }
}
