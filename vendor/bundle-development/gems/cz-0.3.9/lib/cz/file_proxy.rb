require 'pathname'

module CZ
  class FileProxy < BasicObject

    def initialize(path)
      @path = ::Kernel.Pathname(path).realpath
    end

    def path
      @path.relative_path_from(::Pathname.getwd)
    end

    def absolute_path
      @path
    end

    def loaded?
      defined?(@content)
    end

    def ==(other)
      FileProxy === other ? content == other.content : content == other
    end

    def content
      @content ||= ::File.binread(@path)
    end

    def inspect
      "#<CZ::FileProxy #{@path}>"
    end

    def respond_to?(method_id, include_private = false)
      INSTANCE_METHODS[!!include_private].include?(method_id.to_sym) ||
        content.respond_to?(method_id, include_private)
    end

    private

    def respond_to_missing?(method_id, include_private = false)
      content.respond_to?(method_id, include_private) or super
    end

    def method_missing(method_id, *args, &block)
      if content.respond_to?(method_id)
        content.send(method_id, *args, &block)
      else
        super
      end
    end

    # We cache these to make respond_to? more efficient when called
    INSTANCE_METHODS = {
      true  => FileProxy.instance_methods + FileProxy.private_instance_methods,
      false => FileProxy.public_instance_methods
    }
  end
end
