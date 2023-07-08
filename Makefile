-include .env

deploy:
	@forge script script/deployFundMe.s.sol --rpc-url ${RPC_URL} --private-key ${PRIVATE_KEY} --broadcast

deployAlchemy:
	@forge script script/deployFundMe.s.sol --rpc-url ${ALCHEMY_RPC_URL} --private-key ${PRIVATE_KEY_for_Alchemy} --broadcast

