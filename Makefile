.PHONY: lint-md fmt-md lint fmt run-cc headroom-perf rtk-gain

lint-md:
	markdownlint --dot .

lint: lint-md

fmt-md:
	markdownlint --dot --fix .

fmt: fmt-md

headroom-perf:
	headroom perf

rtk-gain:
	rtk gain

run-cc:
	headroom wrap claude