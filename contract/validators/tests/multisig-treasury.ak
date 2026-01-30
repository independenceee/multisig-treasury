use cardano/address.{Address}
use cardano/assets.{AssetName, PolicyId, add, from_asset, from_lovelace}
use cardano/transaction.{InlineDatum, Input, Transaction, OutputReference}
use contract/types.{Datum, Deposit, Execute, Signature, Spend}
use mocktail.{
  add_input, complete, mint, mock_policy_id, mock_pub_key_address,
  mock_pub_key_hash, mock_script_address, mock_script_output, mock_utxo_ref,
  mocktail_tx, required_signer_hash, tx_out, tx_out_inline_datum,
}
use multisig_treasury

test test_deposit_accepts_when_balance_increases() {
  let redeemer: Spend = Deposit

  let threshold: Int = 1
  let allowance: Int = 10_000_000

  let policy_id: PolicyId = mock_policy_id(0)
  let asset_name: AssetName = "Aiken Course 2026"

  let spend_address: Address = mock_script_address(0, None)
  let output_reference: OutputReference = mock_utxo_ref(0, 0)

  let receiver_input: Address = mock_pub_key_address(1, None)

  let owner1_input: Address = mock_pub_key_address(1, None)
  let owner2_input: Address = mock_pub_key_address(2, None)
  let owner3_input: Address = mock_pub_key_address(3, None)
  let owners_input: List<Address> = [owner1_input, owner2_input, owner3_input]

  let signer1_input: Address = mock_pub_key_address(1, None)
  let signer2_input: Address = mock_pub_key_address(2, None)
  let signer3_input: Address = mock_pub_key_address(3, None)
  let signers_input: List<Address> =
    [signer1_input, signer2_input, signer3_input]

  let datum_input =
    Datum {
      receiver: receiver_input,
      owners: owners_input,
      signers: signers_input,
    }

  // datum_output
  let receiver_output: Address = mock_pub_key_address(1, None)

  let owner1_output: Address = mock_pub_key_address(1, None)
  let owner2_output: Address = mock_pub_key_address(2, None)
  let owner3_output: Address = mock_pub_key_address(3, None)
  let owners_output: List<Address> =
    [owner1_output, owner2_output, owner3_output]

  let signer1_output: Address = mock_pub_key_address(1, None)
  let signer2_output: Address = mock_pub_key_address(2, None)
  let signer3_output: Address = mock_pub_key_address(3, None)
  let signers_output: List<Address> =
    [signer1_output, signer2_output, signer3_output]

  let datum_output =
    Datum {
      receiver: receiver_output,
      owners: owners_output,
      signers: signers_output,
    }

  let tx: Transaction =
    mocktail_tx()
      |> mint(True, 1, policy_id, asset_name)
      |> tx_out(
          True,
          spend_address,
          from_asset(policy_id, asset_name, 1)
            |> add("", "", 20_000_000),
        )
      |> tx_out_inline_datum(True, datum_input)
      |> required_signer_hash(True, mock_pub_key_hash(3))
      |> complete()
      |> add_input(
          True,
          Input {
            output_reference,
            output: mock_script_output(
              spend_address,
              from_asset(policy_id, asset_name, 1)
                |> add("", "", 20_000_000),
              InlineDatum(Some(datum_output)),
            ),
          },
        )

  multisig_treasury.multisig_treasury.spend(
    threshold,
    allowance,
    Some(datum_input),
    redeemer,
    output_reference,
    tx,
  )
}
