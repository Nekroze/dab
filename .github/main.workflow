workflow "Tests" {
  on = "push"
  resolves = ["GitHub Action for Docker"]
}

action "GitHub Action for Docker" {
  uses = "actions/docker/cli@76ff57a"
  args = "./scripts/docker-dind-wrapper.sh ./scripts/docker-compose-wrapper.sh ./scripts/test.sh"
  runs = "/bin/sh"
}
