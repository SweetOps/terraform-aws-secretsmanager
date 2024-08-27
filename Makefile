terratest:
	cd tests; go mod tidy; go test -v -count=1 ./...; cd -
