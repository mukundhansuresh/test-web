# Cookbook Name:: apache2
# Recipe:: default
#
# Copyright 2013, Intuit
#
# All rights reserved - Do Not Redistribute
#

puts "The httpd versio is #{node.default["httpd"]["version"]}"

# First, install Apache2 WebServer
package "httpd" do
  version node['httpd']['version']
  action :install
end

package "mod_ssl" do
  version node['mod_ssl']['version']
  action :install
end

## Check if we need this file??
cookbook_file "/etc/sysconfig/httpd" do
  source "sysconfig_httpd"       # this one doesnt use source_path
  mode "0444"
end

## Remove this block later, this is for testing if the Environment is set or not. This is tested good that the directory development is created under /etc
if node.chef_environment == "edge_dev"
   directory "/etc/development" do
     action :create
     owner "root"
     group "root"
     mode "0755"
   end
end

### Remove this block later, this is for testing if the default attribute from the environment file is seen here. The attribute is defined in the file edge_dev.json
 if node.default["startservers"] = 30
   puts "The Start Servers is 50"
end

### Remove this block later, this is for testing if the default attribute from the role file edge_web.json
if node.default["apache2"]["listen_ports"] == 80
   puts "The Port from the role file is #{node.default["apache2"]["listen_ports"]}"
end

# Create the directory to store all of the httpd conf
directory "/etc/httpd" do
  action :create
  owner "root"
  group "root"
  mode "0755"
end

# Create the directory to store httpd.conf file
directory "/etc/httpd/conf" do
  action :create
  owner "root"
  group "root"
  mode "0755"
end

# Create the conf.d folder (apparently doesn't get automatically create on httpd install)
directory "/etc/httpd/conf.d" do
  action :create
  owner "root"
  group "root"
  mode "0755"
end

# Create the Log directory for httpd
directory "/var/log/httpd" do
  action :create
  owner "root"
  group "root"
  mode "0755"
end

link "/etc/httpd/logs" do
  link_type :symbolic
  to  "/var/log/httpd"
end

# Create the Web Root directory for httpd
directory "/edge-www" do
  action :create
  owner "root"
  group "root"
  mode "0755"
end

link "/etc/httpd/modules" do
  link_type :symbolic
  to  "/usr/lib64/httpd/modules"
end

# Copy the required module, mod_jk.so
cookbook_file "/etc/httpd/modules/mod_jk.so" do
  source "mod_jk-1.2.31-httpd-2.2.x.so"
  mode "0644"
  owner "root"
  group "root"
end


# Then, copy all of the configuration files to it
template "/etc/httpd/conf/httpd.conf" do
  source "httpd.conf.erb"
  mode "0644"
  owner "root"
  group "root"
end

template "/etc/httpd/conf.d/httpd-vhosts.conf" do
  source "httpd-vhosts.conf.erb"
  mode "0644"
  owner "root"
  group "root"
end

template "/etc/httpd/conf/mime.types" do
  source "mime.types.erb"
  mode "0644"
  owner "root"
  group "root"
end

template "/etc/httpd/conf.d/mod_jk.conf" do
  source "mod_jk.conf.erb"
  mode "0644"
  owner "root"
  group "root"
end

## This block of code is to generate the VM's from the nodes json files
server_names = []
host_names = search(:node, "role:edge_app")
host_names.each do |appnode|
  ##puts "#{appnode.name}"
  server_names << appnode.name
end

##if node.roles.include?('web')
  template "/etc/httpd/conf.d/workers.properties" do
  source "workers.properties_web.erb"
  mode "0644"
  owner "root"
  group "root"
  variables({
    :app_server  => server_names,
    })
  ##end
end

# Copy the necessary files to allow health check and status checks
cookbook_file "/edge-www/edge_healthcheck.html" do
  source "edge_healthcheck.html"
  mode "0777"
  owner "root"
  group "root"
end

# Lastly, start the web server and make run in the background
service "httpd" do
  action [:enable, :start]
end
