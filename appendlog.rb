require 'open3'
require 'openssl'
require 'base64'
require 'json'
require_relative 'tictac'
module TicTac
  class Block
    def initialize(ipfs_addr)
      @block=JSON.parse(%x(ipfs cat #{ipfs_addr}),symbolize_names: true)
      @payload=Base64.decode64(@block[:payload])
      @signature=Base64.decode64(@block[:signature])
      @signer=@block[:signer]
      @prev=@block[:prev]
    end
    def signed?
      key=OpenSSL::PKey::RSA.new(@signer)
      digest_algo=OpenSSL::Digest::SHA256.new
      key.verify(digest_algo,@signature, @payload)
    end
  end
    
  class AppendLog

    def initialize(initial_state: nil, config: DefaultConfig)
      @config = config

      if initial_state.nil?
        obj={prev: nil, payload: ''}
        push(insert_signed_obj(obj))
      else
        #TODO verification of chain so far
      end
      
    end

    def verify_entry(log_entry)
      proposed_head=JSON.parse(%x(ipfs cat #{log_entry}),symbolize_names: true)
      payload=Base64.base64decode(proposed_head['payload'])
      proposed_head['signature']
    end

    def new_entry(obj)
      last_payload=JSON.parse(%x(ipfs cat #{@log.last}),symbolize_names: true)
      obj[:prev]=last_entry
      sobj=insert_signed_obj(obj)
      push(sobj)
    end

    def insert_signed_obj(obj)
      json_obj=JSON.dump(obj)
      signature=Base64.strict_encode64(pkey.sign(OpenSSL::Digest::SHA256.new,json_obj))
      signed_obj=JSON.dump(payload: Base64.strict_encode64(json_obj),
                  signature: signature,
                  signer: File.read(config.public_key)
                           )
      ipfs_add(signed_obj)
    end

    private

    attr_reader :config

    attr_accessor :last_entry

    def log
      @log ||= []
    end

    def pkey
      @pkey ||= OpenSSL::PKey::RSA.new(File.read(config.private_key))
    end

    def push(obj)
      last_entry = obj
      log.push(obj) if config.store_log
      obj
    end

    def ipfs_add(str)
      Open3.popen3("ipfs add -Q") do | i,o,e|
        i.write(str);i.close;o.read
      end
    end
  end
end
a=TicTac::AppendLog.new
print TicTac::Block.new(a.new_entry({"hello":"World"})).signed?
  
