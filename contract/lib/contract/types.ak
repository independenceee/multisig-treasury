use aiken/crypto.{VerificationKeyHash}
use cardano/address.{Address}

pub type TreasuryDatum {
  receiver: Int,
  owners: List<Address>,
  signers: List<Address>,
}

pub type Mint {
  Init
  End
}

pub type Spend {
  Deposit
  Execute
  Signature
}
