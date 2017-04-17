require 'yaml'
require 'pathname'
require 'cz/file_proxy'

module CZ

  class Config < BasicObject
    Error = ::Class.new(::StandardError)
    MissingKeyError = ::Class.new(Error)

    attr_reader :_hash
    protected   :_hash

    MERGE = -> (_k, v1, v2) {
      Config === v1 && Config === v2 ? v1.merge(v2, &MERGE) : v2
    }

    INDEX = /\A-?\d+\z/

    private_constant :MERGE, :INDEX

    def self.load(*args)
      args.reduce(self.new) { |config, obj| config.merge(obj) }
    end

    def initialize(hash = {})
      @_hash = ::Hash[
        hash.map { |k, v|
          [k.to_s, ::Hash === v ? ::CZ::Config(v) : v]
        }
      ]
    end

    def each(&block)
      @_hash.each(&block)
    end

    def fetch(key, default: :exception)
      key = key.to_s
      result = if default == :exception
                 @_hash.fetch(key)
               else
                 @_hash.fetch(key, default)
               end
      result
    rescue ::KeyError
      ::Object.send :raise, MissingKeyError, "Missing key: #{key}"
    end

    def [](key, default: :exception)
      head, *tail = *key.to_s.split('/')
      result = fetch(head, default: default)
      while ::CZ::Config === result && tail.any?
        head, *tail = *tail
        result = result.fetch(head, default: default)
      end
      if tail.any?
        key = tail.join('/')
        if (::Array === result and INDEX.match key)
          result = result[key.to_i]
        else
          result = default
        end
      end
      result
    end

    def inspect
      "#<CZ::Config #{@_hash.inspect}>"
    end
    alias to_s inspect

    def merge(other)
      other = ::CZ::Config(other)
      Config.new(@_hash.merge(other._hash, &MERGE))
    end

    def respond_to?(method_id, include_private = false)
      @_hash.key?(method_id.to_s) ||
        INSTANCE_METHODS[!!include_private].include?(method_id.to_sym)
    end

    private

    def respond_to_missing?(method_id, include_private = false)
      @_hash.key?(method_id.to_s) or super
    end

    def method_missing(method_id, *args, &block)
      if args.empty?
        self.fetch(method_id)
      else
        super
      end
    end

    # We cache these to make respond_to? more efficient when called
    INSTANCE_METHODS = {
      true  => Config.instance_methods + Config.private_instance_methods,
      false => Config.public_instance_methods
    }

  end

  def self.Config(obj)
    case obj
    when Config
      obj
    when Hash
      Config.new(obj)
    when String, Pathname
      if File.directory?(obj)
        Config.new(_config_dir(obj))
      else
        Config.new(YAML.load_file(obj))
      end
    else
      raise TypeError, "Can't create CZ::Config from object: #{obj.inspect}"
    end
  end

  def self._config_dir(base)
    base = Pathname(base)
    Dir.entries(base).
      reject { |entry| entry == '.' || entry == '..' }.
      reduce({}) { |dir, entry|
        path = base + entry
        if File.directory?(path)
          dir[entry] = _config_dir(path)
        else
          dir[entry] = FileProxy.new(path)
        end
        dir
      }
  end
  private_class_method :_config_dir

end
