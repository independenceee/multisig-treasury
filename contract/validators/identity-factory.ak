use aiken/collection/dict
use aiken/collection/list
use cardano/address.{Address}
use cardano/assets.{AssetName, PolicyId, lovelace_of}
use cardano/transaction.{InlineDatum, Transaction}
use contract/types.{Datum, End, Init, Mint}

/// ─────────────────────────────────────────────────────────────────────────────
/// Identity Factory – Minting Policy
///
/// This policy controls the lifecycle of an identity token:
///
/// Init:
///   • Mint exactly 1 identity token
///   • Send it to the treasury address
///   • Attach an inline datum with an empty signer list
///
/// End:
///   • Burn the identity token
///   • Require a minimum number of signers (threshold)
///   • Transfer ADA from the treasury to the receiver
///   • Ensure the transferred ADA does not exceed the allowance
/// ─────────────────────────────────────────────────────────────────────────────
validator identity_factory(
  threshold: Int,
  allowance: Int,
  treasury: Address,
  token_name: AssetName,
) {
  mint(redeemer: Mint, policy_id: PolicyId, transaction: Transaction) {
    let Transaction { inputs, outputs, mint, .. } = transaction
    expect [Pair(asset_name, amount)] =
      mint
        |> assets.tokens(policy_id)
        |> dict.to_pairs()

    when redeemer is {
      Init -> {
        let treasury_output =
          list.find(outputs, fn(out) { out.address == treasury })
        when treasury_output is {
          Some(output) ->
            when output.datum is {
              InlineDatum(datum_output_raw) -> {
                expect datum_output: Datum = datum_output_raw
                and {
                  amount == 1,
                  asset_name == token_name,
                  list.length(datum_output.signers) == 0,
                }
              }
              _ -> False
            }

          None -> False
        }
      }
      End -> {
        let treasury_input =
          list.find(inputs, fn(input) { input.output.address == treasury })
        when treasury_input is {
          Some(input) ->
            when input.output.datum is {
              InlineDatum(datum_input_raw) ->
                if datum_input_raw is datum_input: Datum {
                  let receiver_output =
                    list.find(
                      outputs,
                      fn(out) { out.address == datum_input.receiver },
                    )
                  when receiver_output is {
                    Some(output) -> and {
                        amount == -1,
                        asset_name == token_name,
                        list.length(datum_input.signers) >= threshold,
                        lovelace_of(input.output.value) == lovelace_of(
                          output.value,
                        ),
                        lovelace_of(output.value) <= allowance,
                      }
                    None -> False
                  }
                } else {
                  False
                }
              _ -> False
            }
          None -> False
        }
      }
    }
  }

  else(_) {
    fail
  }
}
