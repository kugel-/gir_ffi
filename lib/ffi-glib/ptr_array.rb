module GLib
  load_class :PtrArray

  # Overrides for GPtrArray, GLib's automatically growing array of
  # pointers.
  class PtrArray
    include Enumerable

    attr_accessor :element_type

    def self.new type
      wrap(::GLib::Lib.g_ptr_array_new).tap {|it|
        it.element_type = type}
    end

    def self.add array, data
      array.add data
    end

    def add data
      ptr = GirFFI::ArgHelper.cast_to_pointer element_type, data
      ::GLib::Lib.g_ptr_array_add self, ptr
    end

    def each
      prc = Proc.new {|valptr, userdata|
        val = GirFFI::ArgHelper.cast_from_pointer element_type, valptr
        yield val
      }
      ::GLib::Lib.g_ptr_array_foreach self.to_ptr, prc, nil
    end
  end
end
