require "sinatra"
require "sinatra/config_file"
require './model/models.rb'
require 'erb'
config_file 'conf/app.yml'
KeyRegistration.settings = settings

get '/' do
  KeyRegistration.all.to_json
end

post '/' do
  pubkey = params['pubkey']
  
  if k = KeyRegistration.find_by(pubkey: params['pubkey'])
    status 202
    body k.client_networks_str
  else  
    k = KeyRegistration.find_or_create_by(pubkey: params['pubkey'])

    if k.valid?
      logger.info "Uploaded #{pubkey} - Networks:"
      status 201
      body k.client_networks_str
      Thread.new { write_config_file }
    else
      status 400
      logger.error "Invalid public key #{pubkey}"
      body k.errors.values.to_json
    end
  end
end

private
def write_config_file
  logger.info "Writing config file"
  begin
    template = File.read("conf/rest.conf.erb")
    secret_key = File.read(settings.secret_key_file)
    vars = {priv_key: secret_key, peers: KeyRegistration.where("disabled is null or disabled = 0")}
    File.open(settings.config_file, 'w') do  |f|
      f.flock(File::LOCK_EX)
      f << ERB.new(template).result(OpenStruct.new(vars).instance_eval { binding })
      f.chmod 0700
    end
    logger.info "Reloading configuration - output (if any):#{`#{settings.wg_reload_cmd}`}"
  rescue Exception => e
    logger.error e
  end
end
