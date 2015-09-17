require 'forwardable'
require 'gir_ffi/registered_type_base'

module GirFFI
  # Base class for all generated classes and structs. Contains code for dealing
  # with the generated nested Struct classes.
  class ClassBase
    extend RegisteredTypeBase
    extend Forwardable

    attr_reader :struct
    def_delegators :@struct, :to_ptr

    def setup_and_call(method, arguments, &block)
      method_name = self.class.try_in_ancestors(:setup_instance_method, method.to_s)

      unless method_name
        raise "Unable to set up instance method '#{method}' in #{self}"
      end

      send method_name, *arguments, &block
    end

    # NOTE: JRuby should fix FFI::MemoryPointer#== to return true for
    # equivalent FFI::Pointer. For now, user to_ptr.address
    def ==(other)
      other.class == self.class && to_ptr.address == other.to_ptr.address
    end

    def self.setup_and_call(method, arguments, &block)
      method_name = try_in_ancestors(:setup_method, method.to_s)

      unless method_name
        raise "Unable to set up method '#{method}' in #{self}"
      end

      send method_name, *arguments, &block
    end

    def self.try_in_ancestors(method, *arguments)
      ancestors.each do |klass|
        if klass.respond_to?(method)
          result = klass.send(method, *arguments)
          return result if result
        end
      end
    end

    def self.to_ffi_type
      self::Struct
    end

    def self.setup_method(name)
      gir_ffi_builder.setup_method name
    end

    def self.setup_instance_method(name)
      gir_ffi_builder.setup_instance_method name
    end

    class << self
      undef new
    end

    # Wrap the passed pointer in an instance of the current class, or a
    # descendant type if applicable.
    def self.wrap(ptr)
      direct_wrap ptr
    end

    # Wrap the passed pointer in an instance of the current class. Will not
    # do any casting to subtypes or additional processing.
    def self.direct_wrap(ptr)
      return nil if !ptr || ptr.null?
      obj = allocate
      obj.__send__ :assign_pointer, ptr
      obj
    end

    # Pass-through casting method. This may become a type checking
    # method. It is overridden by GValue to implement wrapping of plain
    # Ruby objects.
    def self.from(val)
      val
    end

    private

    # Stores a pointer created by a constructor function. Derived classes may
    # perform additional processing. For example, InitiallyUnowned overrides it
    # to sink the floating object.
    #
    # This method assumes the pointer will always be of the type corresponding
    # to the current class, and never of a subtype.
    #
    # @param ptr Pointer to the object's C structure
    def store_pointer(ptr)
      assign_pointer ptr
    end

    def assign_pointer(ptr)
      @struct = self.class::Struct.new(ptr)
    end
  end
end
