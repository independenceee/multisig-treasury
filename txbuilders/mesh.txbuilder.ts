import { MeshAdapter } from "../adapters/mesh.adapter";
import { APP_NETWORK } from "../constants/enviroments.constant";
import { deserializeAddress, mConStr0 } from "@meshsdk/core";

export class MeshTxBuilder extends MeshAdapter {
    deposit = async ({
        proposal,
        quantity,
    }: {
        proposal: {
            amount: number;
            receiver: string;
            signatures: string[];
        };
        quantity: string;
    }): Promise<string> => {
        const { utxos, walletAddress, collateral } = await this.getWalletForTx();
        const utxo = null;

        const unsignedTx = this.meshTxBuilder;

        if (utxo) {
        } else {
            unsignedTx
                .txOut(this.spendAddress, [
                    {
                        unit: "lovelace",
                        quantity: quantity,
                    },
                ])
                .txOutInlineDatumValue(
                    mConStr0([
                        BigInt(proposal.amount),
                        mConStr0([deserializeAddress(proposal.receiver).pubKeyHash, deserializeAddress(proposal.receiver).stakeCredentialHash]),
                        proposal.signatures.map((signature) =>
                            mConStr0([deserializeAddress(signature).pubKeyHash, deserializeAddress(signature).stakeCredentialHash]),
                        ),
                    ]),
                );
        }
        unsignedTx
            .selectUtxosFrom(utxos)
            .changeAddress(walletAddress)
            .requiredSignerHash(deserializeAddress(walletAddress).pubKeyHash)
            .txInCollateral(collateral.input.txHash, collateral.input.outputIndex)
            .setNetwork(APP_NETWORK);

        return await unsignedTx.complete();
    };

    signature = async (): Promise<string> => {
        const { utxos, walletAddress, collateral } = await this.getWalletForTx();

        const unsignedTx = this.meshTxBuilder;

        unsignedTx
            .selectUtxosFrom(utxos)
            .changeAddress(walletAddress)
            .requiredSignerHash(deserializeAddress(walletAddress).pubKeyHash)
            .txInCollateral(collateral.input.txHash, collateral.input.outputIndex)
            .setNetwork(APP_NETWORK);
        return await unsignedTx.complete();
    };

    execute = async (): Promise<string> => {
        const { utxos, walletAddress, collateral } = await this.getWalletForTx();

        const unsignedTx = this.meshTxBuilder;

        unsignedTx
            .selectUtxosFrom(utxos)
            .changeAddress(walletAddress)
            .requiredSignerHash(deserializeAddress(walletAddress).pubKeyHash)
            .txInCollateral(collateral.input.txHash, collateral.input.outputIndex)
            .setNetwork(APP_NETWORK);
        return await unsignedTx.complete();
    };
}
