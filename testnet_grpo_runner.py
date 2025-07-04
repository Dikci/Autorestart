import logging
from dataclasses import dataclass
from functools import partial
from typing import Callable, Tuple

from datasets import Dataset
from trl import GRPOConfig, ModelConfig

from hivemind_exp.chain_utils import (
    SwarmCoordinator,
)
from hivemind_exp.runner.grpo_runner import GRPOArguments, GRPORunner
from hivemind_exp.trainer.gensyn.testnet_grpo_trainer import TestnetGRPOTrainer

logger = logging.getLogger(__name__)


@dataclass
class TestnetGRPOArguments:
    # Mutually exclusive.
    wallet_private_key: str | None = None  # EOA wallet private key.
    modal_org_id: str | None = None  # Modal organization ID.

    # Swarm coordinator contract address
    contract_address: str = ""


class TestnetGRPORunner(GRPORunner):
    def __init__(self, coordinator: SwarmCoordinator) -> None:
        self.coordinator = coordinator

    def get_initial_peers(self) -> list[str]:
        return self.coordinator.get_bootnodes()

    def register_peer(self, peer_id):
        logger.info(f"Registering self with peer ID: {peer_id}")
        self.coordinator.register_peer(peer_id)

    def setup_dht(self, grpo_args):
        dht = super().setup_dht(grpo_args)
        peer_id = str(dht.peer_id)
        self.register_peer(peer_id)
        return dht

    def run(self, model_args, grpo_args, training_args, initial_datasets_fn):
        # Игнорируем пиры из chain
        initial_peers = grpo_args.initial_peers
        if not initial_peers:
            initial_peers = []  # НЕ подтягиваем из chain
            logger.info("Ignoring peers from chain; using empty peer list")

        grpo_args.initial_peers = initial_peers
        super().run(
            model_args,
            grpo_args,
            training_args,
            initial_datasets_fn,
            partial(TestnetGRPOTrainer, coordinator=self.coordinator),
        )
