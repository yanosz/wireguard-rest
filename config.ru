require 'rubygems'
require 'sinatra'
require File.expand_path '../web.rb', __FILE__

unless File.exists? "db/regs.db"
  puts "Init Database" 
  FileUtils.copy_file "db/regs.db.template", "db/regs.db"
end

unless File.exists? "conf/rest.conf.erb.template"
  puts "Init wireguard config template"
  FileUtils.copy_file "conf/rest.conf.erb.template", "rest.conf.erb"
end

run Sinatra::Application
