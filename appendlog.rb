require 'open3'
require 'openssl'
require 'base64'
require 'json'
require_relative 'tictac'
module TicTac
  class AppendLog
    attr_reader :config

    def initialize(initial_state: nil, config: DefaultConfig)
      @config = config
      @pkey=OpenSSL::PKey::RSA.new(File.read(config.private_key))
      @log=[]
      if initial_state.nil?
        obj={last_log: nil, payload: ''}
        @log.push(signed_obj(obj))
      else
        #TODO verification of chain so far
      end
      
    end
    def verify_entry(log_entry)
      
    end
    def new_entry(obj)
      last_payload=JSON.parse(%x(ipfs cat #{@log.last}),symbolize_names: true)
      obj[:last_log]=@log.last
      sobj=signed_obj(obj)
      @log.push(sobj).last
    end
    def signed_obj(obj)
      json_obj=JSON.dump(obj)
      signature=Base64.strict_encode64(@pkey.sign(OpenSSL::Digest::SHA256.new,json_obj))
      signed_obj=JSON.dump(payload: Base64.strict_encode64(json_obj),
                  signature: signature,
                  signer: File.read(config.public_key)
                           )
      ipfs_add(signed_obj)
    end

    private

    def ipfs_add(str)
      Open3.popen3("ipfs add -Q") do | i,o,e|
        i.write(str);i.close;o.read
      end
    end
  end
end
a=TicTac::AppendLog.new
print a.new_entry({"hello":"World"})
  
