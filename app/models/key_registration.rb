require 'yaml'

class KeyRegistration < ActiveRecord::Base
  @@settings ||= YAML.load(File.read("#{Rails.root}/config/app.yml"))
  after_create :update_conf
  after_destroy :update_conf

  validates_uniqueness_of :pubkey
  validates_uniqueness_of :account

  validates :pubkey, format: {
      with: /[A-Za-z0-9+\/]+={0,3}/,
      message: "Invalid public key"}
  validate :is_valide_curve25519

  def is_valide_curve25519
    # This doesn't fail, if additional chars are present
    unless self.pubkey.unpack("m*")[0].length == 32
      errors.add :pubkey, "Invalid Public key"
    end

    #Strict checking by repacking
    unless self.pubkey.unpack("m*").pack("m*").gsub(/\n/,'') == self.pubkey
      errors.add :pubkey, "Invalid Public key"
    end

  end


  def client_networks_str
    networks = []

    if @@settings["ipv4"]
      ipv4_i = IPAddr.new(@@settings["ipv4"])
      networks << IPAddr.new(ipv4_i.to_i + 2*self.id, Socket::AF_INET).to_s
    end

    if @@settings["ipv6"]
      ipv6_i = IPAddr.new(@@settings["ipv6"])
      networks << IPAddr.new(ipv6_i.to_i + 2*self.id, Socket::AF_INET6).to_s
    end

    if @@settings["ipv6_pd"]
      ipv6_pd_i = IPAddr.new(@@settings["ipv6_pd"]["base"])
      ipv6_s_i = @@settings["ipv6_pd"]["size"].to_i
      offset = 2**(128-ipv6_s_i)
      ipv6_pd = IPAddr.new(ipv6_pd_i.to_i + (self.id-1)*offset, Socket::AF_INET6)
      networks << "#{ipv6_pd}/#{ipv6_s_i}"
    end

    return networks.join ","

  end



  def update_conf
    Thread.new {KeyRegistration.write_config_file}
  end

  def self.write_config_file
    logger.info "Writing config file #{@@settings["config_file"]}"
    begin
      template = File.read("#{Rails.root}/config/rest.conf.erb")
      secret_key = File.read(@@settings["secret_key_file"])
      vars = {priv_key: secret_key, peers: KeyRegistration.all}
      File.open(@@settings["config_file"], 'w') do  |f|
        f.flock(File::LOCK_EX)
        f << ERB.new(template).result(OpenStruct.new(vars).instance_eval { binding })
        f.chmod 0700
      end
      system(@@settings["wg_reload_cmd"])
    rescue Exception => e
      logger.error "Error writing config file #{e.message}"
    end
  end
end
