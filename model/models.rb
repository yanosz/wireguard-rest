require 'active_record'
require 'sqlite3'
require 'ipaddr'


ActiveRecord::Base.establish_connection(
    :adapter  => 'sqlite3',
    :database => 'db/regs.db'
)

class KeyRegistration < ActiveRecord::Base
  # Fields: id, pubkey, document, disabled, created_at, updated_at

  def self.settings=(value)
    @@settings = value
  end

  validates_uniqueness_of :pubkey
  validates :pubkey, format: {
      with: /[A-Za-z0-9+\/]+={0,3}/,
      message: "Invalid public key"}
  validate :is_valide_curve25519

  def is_valide_curve25519
    # This doesn't fail, if additional chars are present
    unless self.pubkey.unpack("m*")[0].length == 32
      errors.add :pubkey, "Invalid Public key: Base64 check fail"
    end

    #Strict checking by repacking
    unless self.pubkey.unpack("m*").pack("m*").gsub(/\n/,'') == self.pubkey
      errors.add :pubkey, "Invalid Public key: Base64 repack fail: '#{self.pubkey.unpack("m*").pack("m*").gsub(/\n/,'') }'"
    end

  end


  def client_networks_str
    ipv4_i = IPAddr.new(@@settings.ipv4)
    ipv6_i = IPAddr.new(@@settings.ipv6)

    ipv4 = IPAddr.new(ipv4_i.to_i + 2*self.id, Socket::AF_INET)
    ipv6 = IPAddr.new(ipv6_i.to_i + 2*self.id, Socket::AF_INET6)

    return "#{ipv4},#{ipv6}/128"

  end

end
