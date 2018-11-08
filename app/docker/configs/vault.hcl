ui = true

storage "consul" {
	address = "consul:8500"
	scheme = "http"
	service_tags = "dab"
}

listener "tcp" {
	address = "0.0.0.0:8200"
	tls_disable = 1
}
