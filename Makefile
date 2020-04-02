build:
	./mvnw clean install -U -P sonar
xdocs:
	./mvnw clean verify -U -P docs
release-clean:
	./mvnw -s settings.xml clean release:clean
release-prepare:
	./mvnw -s settings.xml clean release:prepare
release-promote:
	@read -p "Sonatype Password: " passwd; \
	./mvnw -s settings.xml clean release:promote -DsonatypeUser=developerbhuwan -DsonatypePassword=$${passwd}
gen-gpg:
	gpg --full-generate-key
export-gpg:
	cd ${HOME}/.gnupg && \
	gpg --export-secret-keys -o secring.gpg
publish-gpg-key:
	gpg -K
	@read -p "Gpg Key Id: " keyId; \
	gpg --send-keys --keyserver keyserver.ubuntu.com $${keyId}