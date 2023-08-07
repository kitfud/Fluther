# && lcov --remove lcov.info '/test/fuzz/*' -o lcov.info 
# && python ./clean_coverage_report.py
# forge coverage --mp "test/unit/*" --report lcov && genhtml lcov.info --branch-coverage --output-dir coverage

-include .env

run_coverage:;
	forge coverage --mp "test/unit/*" --report lcov

coverage_report:;
	genhtml lcov.info --branch-coverage --output-dir coverage

deploy:;
	forge script script/Deploy.s.sol --rpc-url $(SEPOLIA_RPC_URL) --broadcast --verify -vvvv

deploy_mocks:;
	forge script script/DeployMocks.s.sol --rpc-url $(SEPOLIA_RPC_URL) --broadcast --verify -vvvv