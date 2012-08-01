#
# Cookbook Name:: taxonfinder
# Recipe:: load_balancer
#
# Copyright 2012, Woods Hole Marine Biological Laboratory
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

include_recipe 'haproxy'

pool_members = search(:node, 'taxonfinder_pool_member:true')

pool_members.map! do |member|
  {:ipaddress => member['ipaddress'], :hostname => member['hostname'], :port => member['taxonfinder']['port']}
end




template "/etc/haproxy/haproxy.cfg" do
  source "haproxy-taxonfinder.cfg.erb"
  owner "root"
  group "root"
  mode 0644
  variables :pool_members => pool_members.uniq
  notifies :restart, "service[haproxy]"
end
