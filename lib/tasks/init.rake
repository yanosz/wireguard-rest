namespace :init do
  desc "Initialize wg-rest.conf"
  task wg_conf: :environment do
    KeyRegistration.write_config_file

  end

end
