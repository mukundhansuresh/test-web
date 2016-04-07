# Cookbook Name:: apache2
# Recipe:: default
#
# Copyright 2013, Intuit
#
# All rights reserved - Do Not Redistribute
#


# First, install Apache2 WebServer
package "httpd" do
  version node['httpd']['version']
  action :install
end

#package "mod_ssl" do
 # version node['mod_ssl']['version']
  #action :install
#end

cookbook_file "/etc/sysconfig/httpd" do
  source "sysconfig_httpd"       # this one doesnt use source_path
  mode "0444"
end

if node.chef_environment == "dev"
   directory "/etc/development" do
     action :create
     owner "root"
     group "root"
     mode "0755"
   end
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

# Create the modules directory
#directory "/etc/httpd/modules" do
 # action :create
 # owner "root"
 # group "root"
 # mode "0755"
#end

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

template "/etc/httpd/conf.d/mod-jk.conf" do
  source "mod-jk.conf.erb"
  mode "0644"
  owner "root"
  group "root"
end

##if node.roles.include?('web')
  cookbook_file "/etc/httpd/conf.d/workers.properties" do
  source "workers.properties_web.erb"
  mode "0644"
  owner "root"
  group "root"
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
