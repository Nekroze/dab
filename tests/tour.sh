## vim: cc=78
# Hi! I will be your tour guide to The Developer Laboratory
# You can call me Clippy     Just kidding!
# This tour can be paused at any time with the space bar
export PS1='\[\e[35m\]\\$\[\e[m\] ' && set -e
# This will exit if any commands fail, everything I show you works!

# Installing Dab is just downloading a tiny wrapper script
whereis dab
# Here it has been done for us but the process is easy, promise
# Next time you run Dab after 24 hours it will update its image and wrapper
# You can disable this by setting $DAB_AUTOUPDATE=no

# The Dab CLI puts a tree of subcommands at your disposal
dab --help
# After an hour the next run will display a tip for using dab
# Subcommands are executed in the Dab docker image
# They can all take 'help', '--help', or '-h' for usage info
dab shell help
# This shell is the exact one all subcommands run from

# Dab provides various apps that you may find useful
dab apps start portainer
# Portainer is now accessible at the above URL
# Apps can easily be stopped to save resources
dab apps stop portainer
# Some apps have state (data) that can be wiped
dab apps destroy portainer
# The app config can also be displayed to see how it works
dab apps config redis
# In the config redis version is set with $DAB_APPS_REDIS_TAG
# Any environment variable prefixed with DAB_ will be passed into dab
# We can change this to any tag for the official redis image, for example
export DAB_APPS_REDIS_TAG=4-alpine
# There are many apps available to give you a jump start today
dab apps list

# The config is a tree stuctured key value store stored on disk
dab config set foo/bar 42
dab config get foo/bar
# Config keys and namespaces are actually directories and files
dab config set directory/file contents
# They are stored at $DAB_CONF_PATH if set or ~/.config/dab
ls ~/.config/dab/directory/
cat ~/.config/dab/directory/file
# Config keys and namespaces can be deleted by setting to nil
dab config set directory/file
ls ~/.config/dab/directory/
# Keys can also be lists, represented as multiple lines
dab config add foo/bar but what is the question
cat ~/.config/dab/foo/bar
# As the config should be seen as a tree lets display one
dab config tree
# This shows us all keys we can get
# When sharing the config you may want to set an env var
dab shell echo \$DAB_APPS_REDIS_TAG
dab config set environment/DAB_APPS_REDIS_TAG 4-alpine
# This will now be loaded at the start of each Dab run
dab shell echo \$DAB_APPS_REDIS_TAG

# Lets pretend you are a happy Nekroze working on subcommander
dab repo add subcommander https://github.com/Nekroze/subcommander.git
# This registers the repo with Dab allowing orchestration
# It also clones the repo into $DAB_REPO_PATH or ~/dab if unset
ls ~/dab/subcommander
# While developing subcommander we (should) run the test suite often
# Lets add an entrypoint to the repo to do that for us
dab repo entrypoint create subcommander test
dab repo entrypoint list subcommander
# Now we have a script where we can place the build incantation
dab config set repo/subcommander/entrypoint/test docker-compose run tests
# We can put anything we want in these entrypoints
# We can even run dab if we wanted to use apps for example
# Now after making several epic improvements we can...
dab repo entrypoint run subcommander test

# Since we are managing projects with Dab, lets start networking
docker network ls
# The lab docker network is instrumented by Dab in various ways
# You can deny internet access with $DAB_LAB_INTERNET=false
# The subnet can be configured, eg. $DAB_LAB_SUBNET=192.169.0.0/16
# Changing these will require recreating the network
dab network recreate
# Dab's has apps like traefik that can connect and share the lab network

# After a while enough repos can get unweildy
# Dab groups allow us to create a sequence of entrypoints to run
dab group repos TestAllProjects subcommander test
# We can do this again to add more repo entrypoints of any kind
# Then run we can start the group to run them all in sequence
dab group start TestAllProjects
# We can even get all meta and make groups of groups
dab group groups TestThenStartCluster TestAllProjects
# Lather, rinse, and repeat!

# With modern web projects we may need to use HTTPS certificates
# This can be difficult but Dab makes it really simple
# To make life easy Dab sets up a Public Key Infrastructure for you
dab pki ready
# This uses vault from the apps to create a CA certificate
# This certificate will persist for your config's lifetime
cat ~/.config/dab/pki/ca/certificate
# This is a standard PEM encoded X509 CA certificate
# Dab will attempt to find any local browsers and trust the CA
# Now we can create web certificates whenever we want
dab pki issue web.example.com
# This same command can renew the certificate when it expires
# Then you can use the certificate in your entrypoints for SSL
dab config get pki/web.example.com/key
# The PKI is backed by vault and can be erased at any time
dab pki destroy
# The next time you ready the vault it will be brand new

# Interested in Dab? Head to https://github.com/Nekroze/dab
