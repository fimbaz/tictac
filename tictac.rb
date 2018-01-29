require 'fileutils'
module TicTac
  Config = Struct.new(:ipfs_path, :tictac_dir, :private_key, :public_key, :empty_log, :store_log)

  DefaultConfig = begin
    ipfs_path = ENV['IPFS_PATH'] ? ENV['IPFS_PATH'] : File.absolute_path("#{ENV['HOME']}/.ipfs")
    Config.new(
      ipfs_path,
      "#{ipfs_path}/tictac",
      "#{ipfs_path}/tictac/self.pem",
      "#{ipfs_path}/tictac/self.pub",
      "QmbJWAESqCsf4RFCqEY7jecCashj8usXiyDNfKtZCwwzGb",
      true
    )
  end


end
