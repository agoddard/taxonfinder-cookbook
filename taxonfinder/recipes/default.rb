#
# Cookbook Name:: taxonfinder
# Recipe:: default
#
# Copyright 2011, Woods Hole Marine Biological Laboratory
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

directory node[:taxonfinder][:directory] do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

remote_file "#{node[:taxonfinder][:directory]}/taxon-finder.tar.gz" do
  source "#{node[:taxonfinder][:src]}"
  mode "0644"
  checksum node[:taxonfinder][:checksum]
  action :create_if_missing
end

execute "untar-taxonfinder" do
  cwd node[:taxonfinder][:directory]
  command "tar --strip-components=1 -xzf #{node[:taxonfinder][:directory]}/taxon-finder.tar.gz"
end

template "#{node[:taxonfinder][:directory]}/config.pl" do
  source "config.pl.erb"
end

file "#{node[:taxonfinder][:directory]}/taxon-finder.tar.gz" do
  action :delete
end


template "/etc/init/taxonfinder.conf" do
  source 'upstart.conf.erb'
  notifies :restart, "service[taxonfinder]"
end


service "taxonfinder" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true
  action [ :enable, :start ]
end
