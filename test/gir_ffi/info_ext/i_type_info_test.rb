require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::ITypeInfo do
  let(:klass) { Class.new do
    include GirFFI::InfoExt::ITypeInfo
  end }
  let(:type_info) { klass.new }
  let(:elmtype_info) { klass.new }
  let(:keytype_info) { klass.new }
  let(:valtype_info) { klass.new }

  describe "#to_ffitype" do
    it "returns an array with elements subtype and size for type :array" do
      mock(type_info).pointer? { false }
      stub(type_info).tag { :array }
      mock(type_info).array_fixed_size { 2 }

      mock(elmtype_info).to_ffitype { :foo }
      mock(type_info).param_type(0) { elmtype_info }

      result = type_info.to_ffitype
      assert_equal [:foo, 2], result
    end

    describe "for an :interface type" do
      let(:iface) { Object.new }
      before do
        stub(type_info).interface { iface }
        stub(type_info).tag { :interface }
        stub(type_info).pointer? { false }
      end

      it "maps a the interface's ffitype" do
        stub(iface).to_ffitype { :foo }

        type_info.to_ffitype.must_equal :foo
      end
    end
  end

  describe "#element_type" do
    it "returns the element type for lists" do
      mock(elmtype_info).tag { :foo }
      mock(elmtype_info).pointer? { false }

      mock(type_info).tag {:glist}
      mock(type_info).param_type(0) { elmtype_info }

      result = type_info.element_type
      result.must_equal :foo
    end

    it "returns the key and value types for ghashes" do
      mock(keytype_info).tag { :foo }
      mock(keytype_info).pointer? { false }
      mock(valtype_info).tag { :bar }
      mock(valtype_info).pointer? { false }

      mock(type_info).tag {:ghash}
      mock(type_info).param_type(0) { keytype_info }
      mock(type_info).param_type(1) { valtype_info }

      result = type_info.element_type
      result.must_equal [:foo, :bar]
    end

    it "returns nil for other types" do
      mock(type_info).tag {:foo}

      result = type_info.element_type
      result.must_be_nil
    end

    it "returns [:pointer, :void] if the element type is a pointer with tag :void" do
      stub(elmtype_info).tag_or_class { [:pointer, :void] }

      mock(type_info).tag {:glist}
      mock(type_info).param_type(0) { elmtype_info }

      assert_equal [:pointer, :void], type_info.element_type
    end
  end

  describe "#flattened_tag" do
    describe "for a simple type" do
      it "returns the type tag" do
        stub(type_info).tag { :uint32 }

        type_info.flattened_tag.must_equal :uint32
      end
    end

    context "for a zero-terminated array" do
      before do
        stub(type_info).tag { :array }
        stub(type_info).param_type(0) { elmtype_info }
        stub(type_info).zero_terminated? { true }
      end

      context "of utf8" do
        it "returns :strv" do
          stub(elmtype_info).tag { :utf8 }
          stub(elmtype_info).pointer? { true }

          type_info.flattened_tag.must_equal :strv
        end
      end

      context "of filename" do
        it "returns :strv" do
          stub(elmtype_info).tag { :filename }
          stub(elmtype_info).pointer? { true }

          type_info.flattened_tag.must_equal :strv
        end
      end

      context "of another type" do
        it "returns :zero_terminated" do
          stub(elmtype_info).tag { :foo }
          stub(elmtype_info).pointer? { false }

          type_info.flattened_tag.must_equal :zero_terminated
        end
      end
    end

    describe "for a fixed length c-like array" do
      it "returns :c" do
        mock(type_info).tag { :array }
        mock(type_info).zero_terminated? { false }
        mock(type_info).array_type { :c }

        type_info.flattened_tag.must_equal :c
      end
    end

  end

  describe "#subtype_tag_or_class_name" do
    describe "without a parameter" do
      it "returns the result of calling #tag_or_class_name on the first param_type" do
        mock(elmtype_info).tag_or_class_name { ":foo" }

        mock(type_info).param_type(0) { elmtype_info }

        type_info.subtype_tag_or_class_name.must_equal ":foo"
      end
    end
  end

  describe "#subtype_tag_or_class" do
    describe "without a parameter" do
      it "returns the result of calling #tag_or_class on the first param_type" do
        mock(elmtype_info).tag_or_class { :foo }

        mock(type_info).param_type(0) { elmtype_info }

        type_info.subtype_tag_or_class.must_equal :foo
      end
    end
  end

  describe "#tag_or_class_name" do
    describe "for the simple type :foo" do
      it "returns the string ':foo'" do
        mock(type_info).tag { :foo }
        mock(type_info).pointer? { false }

        assert_equal ":foo", type_info.tag_or_class_name
      end
    end

    describe "for :utf8" do
      it "returns the string ':utf8'" do
        mock(type_info).tag { :utf8 }
        mock(type_info).pointer? { true }

        assert_equal ":utf8", type_info.tag_or_class_name
      end
    end

    describe "for an interface class" do
      it "returns the interface's full class name" do
        mock(type_info).tag { :interface }
        mock(type_info).interface_type_name { "-full-type-name-" }
        mock(type_info).pointer? { false }

        assert_equal "-full-type-name-", type_info.tag_or_class_name
      end
    end

    describe "for a pointer to simple type :foo" do
      it "returns the string '[:pointer, :foo]'" do
        mock(type_info).tag { :foo }
        mock(type_info).pointer? { true }

        assert_equal "[:pointer, :foo]", type_info.tag_or_class_name
      end
    end
  end

  describe "#tag_or_class" do
    describe "for a simple type" do
      it "returns the type's tag" do
        mock(type_info).tag { :foo }
        mock(type_info).pointer? { false }

        type_info.tag_or_class.must_equal :foo
      end
    end

    describe "for utf8 strings" do
      it "returns the tag :utf8" do
        mock(type_info).tag { :utf8 }
        mock(type_info).pointer? { true }

        type_info.tag_or_class.must_equal :utf8
      end
    end

    describe "for filename strings" do
      it "returns the tag :filename" do
        mock(type_info).tag { :filename }
        mock(type_info).pointer? { true }

        type_info.tag_or_class.must_equal :filename
      end
    end

    describe "for an interface class" do
      it "returns the class built from the interface" do
        interface_info = Object.new
        interface = Object.new

        mock(type_info).tag { :interface }
        mock(type_info).interface { interface_info }
        mock(type_info).pointer? { false }

        mock(GirFFI::Builder).build_class(interface_info) { interface }

        type_info.tag_or_class.must_equal interface
      end
    end

    describe "for a pointer to simple type :foo" do
      it "returns [:pointer, :foo]" do
        mock(type_info).tag { :foo }
        mock(type_info).pointer? { true }

        type_info.tag_or_class.must_equal [:pointer, :foo]
      end
    end

    describe "for a pointer to :void" do
      it "returns [:pointer, :void]" do
        stub(type_info).tag { :void }
        stub(type_info).pointer? { true }

        type_info.tag_or_class.must_equal [:pointer, :void]
      end
    end
  end

  describe "#to_callback_ffitype" do
    let(:iface) { Object.new }
    describe "for an :interface argument" do
      before do
        stub(type_info).interface { iface }
        stub(type_info).tag { :interface }
        stub(type_info).pointer? { false }
      end

      it "correctly maps a :union argument to :pointer" do
        stub(iface).info_type { :union }

        type_info.to_callback_ffitype.must_equal :pointer
      end

      it "correctly maps a :flags argument to :int32" do
        stub(iface).info_type { :flags }

        type_info.to_callback_ffitype.must_equal :int32
      end
    end
  end
end
