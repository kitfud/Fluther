# && lcov --remove lcov.info '/test/fuzz/*' -o lcov.info 
# && python ./clean_coverage_report.py
# forge coverage --mp "test/unit/*" --report lcov && genhtml lcov.info --branch-coverage --output-dir coverage

-include .env

ifeq ($(network),sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --broadcast --verify -vvvv
endif

ifeq ($(network),linea_goerli)
	NETWORK_ARGS := --rpc-url $(LINEA_GOERLI_RPC_URL) --broadcast --verify -vvvv
endif

run_coverage:;
	forge coverage --mp "test/unit/*" --report lcov

coverage_report:;
	genhtml lcov.info --branch-coverage --output-dir coverage

deploy:;
	forge script script/Deploy.s.sol $(NETWORK_ARGS)

deploy_mocks:;
	forge script script/DeployMocks.s.sol $(NETWORK_ARGS)

